#!/usr/bin/env bash
# This script is designed to install and configure dotfiles
# on an Arch Linux system. It checks for necessary dependencies,
# installs packages, backs up existing dotfiles and sets up wallpapers.

set -euo pipefail

AUTHOR="rojikaru"
DRY_RUN=${DRY_RUN:-false}
DOTS_DIR="${DOTS_DIR:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

gums() {
	gum style --bold --foreground "$@"
}

help() {
	echo "Usage: $0 [--help]"
	echo
	echo "Options:"
	echo "  --help    Show this help message and exit"
	echo "  --dry-run  Show what would be done without making any changes"
}

abort_installation() {
	local details="${1:-"Aborting installation."}"
	if command -v gum &>/dev/null; then
		gums 1 "$details"
	else
		printf "\e[31m%s\e[0m\n" "$details"
	fi
	exit 1
}

OPTIONS=$(getopt -o h --long help,dry-run -- "$@")
eval set -- "$OPTIONS"
while true; do
	case "$1" in
	--help | -h)
		help
		exit 0
		;;
	--dry-run)
		DRY_RUN=true
		shift
		;;
	--)
		shift
		break
		;;
	*)
		echo "Invalid option: $1"
		help
		exit 1
		;;
	esac
done

if [[ "$DRY_RUN" = true ]]; then
	gums 4 "Dry run mode enabled. No changes will be made."
fi

# Check if on Arch by looking for pacman command
if ! command -v pacman &>/dev/null; then
	abort_installation "This script is Arch-only. Exiting."
fi

# Check if on Wayland by checking for WAYLAND_DISPLAY environment variable
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
	abort_installation "This script is designed for Wayland sessions. Exiting."
fi

# Find & install missing dependencies
MISSING=()
command -v git &>/dev/null || MISSING+=(git)
command -v gum &>/dev/null || MISSING+=(gum)
pacman -Q base-devel &>/dev/null || MISSING+=(base-devel)

