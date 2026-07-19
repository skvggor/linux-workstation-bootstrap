#!/bin/bash

install_starship() {
  if command -v starship &>/dev/null; then
    log_info "Starship is already installed. Skipping."
    return
  fi

  log_info "Installing Starship..."

  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_packages starship
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
}

install_nitch() {
  if command -v nitch &>/dev/null; then
    log_info "Nitch is already installed. Skipping."
    return
  fi

  log_info "Installing Nitch..."

  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_aur_packages nitch
  else
    local temp_setup="$HOME/temp_nitch_setup.sh"
    wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh -O "$temp_setup"
    sh "$temp_setup"
    rm "$temp_setup"
  fi
}

install_atuin() {
  if command -v atuin &>/dev/null; then
    log_info "Atuin is already installed. Skipping."
    return
  fi

  log_info "Installing Atuin..."

  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_aur_packages atuin
  else
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi
}

CARGO_BUILD_DEPS_READY=false

ensure_cargo_build_deps() {
  export PATH="$HOME/.cargo/bin:$PATH"

  if ! command -v cargo &>/dev/null; then
    install_rust
  fi

  if [ "$CARGO_BUILD_DEPS_READY" = true ]; then
    return
  fi

  log_info "Installing build dependencies for Cargo tools..."

  local pkgs_build_cargo_common=(cmake pkg-config)

  case $PKG_MANAGER in
    apt)
      install_packages "${pkgs_build_cargo_common[@]}" python3 \
        libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
      ;;
    dnf)
      install_packages "${pkgs_build_cargo_common[@]}" python3 \
        fontconfig-devel freetype-devel libxcb-devel libxkbcommon-devel
      ;;
    pacman)
      install_packages "${pkgs_build_cargo_common[@]}" python freetype2 fontconfig libxcb libxkbcommon
      ;;
  esac

  CARGO_BUILD_DEPS_READY=true
}

cargo_install_tool() {
  local tool="$1"

  if command -v "$tool" &>/dev/null; then
    log_info "$tool is already installed. Skipping."
    return
  fi

  ensure_cargo_build_deps
  cargo install "$tool"
}

install_bat() {
  if command -v bat &>/dev/null; then
    log_info "Bat is already installed. Skipping."
    return
  fi

  log_info "Installing Bat..."

  case $PKG_MANAGER in
    pacman | dnf) install_packages bat ;;
    *) cargo_install_tool bat ;;
  esac
}

install_zellij() {
  if command -v zellij &>/dev/null; then
    log_info "Zellij is already installed. Skipping."
    return
  fi

  log_info "Installing Zellij..."

  case $PKG_MANAGER in
    pacman)
      install_packages zellij
      ;;
    dnf)
      sudo dnf copr enable varlad/zellij -y
      install_packages zellij
      ;;
    *)
      cargo_install_tool zellij
      ;;
  esac
}

install_zoxide() {
  log_info "Installing Zoxide..."
  cargo_install_tool zoxide
}

install_alacritty() {
  log_info "Installing Alacritty..."
  cargo_install_tool alacritty
  setup_alacritty_extras
}

setup_alacritty_extras() {
  if [ -f /usr/share/pixmaps/Alacritty.svg ] && [ -f /usr/share/applications/Alacritty.desktop ]; then
    log_info "Alacritty desktop entry already installed. Skipping."
    return
  fi

  log_info "Setting up Alacritty extras (icon/desktop)..."

  local temp_dir="/tmp/alacritty_extras"

  if [ ! -d "$temp_dir" ]; then
    git clone https://github.com/alacritty/alacritty "$temp_dir"
  fi

  if [ -d "$temp_dir/extra" ]; then
    local current_dir
    current_dir=$(pwd)
    cd "$temp_dir" || return

    if [ -f "extra/logo/alacritty-term.svg" ]; then
      sudo cp -v extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    fi

    if [ -f "extra/linux/Alacritty.desktop" ]; then
      sudo desktop-file-install extra/linux/Alacritty.desktop
      sudo update-desktop-database
    fi

    cd "$current_dir" || return
    rm -rf "$temp_dir"
  fi
}

