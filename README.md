# NixOS Configuration: Hyprland & Caelestia Shell

A declarative, modular NixOS flake configuration featuring the **Hyprland** Wayland compositor, **Caelestia Shell & CLI**, and Home Manager.

---

## 🖥️ Overview & Features

* **Compositor**: [Hyprland](https://hypr.land/) (with UWSM session support and native Lua configuration)
* **Desktop Shell**: [Caelestia Shell](https://github.com/caelestia-dots/shell) (Quickshell-based dynamic Material 3 panels, launcher, status bar, and wallpaper switcher)
* **CLI Utility**: [Caelestia CLI](https://github.com/caelestia-dots/cli) (theming, special workspace toggles, and shell control)
* **Display Manager**: [Ly](https://github.com/fairyglade/ly) (lightweight, modern TUI login manager)
* **Audio & Media**: PipeWire with WirePlumber, ALSA, PulseAudio emulation, and playerctl
* **Portals**: `xdg-desktop-portal-hyprland` & `xdg-desktop-portal-gtk`
* **Typography**: JetBrains Mono Nerd Font, Cascadia Code Nerd Font, Material Symbols, and Rubik
* **Dotfiles**: Self-contained and reproducible within `config/` (includes custom keybind fuzzy searcher and headset battery monitoring plugins)

---

## 📁 Repository Structure

```
nixos-config/
├── flake.nix                       # Flake inputs (nixpkgs-unstable, home-manager, caelestia-shell)
├── flake.lock                      # Flake lockfile
├── hosts/
│   └── nixarchy/
│       ├── default.nix             # Host definition (imports system modules & hardware)
│       └── hardware-configuration.nix # Hardware config (overridden per machine)
├── modules/
│   ├── system/
│   │   ├── base.nix                # Bootloader, networking, locale, user 'ani', nix settings
│   │   ├── hyprland.nix            # Hyprland, Ly display manager, PipeWire, Polkit, portals
│   │   └── fonts.nix               # Caelestia-required typography (Material Symbols, Rubik, NerdFonts)
│   └── home/
│       ├── caelestia.nix           # Caelestia shell, CLI, and config linking
│       ├── hyprland.nix            # Hyprland environment variables, PATH, user packages
│       └── neovim.nix              # Neovim configuration and LSP tooling
├── config/                         # Bundled, reproducible dotfiles
│   ├── caelestia/                  # Caelestia shell.json, cli.json, hypr-vars.lua, plugins, monitors
│   └── hypr/                       # Hyprland Lua dotfiles (hyprland.lua, keybinds, rules, animations)
├── home.nix                        # Main Home Manager entrypoint for user 'ani'
├── .gitignore                      # Git ignore rules
└── README.md                       # Documentation & deployment guide
```

---

## 🚀 Setting Up Git & Pushing to GitHub

1. **Create a new repository** on GitHub (e.g. `nixos-config`).
2. **Add your remote**:
   ```bash
   cd ~/Projects/nixos-config
   git remote add origin git@github.com:<your-github-username>/nixos-config.git
   ```
3. **Push the repository**:
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
nixos-install --flake github:<your-github-username>/nixos-config#nixarchy
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
