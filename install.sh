#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$SCRIPT_DIR/scripts"

if [ -f "$SCRIPTS_PATH/utils.sh" ]; then
  source "$SCRIPTS_PATH/utils.sh"
else
  echo "Error: scripts/utils.sh not found."
  exit 1
fi

available_modules=(system configs languages cli_tools apps fonts)
only_modules=""
skip_modules=""

usage() {
  cat <<EOF
Usage: bash install.sh [options]

Options:
  --only <modules>  Run only the given modules (comma-separated)
  --skip <modules>  Skip the given modules (comma-separated)
  --list            List available modules
  -h, --help        Show this help

Available modules: ${available_modules[*]}

Examples:
  bash install.sh --only fonts,configs
  bash install.sh --skip apps
EOF
}

validate_modules() {
  local name

  for name in ${1//,/ }; do
    if [[ " ${available_modules[*]} " != *" $name "* ]]; then
      log_error "Unknown module: $name (available: ${available_modules[*]})"
    fi
  done
}

while [ $# -gt 0 ]; do
  case $1 in
    --only)
      only_modules="${2:-}"
      [ -n "$only_modules" ] || log_error "--only requires a comma-separated list of modules."
      validate_modules "$only_modules"
      shift 2
      ;;
    --skip)
      skip_modules="${2:-}"
      [ -n "$skip_modules" ] || log_error "--skip requires a comma-separated list of modules."
      validate_modules "$skip_modules"
      shift 2
      ;;
    --list)
      printf '%s\n' "${available_modules[@]}"
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

should_run() {
  if [ -n "$only_modules" ]; then
    [[ ",$only_modules," == *",$1,"* ]]
  else
    [[ ",$skip_modules," != *",$1,"* ]]
  fi
}

selected_modules=()
for module in "${available_modules[@]}"; do
  if should_run "$module"; then
    selected_modules+=("$module")
  fi
done

if [ ${#selected_modules[@]} -eq 0 ]; then
  log_error "No modules selected."
fi

for module in "${selected_modules[@]}"; do
  module_file="$SCRIPTS_PATH/$module.sh"

  if [ -f "$module_file" ]; then
    # shellcheck source=/dev/null
    source "$module_file"
  else
    log_error "Module $module not found in $SCRIPTS_PATH"
  fi
done

detect_package_manager
log_info "Detected package manager: $PKG_MANAGER"

needs_package_update=false
for module in "${selected_modules[@]}"; do
  case $module in
    system | languages | cli_tools | apps) needs_package_update=true ;;
  esac
done

if [ "$needs_package_update" = true ]; then
  update_package_lists
fi

log_info "Starting installation (modules: ${selected_modules[*]})..."

for module in "${selected_modules[@]}"; do
  case $module in
    system) run_system_setup ;;
    configs) run_configs_setup "$SCRIPT_DIR" ;;
    languages) run_language_setup ;;
    cli_tools) run_cli_tools_setup ;;
    apps) run_apps_setup ;;
    fonts) run_fonts_setup ;;
  esac
done

log_info "Installation completed successfully!"
log_info "Please restart your shell or computer to apply all changes."
