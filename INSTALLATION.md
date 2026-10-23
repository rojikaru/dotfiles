# Arch Linux Manual Installation Guide

## Stack: LUKS + btrfs + Limine UKI + Secure Boot + TPM + Hyprland (uwsm) + TLP

Tested on: HP Omen, Intel Core 5 210H + RTX 5060, June 2026.

---

## 0. Pre-installation

### Boot from USB

1. Download Arch ISO, flash with Ventoy or balenaEtcher
2. In UEFI: disable Secure Boot, set USB as first boot device
3. Boot into live environment

### WiFi (if needed)

```bash
iwctl
station wlan0 scan
station wlan0 connect <SSID>
# enter password
exit
```

---

## 1. Disk Partitioning

```bash
cfdisk /dev/nvme0n1
```

Create two partitions:

| Partition | Size | Type |
|-----------|------|------|
| nvme0n1p1 | 512MB–1GB | EFI System |
| nvme0n1p2 | Remaining | Linux filesystem |

Write and quit.

```bash
# Format EFI
mkfs.fat -F32 /dev/nvme0n1p1
```

---

## 2. LUKS Encryption

```bash
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 root
```

---

## 3. btrfs + Subvolumes

```bash
mkfs.btrfs /dev/mapper/root
mount /dev/mapper/root /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@swap

umount /mnt
```

### Mount with options

```bash
mount -o subvol=@,compress=zstd:3,ssd,space_cache=v2 /dev/mapper/root /mnt

mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,var/log,swap}

mount -o subvol=@home,compress=zstd:3,ssd,space_cache=v2 /dev/mapper/root /mnt/home
mount -o subvol=@pkg,compress=zstd:3,ssd,space_cache=v2 /dev/mapper/root /mnt/var/cache/pacman/pkg
mount -o subvol=@log,compress=zstd:3,ssd,space_cache=v2 /dev/mapper/root /mnt/var/log
mount -o subvol=@swap,compress=zstd:3,ssd,space_cache=v2 /dev/mapper/root /mnt/swap

mount /dev/nvme0n1p1 /mnt/boot
```

---

## 4. Pacstrap

IMPORTANT: don't copy-paste this list blindly!!!

Some of these packages are for Intel iGPU + Nvidia dGPU combo.
If you have other hardware, please find the relevant alternatives.

```bash
pacstrap -K /mnt \
  base base-devel linux linux-headers linux-firmware \
  intel-ucode btrfs-progs cryptsetup \
  mesa intel-media-driver vulkan-intel vulkan-icd-loader \
  networkmanager iwd \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  nvidia-dkms nvidia-utils lib32-nvidia-utils \
  lib32-mesa lib32-vulkan-icd-loader \
  sudo neovim vim curl wget git openssh \
  zsh zsh-completions man-db man-pages \
  htop btop fastfetch \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
  bluez bluez-utils docker docker-compose bolt \
  limine rtkit sof-firmware \
  alsa-utils
```

---

## 5. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
# Add swap entry manually:
echo "/swap/swapfile none swap defaults,pri=0 0 0" >> /mnt/etc/fstab
cat /mnt/etc/fstab  # verify all subvolumes present
```

---

## 6. Chroot — Base Configuration

```bash
arch-chroot /mnt
```

### Timezone and locale

```bash
ln -sf /usr/share/zoneinfo/Europe/Kyiv /etc/localtime
hwclock --systohc
echo "hp-omen" > /etc/hostname

# /etc/locale.gen — uncomment:
# en_US.UTF-8 UTF-8
# uk_UA.UTF-8 UTF-8
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### pacman.conf

```bash
nvim /etc/pacman.conf
# Uncomment [multilib] section (both lines)
# Add under [options]:
# Color
# VerbosePkgLists
# ParallelDownloads = 10
# ILoveCandy
pacman -Syy
```

### Users

