# Linux Workstation Bootstrap

A collection of system configuration and package installation scripts for various Linux distributions.

## 🐧 Supported Distributions

| Distribution | Tested On | Package Manager |
| :--- | :--- | :--- |
| **Ubuntu/Debian-like** | Ubuntu Desktop 24.04.3 LTS | `apt` |
| **Arch-based** | Omarchy 3.2.0 (Hyprland) | `pacman` + `yay` + `aur` |
| **Fedora/RHEL-like** | Fedora 43 Workstation | `dnf` |

## 💡 Overview

This project provides a modular installation script that automatically detects your distribution and sets up a complete development and multimedia environment. It handles:

* **System Essentials:** Basic tools (`curl`, `git`, `unzip`) and shell setup (Fish).
* **Languages:** Go, Rust (via rustup), Node.js (via nvm), and Python.
* **CLI Tools:** Starship, Atuin, Nitch, Bat, Zellij, Zoxide.
* **Apps:** VS Code Insiders, Chrome, Edge, Docker, DBeaver, and design tools.
* **Fonts:** Optimized installation of specific Nerd Fonts and Monaspace.
* **Configs:** Automatic dotfiles linking for Alacritty, Fish, Starship, etc.

## ⚙️ Prerequisites

* A supported Linux distribution.
* Sudo privileges.

## 🚀 How to Use

1. **Clone this repository:**

```bash
git clone [https://github.com/skvggor/linux-workstation-bootstrap.git](https://github.com/skvggor/linux-workstation-bootstrap.git)
cd linux-workstation-bootstrap
