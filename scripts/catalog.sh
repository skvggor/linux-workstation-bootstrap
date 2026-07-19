#!/bin/bash

# Each entry: id|category|description|install command
# Execution always follows catalog order regardless of selection order.
CATALOG=(
  "essentials|system|Base packages (curl git wget unzip xclip) and directories|run_essentials_setup"
  "system-tools|system|Dev tools (fish ghostty konsole micro lsd jq cmake net-tools cmatrix)|install_system_tools"
  "default-shell|system|Set Fish as the default shell|setup_shell"
  "hyprland-tools|system|Hyprmon monitor manager (Arch + Hyprland only)|install_hyprland_tools"
  "go|languages|Go toolchain|install_go"
  "rust|languages|Rust toolchain via rustup|install_rust"
  "node|languages|Node.js LTS via nvm + global npm packages|install_node"
  "starship|cli|Starship prompt|install_starship"
  "nitch|cli|Nitch system fetch|install_nitch"
  "atuin|cli|Atuin shell history|install_atuin"
  "bat|cli|Bat: a better cat|install_bat"
  "zellij|cli|Zellij terminal multiplexer|install_zellij"
  "zoxide|cli|Zoxide: a smarter cd|install_zoxide"
  "alacritty|cli|Alacritty terminal (built with cargo)|install_alacritty"
  "design-apps|apps|OBS Studio / Krita / Inkscape / Gimp / Darktable / VLC / Cheese|install_design_apps"
  "docker|apps|Docker Engine and Compose|install_docker"
  "dbeaver|apps|DBeaver CE database client|install_dbeaver"
  "insomnia|apps|Insomnia API client|install_insomnia"
  "chrome|apps|Google Chrome|install_chrome"
  "edge|apps|Microsoft Edge|install_edge"
  "vscode|apps|VS Code Insiders|install_vscode"
  "misc-apps|apps|Flameshot and Solaar|install_misc_apps"
  "font-jetbrainsmono|fonts|JetBrainsMono Nerd Font|install_nerd_font JetBrainsMono"
  "font-firacode|fonts|FiraCode Nerd Font|install_nerd_font FiraCode"
  "font-hack|fonts|Hack Nerd Font|install_nerd_font Hack"
  "font-meslo|fonts|Meslo Nerd Font|install_nerd_font Meslo"
  "font-geistmono|fonts|GeistMono Nerd Font|install_nerd_font GeistMono"
  "font-iosevka|fonts|Iosevka Nerd Font|install_nerd_font Iosevka"
  "font-monaspace|fonts|Monaspace font family|install_monaspace"
  "dotfiles|configs|Dotfiles (fish starship alacritty ghostty zellij lsd konsole pulse git)|run_configs_setup"
)

catalog_field() {
  local entry="$1" index="$2"
  local fields
  IFS='|' read -r -a fields <<<"$entry"
  echo "${fields[$index]}"
}

catalog_entry() {
  local id="$1" entry
  for entry in "${CATALOG[@]}"; do
    if [ "$(catalog_field "$entry" 0)" = "$id" ]; then
      echo "$entry"
      return 0
    fi
  done
  return 1
}

catalog_ids() {
  local entry
  for entry in "${CATALOG[@]}"; do
    catalog_field "$entry" 0
  done
}

catalog_categories() {
  local entry category
  local seen=""
  for entry in "${CATALOG[@]}"; do
    category="$(catalog_field "$entry" 1)"
    if [[ " $seen " != *" $category "* ]]; then
      seen="$seen $category"
      echo "$category"
    fi
  done
}

catalog_ids_in_category() {
  local category="$1" entry
  for entry in "${CATALOG[@]}"; do
    if [ "$(catalog_field "$entry" 1)" = "$category" ]; then
      catalog_field "$entry" 0
    fi
  done
}

# Expands a comma-separated list of item ids and/or category names
# into item ids. Accepts legacy module names as category aliases.
expand_selection() {
  local token
  for token in ${1//,/ }; do
    case $token in
      cli_tools) token="cli" ;;
    esac

    if catalog_entry "$token" >/dev/null; then
      echo "$token"
    elif [[ " $(catalog_categories | tr '\n' ' ') " == *" $token "* ]]; then
      catalog_ids_in_category "$token"
    else
      log_error "Unknown item or category: $token (use --list to see available options)"
    fi
  done
}
