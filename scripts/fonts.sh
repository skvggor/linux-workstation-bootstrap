#!/bin/bash

NERD_FONTS_VERSION="v3.4.0"

install_nerd_font() {
  local font="$1"
  local fonts_dir="$HOME/.local/share/fonts"
  local base_url="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION"

  mkdir -p "$fonts_dir"

  if [ -d "$fonts_dir/$font" ]; then
    log_info "Font $font already installed, skipping."
    return
  fi

  log_info "Downloading $font Nerd Font..."
  local zip_file="/tmp/$font.zip"
  wget -q --show-progress "$base_url/$font.zip" -O "$zip_file"

  if [ -f "$zip_file" ]; then
    unzip -o -q "$zip_file" -d "$fonts_dir/$font"
    rm "$zip_file"
  else
    log_warn "Failed to download $font"
  fi
}

install_monaspace() {
  log_info "Installing Monaspace Font..."
  local monaspace_dir="/tmp/monaspace-main"
  local zip_file="/tmp/monaspace.zip"

  if [ -d "$HOME/.local/share/fonts/monaspace" ]; then
    log_info "Monaspace already installed, skipping."
    return
  fi

  wget -q --show-progress "https://github.com/githubnext/monaspace/archive/refs/heads/main.zip" -O "$zip_file"
  unzip -o -q "$zip_file" -d "/tmp"

  if [ -d "$monaspace_dir" ]; then
    mkdir -p "$HOME/.local/share/fonts/monaspace"
    find "$monaspace_dir" \( -name "*.otf" -o -name "*.ttf" \) -exec cp {} "$HOME/.local/share/fonts/monaspace/" \;
    rm -rf "$monaspace_dir" "$zip_file"
  fi
}

refresh_font_cache() {
  log_info "Updating font cache..."
  fc-cache -f
}
