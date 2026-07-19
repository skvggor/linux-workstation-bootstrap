#!/bin/bash

GUM_VERSION="0.17.0"
GUM_CACHE_DIR="$HOME/.cache/linux-workstation-bootstrap"
GUM_BIN=""

ensure_gum() {
  if command -v gum &>/dev/null; then
    GUM_BIN="$(command -v gum)"
    return 0
  fi

  if [ -x "$GUM_CACHE_DIR/gum" ]; then
    GUM_BIN="$GUM_CACHE_DIR/gum"
    return 0
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      log_warn "Unsupported architecture for gum: $(uname -m)"
      return 1
      ;;
  esac

  log_info "Downloading gum v$GUM_VERSION (TUI helper)..."

  local tarball_url="https://github.com/charmbracelet/gum/releases/download/v$GUM_VERSION/gum_${GUM_VERSION}_Linux_$arch.tar.gz"
  local temp_dir
  temp_dir="$(mktemp -d)"

  if ! curl -fsSL "$tarball_url" -o "$temp_dir/gum.tar.gz"; then
    log_warn "Failed to download gum."
    rm -rf "$temp_dir"
    return 1
  fi

  tar -xzf "$temp_dir/gum.tar.gz" -C "$temp_dir"

  local extracted_gum
  extracted_gum="$(find "$temp_dir" -type f -name gum | head -n 1)"

  if [ -z "$extracted_gum" ]; then
    log_warn "gum binary not found in downloaded archive."
    rm -rf "$temp_dir"
    return 1
  fi

  mkdir -p "$GUM_CACHE_DIR"
  mv "$extracted_gum" "$GUM_CACHE_DIR/gum"
  chmod +x "$GUM_CACHE_DIR/gum"
  rm -rf "$temp_dir"

  GUM_BIN="$GUM_CACHE_DIR/gum"
}

tui_banner() {
  "$GUM_BIN" style \
    --border rounded \
    --border-foreground 212 \
    --padding "1 3" \
    --margin "1 0" \
    "Linux Workstation Bootstrap" \
    "Pick what you want to install. Everything is preselected."
}

tui_choose_category() {
  local category="$1"
  local ids options option id entry description
  mapfile -t ids < <(catalog_ids_in_category "$category")

  options=()
  for id in "${ids[@]}"; do
    entry="$(catalog_entry "$id")"
    description="$(catalog_field "$entry" 2)"
    options+=("$id — $description")
  done

  local preselected
  preselected="$(printf '%s,' "${options[@]}")"
  preselected="${preselected%,}"

  local chosen
  chosen="$("$GUM_BIN" choose \
    --no-limit \
    --height 12 \
    --header "[$category] Space to toggle. Enter to confirm." \
    --selected "$preselected" \
    "${options[@]}")" || true

  while IFS= read -r option; do
    [ -n "$option" ] && echo "${option%% —*}"
  done <<<"$chosen"
}

tui_fallback_prompt() {
  local category id entry

  echo ""
  echo "Available items:"

  for category in $(catalog_categories); do
    echo ""
    echo "  [$category]"
    for id in $(catalog_ids_in_category "$category"); do
      entry="$(catalog_entry "$id")"
      printf '    %-20s %s\n' "$id" "$(catalog_field "$entry" 2)"
    done
  done

  echo ""
  local answer
  read -rp "Items to install (comma-separated ids/categories, or 'all') [all]: " answer
  answer="${answer:-all}"

  if [ "$answer" = "all" ]; then
    catalog_ids
  else
    expand_selection "$answer"
  fi
}

# Sets SELECTED_ITEMS with the ids chosen by the user, in catalog order.
run_tui() {
  SELECTED_ITEMS=()

  if ! ensure_gum; then
    log_warn "gum unavailable. Falling back to plain prompt."
    mapfile -t SELECTED_ITEMS < <(tui_fallback_prompt)
    return 0
  fi

  tui_banner

  local category chosen_ids=()
  for category in $(catalog_categories); do
    mapfile -t -O "${#chosen_ids[@]}" chosen_ids < <(tui_choose_category "$category")
  done

  if [ ${#chosen_ids[@]} -eq 0 ]; then
    return 0
  fi

  local id
  for id in $(catalog_ids); do
    if [[ " ${chosen_ids[*]} " == *" $id "* ]]; then
      SELECTED_ITEMS+=("$id")
    fi
  done

  echo ""
  "$GUM_BIN" style --foreground 212 "Selected (${#SELECTED_ITEMS[@]}): ${SELECTED_ITEMS[*]}"

  if ! "$GUM_BIN" confirm "Proceed with installation?"; then
    SELECTED_ITEMS=()
  fi
}
