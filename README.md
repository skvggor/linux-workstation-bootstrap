# Linux Workstation Bootstrap

A collection of **system configuration** and **package installation** scripts for various Linux distributions.

| Distribution | Tested On |
|--------------|-----------|
| **Ubuntu/Debian-like** (apt) | Ubuntu Desktop 24.04.3 LTS |
| **Arch-based** (pacman + yay + aur) | Omarchy 3.2.0 (Hyprland) |
| **Fedora/Nobara/RHEL-like** (dnf) | Fedora 43 Workstation |

## Overview

This project provides a modular installation script that automatically detects your distribution and sets up a complete development and multimedia environment. It handles:

- **System Essentials**: Basic tools (curl, git, unzip) and shell setup (Fish).
- **Languages**: Go, Rust (via rustup), and Node.js (via nvm).
- **CLI Tools**: Starship, Atuin, Nitch, Bat, Zellij, Zoxide.
- **Apps**: VS Code Insiders, Chrome, Edge, Docker, DBeaver, and design tools.
- **Fonts**: Optimized installation of specific Nerd Fonts and Monaspace.
- **Configs**: Automatic dotfiles linking for Alacritty, Fish, Starship, etc.

## Prerequisites

- A supported Linux distribution.

## How to Use

1. **Download** this repository:

Click the green "Code" button and select "Download ZIP", or clone it using Git:

![Download](assets/download.gif)

   ```bash
   git clone https://github.com/skvggor/linux-workstation-bootstrap.git
   cd linux-workstation-bootstrap
   ```

2. **Run the installation script**:
   ```bash
   bash install.sh
   ```

   You can also run specific modules:
   ```bash
   bash install.sh --list              # list available modules
   bash install.sh --only fonts,configs
   bash install.sh --skip apps
   ```

3. **Follow the prompts** (you will need to enter your sudo password).

4. **Restart your computer** or log out/in to apply all changes (especially for group changes like Docker and shell changes).

## Project Structure

The installation logic is modularized in the `scripts/` directory:

- `install.sh`: Main entry point and orchestrator.
- `scripts/system.sh`: Base system packages and directories.
- `scripts/languages.sh`: Programming language environments (Go, Rust, Node/NVM).
- `scripts/cli_tools.sh`: Terminal utilities and shell prompts.
- `scripts/apps.sh`: GUI applications and Docker.
- `scripts/fonts.sh`: Font installation (downloads only specific fonts to save bandwidth).
- `scripts/configs.sh`: Dotfiles management.
- `scripts/utils.sh`: Helper functions and package manager detection.

## Included Software

### Development
- **Languages**: Go, Rust, Node.js (LTS via NVM)
- **Editors**: VS Code Insiders, Micro
- **Terminal**: Ghostty, Alacritty, Konsole
- **Shell**: Fish (default), Starship (prompt)
- **Tools**: Docker, Docker Compose, DBeaver CE, Insomnia, Git, JQ, Net-tools
- **NPM Global**: gtop, localtunnel, svgo, vercel

### CLI Utilities
- **Atuin**: Shell history sync
- **Bat**: Better `cat`
- **LSD**: Better `ls`
- **Nitch**: System fetch
- **Zellij**: Terminal multiplexer
- **Zoxide**: Smarter `cd`
- **cmatrix**: Matrix-style animation

### Hyprland (Arch Linux only)
- **Hyprmon**: TUI for managing monitor/display layouts in Hyprland (installed automatically when Hyprland is detected)

### Multimedia & Design
- **Apps**: OBS Studio, Krita, Inkscape, Gimp, Darktable, VLC, Cheese
- **Browsers**: Google Chrome, Microsoft Edge

### Utilities
- **Flameshot**: Screenshot tool
- **Solaar**: Logitech device manager
- **xclip**: Clipboard utility

### Fonts
- **Nerd Fonts**: JetBrainsMono, FiraCode, Hack, Meslo, GeistMono, Iosevka
- **Monaspace**: GitHub's new font family

## Additional Scripts

These scripts are standalone and are not run by `install.sh`:

- `prepare-dropbox-sync.sh`: Replaces the local home folders (Documents, Downloads, Projects, etc.) with symlinks to their Dropbox counterparts, backing up any existing local content, and updates the XDG user directories.
- `setup-gnome-terminal.sh`: Creates a pre-configured GNOME Terminal profile (font, transparency, cursor, scrollback) and sets it as default.

## Contributing

1. **Fork** the repository.
2. Create a **feature branch**.
3. Modify the relevant scripts in `scripts/`.
4. Open a **pull request**.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
