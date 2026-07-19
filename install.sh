#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$REPO_DIR/scripts"

for lib in utils catalog tui system configs languages cli_tools apps fonts; do
  lib_file="$SCRIPTS_PATH/$lib.sh"

  if [ -f "$lib_file" ]; then
    # shellcheck source=/dev/null
    source "$lib_file"
  else
    echo "Error: scripts/$lib.sh not found." >&2
    exit 1
  fi
done

only_selection=""
skip_selection=""
install_all=false

usage() {
  cat <<EOF
Usage: bash install.sh [options]

Without options, an interactive TUI lets you pick what to install.

Options:
  --all             Install everything without prompting
  --only <list>     Install only the given items/categories (comma-separated)
  --skip <list>     Install everything except the given items/categories
  --list            List available items grouped by category
  -h, --help        Show this help

Categories: $(catalog_categories | tr '\n' ' ')

Examples:
  bash install.sh --only fonts,dotfiles
  bash install.sh --only docker,chrome,vscode
  bash install.sh --skip apps
EOF
}

list_items() {
  local category id entry

  for category in $(catalog_categories); do
    echo "[$category]"
    for id in $(catalog_ids_in_category "$category"); do
      entry="$(catalog_entry "$id")"
      printf '  %-20s %s\n' "$id" "$(catalog_field "$entry" 2)"
    done
    echo ""
  done
}

while [ $# -gt 0 ]; do
  case $1 in
    --all)
      install_all=true
      shift
      ;;
    --only)
      only_selection="${2:-}"
      [ -n "$only_selection" ] || log_error "--only requires a comma-separated list."
      shift 2
      ;;
    --skip)
      skip_selection="${2:-}"
      [ -n "$skip_selection" ] || log_error "--skip requires a comma-separated list."
      shift 2
      ;;
    --list)
      list_items
      exit 0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      log_error "Unknown option: $1"
      ;;
  esac
done

detect_package_manager
log_info "Detected package manager: $PKG_MANAGER"

SELECTED_ITEMS=()

if [ -n "$only_selection" ]; then
  expand_selection "$only_selection" >/dev/null
  mapfile -t requested < <(expand_selection "$only_selection")

  for id in $(catalog_ids); do
    if [[ " ${requested[*]} " == *" $id "* ]]; then
      SELECTED_ITEMS+=("$id")
    fi
  done
elif [ -n "$skip_selection" ]; then
  expand_selection "$skip_selection" >/dev/null
  mapfile -t skipped < <(expand_selection "$skip_selection")

  for id in $(catalog_ids); do
    if [[ " ${skipped[*]} " != *" $id "* ]]; then
      SELECTED_ITEMS+=("$id")
    fi
  done
elif [ "$install_all" = true ] || [ ! -t 0 ]; then
  mapfile -t SELECTED_ITEMS < <(catalog_ids)
else
  run_tui
fi

if [ ${#SELECTED_ITEMS[@]} -eq 0 ]; then
  log_info "Nothing selected. Exiting."
  exit 0
fi

needs_package_update=false
needs_font_cache=false

for id in "${SELECTED_ITEMS[@]}"; do
  case "$(catalog_field "$(catalog_entry "$id")" 1)" in
    system | languages | cli | apps) needs_package_update=true ;;
    fonts) needs_font_cache=true ;;
  esac
done

if [ "$needs_package_update" = true ]; then
  update_package_lists
fi

log_info "Starting installation (${#SELECTED_ITEMS[@]} items: ${SELECTED_ITEMS[*]})..."

for id in "${SELECTED_ITEMS[@]}"; do
  read -r -a install_command <<<"$(catalog_field "$(catalog_entry "$id")" 3)"
  "${install_command[@]}"
done

if [ "$needs_font_cache" = true ]; then
  refresh_font_cache
fi

log_info "Installation completed successfully!"
log_info "Please restart your shell or computer to apply all changes."