```bash
passwd  # root password
useradd -m -G wheel,docker,video,input,storage -s /bin/zsh rojikaru
passwd rojikaru
EDITOR=nvim visudo  # uncomment %wheel ALL=(ALL:ALL) ALL
```

---

## 7. Swapfile for Hibernate

```bash
btrfs filesystem mkswapfile --size 28g /swap/swapfile
swapon /swap/swapfile
swapon --show

# Get resume offset (save this number)
btrfs inspect-internal map-swapfile -r /swap/swapfile > /tmp/offset.txt
cat /tmp/offset.txt
```

---

## 8. mkinitcpio — UKI Setup

```bash
nvim /etc/mkinitcpio.conf
```

```
MODULES=()
HOOKS=(base systemd autodetect microcode modconf kms block keyboard sd-vconsole sd-encrypt filesystems fsck)
```

### UKI preset

```bash
mkdir -p /boot/EFI/Linux

nvim /etc/mkinitcpio.d/linux.preset
```

```ini
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_uki="/boot/EFI/Linux/arch-linux.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

fallback_uki="/boot/EFI/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect"
```

### Kernel cmdline (CRITICAL — this is what UKI embeds)

IMPORTANT: Change `nvidia-drm` attribute if you have dGPU other than Nvidia!

```bash
# Get UUIDs
LUKS_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
RESUME_OFFSET=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)

cat > /etc/kernel/cmdline <<EOF
rd.luks.name=${LUKS_UUID}=root root=/dev/mapper/root rootflags=subvol=@ rw rootfstype=btrfs nvidia-drm.modeset=1 resume=/dev/mapper/root resume_offset=${RESUME_OFFSET}
EOF

cat /etc/kernel/cmdline  # verify
```

### LUKS for initramfs

```bash
cat > /etc/crypttab.initramfs <<EOF
root UUID=${LUKS_UUID} - luks
EOF
```

### Generate UKI

```bash
mkinitcpio -P
ls -lh /boot/EFI/Linux/  # verify .efi files exist and are 100MB+
```

---

## 9. Limine Bootloader

```bash
# Install Limine EFI
mkdir -p /boot/EFI/limine
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/limine_x64.efi

# Fallback for UEFI that ignores custom entries (e.g. HP)
mkdir -p /boot/EFI/BOOT
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI

# Create config
mkdir -p /boot/limine
nvim /boot/limine/limine.conf
```

```ini
timeout: 5

/Arch Linux
    protocol: efi
    efi_path: boot():/EFI/Linux/arch-linux.efi

/Arch Linux Fallback
    protocol: efi
    efi_path: boot():/EFI/Linux/arch-linux-fallback.efi
```

### /etc/default/limine (for limine-mkinitcpio hook)

```bash
nvim /etc/default/limine
```

```bash
TARGET_OS_NAME="Arch"
ESP_PATH="/boot"
ENABLE_UKI=yes
CUSTOM_UKI_NAME="arch"
ENABLE_LIMINE_FALLBACK=yes
```

> **Note:** `/etc/default/limine` is used by the limine pacman hook.
> `/etc/kernel/cmdline` is what actually gets embedded into the UKI by mkinitcpio.
> Both must exist. This was the critical discovery during installation.

---

## 10. Enable Services

```bash
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable bluetooth
systemctl enable docker
systemctl enable sddm
systemctl enable tlp
systemctl enable rtkit-daemon
```

---

## 11. Exit and Reboot

```bash
exit
reboot
# Remove USB when screen goes dark
```

---

## 12. Post-boot: Secure Boot

```bash
# First boot will be without Secure Boot
# Verify system works, then:

pacman -S sbctl

sbctl status  # Setup Mode must be Enabled (set in UEFI first)
sbctl create-keys
sbctl enroll-keys -m  # -m includes Microsoft keys (important for HP/most laptops)

# Sign all EFI files
sbctl sign -s /boot/EFI/Linux/arch-linux.efi
sbctl sign -s /boot/EFI/limine/limine_x64.efi
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

sbctl verify  # all should show ✓

# Enable Secure Boot in UEFI, reboot
```