if [[ ${#MISSING[@]} -gt 0 ]]; then
	printf "\e[33mInstalling bootstrap deps: ${MISSING[*]}\e[0m\n"
	if [[ "$DRY_RUN" = true ]]; then
		printf "\e[33m[Dry run] would install ${MISSING[*]}\e[0m\n"
	else
		sudo pacman -S --noconfirm "${MISSING[@]}" || {
			abort_installation "Failed to install bootstrap dependencies: ${MISSING[*]}"
		}
	fi
fi

# Check if inside the dotfiles repo
if [[ "$SCRIPT_DIR" != "$DOTS_DIR" ]]; then
	if [[ -d "$DOTS_DIR" ]]; then
		abort_installation "$DOTS_DIR already exists but you're not running from it. cd into it and re-run."
	fi
	git clone "https://github.com/$AUTHOR/dotfiles" "$DOTS_DIR" ||
		abort_installation "Failed to clone dotfiles repo."
	cd "$DOTS_DIR"
	exec bash install.sh # Re-run the script from the cloned repo
fi

# No liability disclaimer
gums 3 --border rounded --padding "1 2" \
	"⚠  Configure snapper or another snapshotting tool before proceeding." \
	"⚠  This script makes no guarantees. You are responsible."
printf "\n"

gum confirm \
	"I have configured a snapshotting tool, made a backup, and accept responsibility for what I am about to do.
I acknowledge original author, $AUTHOR, does not have any liability for any damages caused by this script." ||
	abort_installation

# Try to create a snapshot before proceeding
if command -v snapper &>/dev/null &&
	gum confirm "Create a snapshot with snapper before proceeding?"; then
	if [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would create a snapshot with snapper"
	else
		sudo snapper create --description "Pre-dotfiles-installation snapshot"
		gums 2 "Snapshot created successfully."
	fi
	printf "\n"
fi

# Find an AUR helper
AUR_HELPERS=("paru" "yay" "aurman")
AUR_HELPER=""
for helper in "${AUR_HELPERS[@]}"; do
	command -v $helper &>/dev/null && AUR_HELPER=$helper && break
done

if [[ -z "$AUR_HELPER" ]]; then
	AUR_HELPER=$(printf "%s\n" "${AUR_HELPERS[@]}" | gum choose \
		--header="No AUR helper found. Choose one to install:" ||
		abort_installation "No AUR helper found. Please install one manually and re-run the script.")

	if [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would install $AUR_HELPER"
	else
		git clone https://aur.archlinux.org/$AUR_HELPER.git /tmp/$AUR_HELPER
		(cd /tmp/$AUR_HELPER && makepkg -si --noconfirm)
		gums 2 "$AUR_HELPER installed successfully."
	fi
fi

# Baseline requirements for .config and .local/bin to work
if gum confirm "Install base packages? (needed for .config and .local/bin to work)"; then
	if [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would install base packages"
	else
		grep -v '^\s*$' packages/base.txt | $AUR_HELPER -S --needed --noconfirm - ||
			abort_installation "Failed to install base packages. Exiting."
		gums 2 "Base packages installed successfully."
	fi
else
	abort_installation "Installation aborted."
fi
printf "\n"

# Checking only for PPD because it's provided by tlp-pd too
if ! pacman -Q \
	power-profiles-daemon \
	iwd networkmanager \
	pipewire bluez \
	&>/dev/null; then
	gums 3 --border rounded --padding "1 2" \
		"⚠  power-profiles-daemon (or tlp), iwd, networkmanager, pipewire, and bluez" \
		"⚠  are required for proper functionality. They aren't included, so" \
		"⚠  please install them manually OR run the script again and select" \
		"⚠  'Auto-install (select lists of packages)' to install them OR" \
		"⚠  configure other packages to your liking throughout the dots " \
		"⚠  (grep for aforementioned tools). The script will continue, " \
		"⚠  but you may encounter issues during usage later."
	printf "\n"
fi 

# Other packages installation
NATIVE_PACKAGES_COUNT=$(wc -l <packages/native.txt)
AUR_PACKAGES_COUNT=$(wc -l <packages/aur.txt)
PACKAGES_COUNT=$((NATIVE_PACKAGES_COUNT + AUR_PACKAGES_COUNT))
INSTALLATION_CHOICE="Auto-install (select lists of packages)"

if [[ -n "$AUR_HELPER" ]]; then
	INSTALLATION_CHOICE=$(
		gum choose --header="Pick package installation type" \
			"Auto-install (select lists of packages)" \
			"Custom installation (select individual packages from $PACKAGES_COUNT in lists)" \
			"Skip package installation"
	)
fi

case "$INSTALLATION_CHOICE" in
"Auto-install (select lists of packages)")
	if [[ "$NATIVE_PACKAGES_COUNT" -gt 0 ]] &&
		gum confirm "Install native packages (packages/native.txt)?"; then
		if [[ "$DRY_RUN" = true ]]; then
			gums 4 "[Dry run] would install native packages"
		else
			sudo pacman -S --needed --noconfirm - <packages/native.txt
			gums 2 "Native packages installed successfully."
		fi
	fi

	if [[ -n "$AUR_HELPER" && "$AUR_PACKAGES_COUNT" -gt 0 ]] &&
		gum confirm "Install AUR packages (packages/aur.txt)?"; then
		if [[ "$DRY_RUN" = true ]]; then
			gums 4 "[Dry run] would install AUR packages"
		else
			$AUR_HELPER -S --needed --noconfirm - <packages/aur.txt
			gums 2 "AUR packages installed successfully."
		fi
	fi
	;;

"Custom installation (select individual packages from $PACKAGES_COUNT in lists)")
	ALL_PACKAGES=$(cat packages/native.txt packages/aur.txt | grep -v -- '-debug$')
	PACKAGES_COUNT=$(echo "$ALL_PACKAGES" | wc -l)

	SELECTED_PACKAGES=$(
		echo "$ALL_PACKAGES" |
			gum filter \
				--header="Select packages to install ($PACKAGES_COUNT available)" \
				--no-limit --selected=*
	) || true

	if [[ -z "$SELECTED_PACKAGES" ]]; then
		gums 3 "No packages selected. Proceeding."
	elif [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would install: $(echo "$SELECTED_PACKAGES" | tr '\n' ' ')"
	else
		echo "$SELECTED_PACKAGES" | xargs $AUR_HELPER -S --needed --noconfirm
		gums 2 "Selected packages installed successfully."
	fi
	;;
"Skip package installation")
	gums 3 "Skipping package installation."
	;;
*)
	abort_installation "Invalid choice. Exiting."
	;;
esac
printf "\n"

gum confirm "Install hyprexpo (workspace viewer)?" && {
	if [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would install hyprexpo"
	else
		hyprpm add https://github.com/sandwichfarm/hyprexpo
		hyprpm enable hyprexpo
		hyprpm reload
		gums 2 "hyprexpo installed successfully."
	fi
} || gums 3 "Skipping hyprexpo installation."
printf "\n"

# Dotfiles backup
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y-%m-%d-%H%M%S)"
if gum confirm "Backup existing dotfiles to $BACKUP_DIR? (will move ~/.config and ~/.local/bin)"; then
	if [[ "$DRY_RUN" = true ]]; then
		gums 4 "[Dry run] would backup existing dotfiles to $BACKUP_DIR"
	else
		mkdir -p "$BACKUP_DIR"
		if [[ -e "$XDG_CONFIG_HOME" ]]; then
			mv "$XDG_CONFIG_HOME" "$BACKUP_DIR/"
		fi
		for item in .local/bin .zshrc .tmux.conf; do
			if [[ -e "$HOME/$item" ]]; then
				mv "$HOME/$item" "$BACKUP_DIR/"
			fi
		done
		gums 2 "Existing dotfiles backed up to $BACKUP_DIR."
	fi
	printf "\n"
fi

# Dotfiles symlinking
AVAILABLE_DIRS=$(find "$DOTS_DIR" -mindepth 1 -maxdepth 1 -type d \
	! -name 'packages' \
	! -name 'scripts' \
	! -name 'wallpapers' \
	! -name '.git' \
	-exec basename {} \;)
SELECTED_DIRS=$(
	echo "$AVAILABLE_DIRS" | gum choose \
		--header="Select directories to install from dotfiles repo" \
		--no-limit --selected=*
) || true

if [[ -z "$SELECTED_DIRS" ]]; then
	gums 3 "No directories selected. Skipping dotfiles installation."
elif [[ "$DRY_RUN" = true ]]; then
	gums 4 "[Dry run] would symlink selected directories: $SELECTED_DIRS"
else
	DEPLOY_CHOICE=$(
		gum choose --header="How would you like to deploy dotfiles?" \
			"Symlink (stow) — edits sync back to repo" \
			"Copy (eject) — standalone copy, no sync" \
			"Skip — I'll deploy manually"
	)

	case "$DEPLOY_CHOICE" in
	"Symlink (stow) — edits sync back to repo")
		for dir in $SELECTED_DIRS; do
			stow -d "$DOTS_DIR" -t ~ "$dir"
			gums 2 "Symlinked $dir"
		done
		;;

	# Walk the package tree and copy preserving structure
	"Copy (eject) — standalone copy, no sync")
		for dir in $SELECTED_DIRS; do
			find "$DOTS_DIR/$dir" -mindepth 1 | while read -r src; do
				rel="${src#$DOTS_DIR/$dir/}"
				dst="$HOME/$rel"
				if [[ -d "$src" ]]; then
					mkdir -p "$dst"
				else
					mkdir -p "$(dirname "$dst")"
					cp -p "$src" "$dst"
				fi
			done
			gums 2 "Copied $dir"
		done
		;;

	"Skip — I'll deploy manually")
		gums 3 "Skipping deployment."
		;;

	esac
