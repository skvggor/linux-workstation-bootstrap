#!/bin/bash

log_info() { echo "[INFO] $*" >&2; }

log_warn() { echo "[WARN] $*" >&2; }

log_error() {
  echo "[ERROR] $*" >&2
  exit 1
}

detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    SUDO_CMD="sudo"
    INSTALL_CMD="$SUDO_CMD apt install -y"
    ADD_REPO_CMD="$SUDO_CMD add-apt-repository -y"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    SUDO_CMD="sudo"
    INSTALL_CMD="$SUDO_CMD dnf install -y"
  elif command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    SUDO_CMD="sudo"
    INSTALL_CMD="$SUDO_CMD pacman -S --noconfirm --needed"
  else
    log_error "Package manager not supported."
  fi

  export PKG_MANAGER SUDO_CMD INSTALL_CMD ADD_REPO_CMD
}

update_package_lists() {
  log_info "Updating package lists..."

  case $PKG_MANAGER in
    apt) $SUDO_CMD apt update -y ;;
    dnf) $SUDO_CMD dnf check-update || true ;;
    pacman) $SUDO_CMD pacman -Syu --noconfirm ;;
  esac
}

install_packages() {
  if [ $# -eq 0 ]; then
    return 0
  fi

  if $INSTALL_CMD "$@"; then
    return 0
  fi

  log_warn "Batch install failed. Retrying packages individually..."

  local pkg
  local failed=()

  for pkg in "$@"; do
    $INSTALL_CMD "$pkg" || failed+=("$pkg")
  done

  if [ ${#failed[@]} -gt 0 ]; then
    log_warn "Could not install: ${failed[*]}"
  fi
}

install_yay_if_needed() {
  if [ "$PKG_MANAGER" == "pacman" ] && ! command -v yay &>/dev/null; then

    local current_dir_yay_install
    current_dir_yay_install=$(pwd)

    $SUDO_CMD pacman -S --noconfirm --needed git base-devel

    cd /tmp || exit 1
    [ -d "yay" ] && rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit 1
    makepkg -si --noconfirm
    cd "$current_dir_yay_install" || exit 1
  fi
}

install_aur_packages() {
  if [ "$PKG_MANAGER" == "pacman" ]; then
    install_yay_if_needed

    if [ $# -gt 0 ]; then
      yay -S --noconfirm "$@"
    fi
  fi
}
