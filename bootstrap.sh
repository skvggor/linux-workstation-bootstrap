#!/bin/bash

# Remote entry point. Run on a freshly installed machine with:
#   curl -fsSL https://raw.githubusercontent.com/skvggor/linux-workstation-bootstrap/main/bootstrap.sh | bash
#
# To test another branch:
#   curl -fsSL https://raw.githubusercontent.com/skvggor/linux-workstation-bootstrap/<branch>/bootstrap.sh | BOOTSTRAP_BRANCH=<branch> bash

set -euo pipefail

REPO_URL="${BOOTSTRAP_REPO_URL:-https://github.com/skvggor/linux-workstation-bootstrap.git}"
REPO_BRANCH="${BOOTSTRAP_BRANCH:-main}"
INSTALL_DIR="$HOME/.local/share/linux-workstation-bootstrap"

log() { echo "[BOOTSTRAP] $*" >&2; }

ensure_git() {
  if command -v git &>/dev/null; then
    return
  fi

  log "Installing git..."

  if command -v apt-get &>/dev/null; then
    sudo apt update -y && sudo apt install -y git
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y git
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm git
  else
    log "Error: unsupported package manager. Install git manually and retry."
    exit 1
  fi
}

ensure_git

if [ -d "$INSTALL_DIR/.git" ]; then
  log "Updating existing copy in $INSTALL_DIR (branch: $REPO_BRANCH)..."
  git -C "$INSTALL_DIR" fetch --depth 1 origin "$REPO_BRANCH" &&
    git -C "$INSTALL_DIR" checkout -B "$REPO_BRANCH" FETCH_HEAD ||
    log "Could not update. Using current copy."
else
  log "Cloning repository into $INSTALL_DIR (branch: $REPO_BRANCH)..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# When piped from curl, stdin is the pipe. Reattach the terminal
# so the interactive TUI works; fall back to --all when headless.
if [ -t 0 ]; then
  exec bash install.sh "$@"
elif { : </dev/tty; } 2>/dev/null; then
  exec bash install.sh "$@" </dev/tty
else
  log "No terminal available. Running non-interactively."
  exec bash install.sh "${@:---all}"
fi
