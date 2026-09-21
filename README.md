# NixOS Configuration: Hyprland & Caelestia Shell

A declarative, modular NixOS flake configuration featuring the **Hyprland** Wayland compositor, **Caelestia Shell & CLI**, and Home Manager.

---

## 🖥️ Overview & Features

* **Compositor**: [Hyprland](https://hypr.land/) (with UWSM session support and native Lua configuration)
* **Desktop Shell**: [Caelestia Shell](https://github.com/caelestia-dots/shell) (Quickshell-based dynamic Material 3 panels, launcher, status bar, and wallpaper switcher)
* **CLI Utility**: [Caelestia CLI](https://github.com/caelestia-dots/cli) (theming, special workspace toggles, and shell control)
* **Hardware & Acceleration**: Intel Arc B580 Battlemage VA-API acceleration, AMD CPU microcode, ZRAM swap, and HeadsetControl udev rules
* **Display Manager**: [Astra Airlock](https://github.com/AstraSuite/Airlock) (Caelestia-styled Material 3 Quickshell frontend for greetd)
* **Audio & Media**: PipeWire with WirePlumber, ALSA, PulseAudio emulation, EasyEffects, and playerctl
* **Networking**: NetworkManager, Tailscale mesh VPN, and stateful firewall
* **Gaming & Virtualization**: Steam (dedicated firewall rules), Feral GameMode, Gamescope, and Quickemu
* **Terminal & CLI Suite**: Starship prompt, Direnv (+ nix-direnv), Zoxide, Eza, Bat, Yazi, Btop, Nvtop, Tmux, and Lazygit
* **Desktop Applications**: Vesktop (Wayland Discord with screen/audio share), Obsidian, Thunar (with GVFS/trash), MPV, IMV, and OBS Studio
* **Typography**: JetBrains Mono Nerd Font, Cascadia Code Nerd Font, Material Symbols, and Rubik
* **Dotfiles**: Self-contained and reproducible within `config/` (includes custom keybind fuzzy searcher, monitor toggle script, and headset battery monitoring plugins)

---

## 📁 Repository Structure

```
nixos-config/
├── flake.nix                       # Flake inputs (nixpkgs-unstable, home-manager, caelestia-shell, astra-airlock)
├── hosts/
│   └── nixarchy/
│       ├── default.nix             # Host definition (imports system modules & hardware)
│       └── hardware-configuration.nix # Hardware config (overridden per machine)
├── modules/
│   ├── system/
│   │   ├── base.nix                # Bootloader, networking, locale, user 'ani', nix settings
│   │   ├── hyprland.nix            # Hyprland, Astra Airlock (greetd), PipeWire, Polkit, portals
│   │   ├── fonts.nix               # Caelestia-required typography (Material Symbols, Rubik, NerdFonts)
│   │   ├── hardware.nix            # Intel Arc GPU, AMD microcode, ZRAM swap, Headset udev, Tailscale
│   │   └── gaming.nix              # Steam, GameMode, Gamescope, Quickemu
│   └── home/
│       ├── caelestia.nix           # Caelestia shell, CLI, and config linking
│       ├── hyprland.nix            # Hyprland session env, monitor toggle script, user packages
│       ├── cli.nix                 # Starship, Direnv, Zoxide, Eza, Bat, Yazi, Btop, Lazygit
│       ├── apps.nix                # Vesktop, Obsidian, Thunar, MPV, EasyEffects, OBS Studio
│       └── neovim.nix              # Neovim configuration and LSP tooling
├── config/                         # Bundled, reproducible dotfiles
│   ├── caelestia/                  # Caelestia shell.json, cli.json, hypr-vars.lua, plugins, monitors
│   ├── hypr/                       # Hyprland Lua dotfiles & monitor toggle script
│   └── starship.toml               # Custom Starship prompt configuration
├── home.nix                        # Main Home Manager entrypoint for user 'ani'
├── .gitignore                      # Git ignore rules
└── README.md                       # Documentation & deployment guide
```

---

## 🚀 Setting Up Git & Pushing to GitHub

1. **Add your remote**:
   ```bash
   cd ~/Projects/nixos-config
   git remote set-url origin https://github.com/aniTheDude/nixos-dotfiles.git
   ```
2. **Push the repository**:
   ```bash
   git branch -M main
   git push -u origin main
   ```

---

## 🌐 Remote Installation on a Fresh Machine

When installing NixOS on a new computer or remote machine from a NixOS Minimal Live USB:

### 1. Partition and Format Disks
Example for standard UEFI GPT setup:
```bash
# Partitioning with parted or fdisk
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1024MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 1024MiB 100%

# Format partitions
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2

# Mount target partitions
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# (Optional) Create and activate a swapfile on the target disk
mkdir -p /mnt/var/lib
dd if=/dev/zero of=/mnt/var/lib/swapfile bs=1M count=16384 status=progress
chmod 0600 /mnt/var/lib/swapfile
mkswap /mnt/var/lib/swapfile
swapon /mnt/var/lib/swapfile
```

### 2. Generate Target Hardware Configuration
Generate the hardware specification for the target machine:
```bash
# Clone your repo or clone temporarily
nixos-generate-config --root /mnt
```
*Note: If you activated a swapfile above, `nixos-generate-config` will automatically detect it and include it in `/mnt/etc/nixos/hardware-configuration.nix`.*

Copy the generated hardware config into your repository:
```bash
cp /mnt/etc/nixos/hardware-configuration.nix hosts/nixarchy/hardware-configuration.nix
git add hosts/nixarchy/hardware-configuration.nix
```

### 3. Install from GitHub Remotely
Install NixOS directly using your GitHub flake:
```bash
nixos-install --flake github:aniTheDude/nixos-dotfiles#nixarchy
```

### 4. Reboot
Set your user password when prompted, then:
```bash
reboot
```

---

## 💾 Swapfile Configuration (Declarative & Post-Install)

This configuration enables **ZRAM compressed RAM swap** by default (`modules/system/hardware.nix`), which handles fast, everyday memory compression directly in RAM.

If you also want a **persistent on-disk swapfile** (for large workloads, heavy builds, or hibernation), you can configure it completely declaratively in NixOS without manual partitioning:

### 1. Declarative NixOS Swapfile
Add the swapfile definition to `hosts/nixarchy/hardware-configuration.nix` (or `modules/system/hardware.nix`):

```nix
swapDevices = [ {
  device = "/var/lib/swapfile";
  size = 16 * 1024; # 16 GB (size in megabytes)
  priority = 10;    # Lower priority than ZRAM (100) so fast RAM compression is used first
} ];
```

When you run `sudo nixos-rebuild switch --flake .#nixarchy`, NixOS will automatically:
* Allocate `/var/lib/swapfile` with the exact requested size
* Apply secure file permissions (`0600`)
* Format it with `mkswap` and enable it via `swapon`

### 2. Live USB Setup (Auto-detected during install)
If you create the swapfile while mounted in the live installer:
```bash
mkdir -p /mnt/var/lib
dd if=/dev/zero of=/mnt/var/lib/swapfile bs=1M count=16384 status=progress
chmod 0600 /mnt/var/lib/swapfile
mkswap /mnt/var/lib/swapfile
swapon /mnt/var/lib/swapfile
```
Running `nixos-generate-config --root /mnt` will automatically detect the active swapfile and include it in `hardware-configuration.nix`.

### ⚠️ Note on Btrfs
If your root filesystem is Btrfs instead of ext4, copy-on-write (CoW) must be disabled on the swapfile. Use `btrfs filesystem mkswapfile` instead:
```bash
btrfs filesystem mkswapfile --size 16g /mnt/var/lib/swapfile
swapon /mnt/var/lib/swapfile
```

## 🔄 Daily Workflow & Local Rebuilding

After making changes to the configuration on your running NixOS system:

* **Switch system**:
  ```bash
  sudo nixos-rebuild switch --flake .#nixarchy
  ```
* **Test without switching bootloader**:
  ```bash
  sudo nixos-rebuild test --flake .#nixarchy
  ```
* **Update all flake inputs** (nixpkgs, home-manager, caelestia-shell):
  ```bash
  nix flake update
  sudo nixos-rebuild switch --flake .#nixarchy
  ```

---

## ⌨️ Useful Default Keybinds

* `Super + /`: Open Caelestia fuzzy keybinds searcher
* `Super + Return`: Launch terminal (`foot`)
* `Super + Space`: Toggle Caelestia launcher
* `Super + A`: Toggle window split layout
* `Super + Q`: Close active window
* `Super + V`: Open clipboard history