---

## 13. Post-boot: TPM Auto-decrypt

After Secure Boot is working:

```bash
pacman -S tpm2-tools tpm2-tss

# Enroll LUKS key into TPM
# PCR0 = firmware, PCR7 = Secure Boot state
systemd-cryptenroll --tpm2-device=auto \
  --tpm2-pcrs=0+7 \
  /dev/nvme0n1p2

# Update crypttab.initramfs
nvim /etc/crypttab.initramfs
```

```
root UUID=<LUKS_UUID> - tpm2-device=auto,password-echo=no
```

```bash
mkinitcpio -P
reboot
# System should now decrypt automatically via TPM
# Password prompt appears only if Secure Boot state changes
```

---

## 14. Post-boot: Snapshots

```bash
pacman -S snapper snap-pac

snapper -c root create-config /
snapper -c home create-config /home

# Edit /etc/snapper/configs/root
# Set reasonable limits:
# TIMELINE_LIMIT_HOURLY="5"
# TIMELINE_LIMIT_DAILY="7"
# TIMELINE_LIMIT_WEEKLY="0"
# TIMELINE_LIMIT_MONTHLY="0"
# TIMELINE_LIMIT_YEARLY="0"

systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer

snapper -c root create --description "base install"

# For Limine snapshot entries:
paru -S limine-snapper-sync
```

> **Note:** For read-only snapshots to boot, `sd-volatile` hook is needed in mkinitcpio
> so systemd mounts an overlay over the ro snapshot.

---

## 15. Desktop Environment

### AUR helper

```bash
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
cd .. && rm -rf paru
```

### Hyprland + SDDM + portal

```bash
pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  qt5-wayland qt6-wayland \
  sddm uwsm \
  waybar mako \
  polkit-kde-agent \
  wl-clipboard

paru -S walker-bin
```

### SDDM Wayland config

```bash
mkdir -p /etc/sddm.conf.d/
nvim /etc/sddm.conf.d/wayland.conf
```

```ini
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=Hyprland
```

### Use uwsm session in SDDM

At login screen, select **"Hyprland (uwsm-managed)"** — not plain Hyprland.
This activates `graphical-session.target` correctly, which is required for xdg-desktop-portal.

---

## 16. Power Management

```bash
pacman -S tlp tlp-pd
systemctl enable tlp
systemctl enable --now tlp-pd

# Gaming/performance profile
sudo tee /etc/tlp.d/10-gaming.conf >/dev/null <<'EOF'
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
EOF

sudo tlp start
```

---

## 17. Wayland Environment Variables

```bash
mkdir -p ~/.config/environment.d
nvim ~/.config/environment.d/wayland.conf
```

```ini
NIXOS_OZONE_WL=1
ELECTRON_OZONE_PLATFORM_HINT=wayland
```

---

## Key Lessons Learned

| Problem | Solution |
| --------- | ---------- |
| UKI boots with wrong/no cmdline | `/etc/kernel/cmdline` must exist — mkinitcpio reads it, NOT `/etc/default/limine` |
| Limine "Image path not specified" | Path syntax must be `boot():/EFI/Linux/arch-linux.efi` with `boot():` prefix |
| UEFI ignores custom EFI entries (HP) | Copy to `/boot/EFI/BOOT/BOOTX64.EFI` as fallback |
| xdg-desktop-portal dependency failed | Use uwsm session — it activates `graphical-session.target` |
| No audio (only Dummy Output) | Install `sof-firmware` for Intel HDA on modern laptops |
| Games low FPS, GPU underutilized | CPU was in `powersave` governor — TLP config needed for AC profile |
| nvidia-dkms not found | Package is `nvidia-dkms` not `nvidia` on modern kernels |
