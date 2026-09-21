# NixOS Configuration: Hyprland & Caelestia Shell

A declarative, modular NixOS flake configuration featuring the **Hyprland** Wayland compositor, **Caelestia Shell & CLI**, and Home Manager.

---

## 🖥️ Overview & Features

* **Compositor**: [Hyprland](https://hypr.land/) (with UWSM session support and native Lua configuration)
* **Desktop Shell**: [Caelestia Shell](https://github.com/caelestia-dots/shell) (Quickshell-based dynamic Material 3 panels, launcher, status bar, and wallpaper switcher)
* **CLI Utility**: [Caelestia CLI](https://github.com/caelestia-dots/cli) (theming, special workspace toggles, and shell control)
* **Hardware & Acceleration**: Intel Arc B580 Battlemage VA-API acceleration, AMD CPU microcode, ZRAM swap, and HeadsetControl udev rules
* **Display Manager**: [Ly](https://github.com/fairyglade/ly) (lightweight, modern TUI login manager)
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
├── flake.nix                       # Flake inputs (nixpkgs-unstable, home-manager, caelestia-shell)
├── hosts/
│   └── nixarchy/
│       ├── default.nix             # Host definition (imports system modules & hardware)
│       └── hardware-configuration.nix # Hardware config (overridden per machine)
├── modules/
│   ├── system/
│   │   ├── base.nix                # Bootloader, networking, locale, user 'ani', nix settings
│   │   ├── hyprland.nix            # Hyprland, Ly display manager, PipeWire, Polkit, portals
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
```

### 2. Generate Target Hardware Configuration
Generate the hardware specification for the target machine:
```bash
# Clone your repo or clone temporarily
nixos-generate-config --root /mnt
```
Copy or commit the newly generated `/mnt/etc/nixos/hardware-configuration.nix` into your repository at `hosts/nixarchy/hardware-configuration.nix`.

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