fi
printf "\n"

# Wallpaper setup
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
if [[ "$DRY_RUN" = true ]]; then
	gums 4 "[Dry run] would copy wallpapers to $WALLPAPER_DIR"
elif gum confirm "Copy wallpapers to $WALLPAPER_DIR?"; then
	mkdir -p "$WALLPAPER_DIR"
	cp -r "$DOTS_DIR"/wallpapers/* "$WALLPAPER_DIR/"
	gums 2 "Wallpapers copied to $WALLPAPER_DIR"
else
	gums 3 "Skipping wallpaper copy. Remember to put yours in $WALLPAPER_DIR."
fi

if [[ "$DRY_RUN" = true ]]; then
	gums 4 "[Dry run] would set wallpaper using wallset"
elif [[ -n "${WAYLAND_DISPLAY:-}" && -d "$WALLPAPER_DIR" && -n "$(ls -A $WALLPAPER_DIR)" ]]; then
	$HOME/.local/bin/wallset
	gums 2 "Wallpaper set successfully."
else
	gums 3 "No Wayland session or wallpapers detected. Run wallset manually after login."
fi
printf "\n"

# Enabling services
SERVICES=("hypridle.service")
if command -v systemctl &>/dev/null; then
	CHOSEN_SERVICES=$(
		gum choose --header="Select services to enable" \
			--no-limit "${SERVICES[@]}"
	) || true

	if [[ -z "$CHOSEN_SERVICES" ]]; then
		gums 3 "No services selected. Skipping."
	else
		# Split newline-separated string into array
		mapfile -t CHOSEN_ARRAY <<<"$CHOSEN_SERVICES"

		systemctl --user enable --now "${CHOSEN_ARRAY[@]}" || {
			gums 1 "Failed to enable some services."
		}
		gums 2 "Enabled: ${CHOSEN_ARRAY[*]}"
	fi
else
	gums 3 "Systemd not detected. Skipping service enablement."
fi

# Post-installation
gums 2 \
	"Installation complete. Please restart your session to apply changes."
gums 3 \
	"If you encounter issues, restore from backup: mv $BACKUP_DIR/* $HOME/
or use your snapshotting tool to revert the system state."
printf "\n"

RESTART_CHOICE=$(
	gum choose --header="Would you like to restart your session now?" \
		"Yes, restart now" \
		"No, I'll restart later"
)

case "$RESTART_CHOICE" in
"Yes, restart now")
	gums 3 "Restarting session..."
	if [[ "$DRY_RUN" = true ]]; then
		gums 3 "[Dry run] would restart session"
	elif [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
		gums 3 "Restarting Hyprland session..."
		hyprctl dispatch 'hl.dsp.exit()'
	else
		gums 3 "Not running inside Hyprland. Please log out manually."
	fi
	;;
"No, I'll restart later")
	gums 3 "Please remember to restart your session later to apply changes."
	;;
*)
	abort_installation "Invalid choice. Exiting."
	;;
esac
