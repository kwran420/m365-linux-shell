#!/usr/bin/env bash
set -euo pipefail

SELAWIK_URL="https://github.com/microsoft/Selawik/releases/download/1.01/Selawik_Release.zip"

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
font_dir="$data_home/fonts/selawik"
fontconfig_dir="$config_home/fontconfig/conf.d"
alias_file="$fontconfig_dir/49-m365-linux-shell-selawik.conf"

install_apt_compat=0

usage() {
  cat <<USAGE
Install Microsoft 365-compatible fonts for Microsoft 365 Linux Shell.

Usage:
  ./extras/install-fonts.sh
  ./extras/install-fonts.sh --with-apt-compat
USAGE
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  if ! command_exists "$1"; then
    printf 'error: missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --with-apt-compat)
      install_apt_compat=1
      shift
      ;;
    *)
      printf 'unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_command curl
require_command unzip
require_command install
require_command fc-cache
require_command fc-match

if [[ "$install_apt_compat" == "1" ]]; then
  if ! command_exists apt-get || ! command_exists sudo; then
    printf 'error: --with-apt-compat requires apt-get and sudo\n' >&2
    exit 1
  fi
  sudo apt-get install -y fonts-liberation2 fonts-crosextra-carlito fonts-crosextra-caladea
fi

tmp_dir="$(mktemp -d)"
alias_tmp="$(mktemp)"
trap 'rm -rf "$tmp_dir"; rm -f "$alias_tmp"' EXIT

curl -fsSL "$SELAWIK_URL" -o "$tmp_dir/Selawik_Release.zip"
unzip -q "$tmp_dir/Selawik_Release.zip" -d "$tmp_dir/selawik"

install -d "$font_dir" "$fontconfig_dir"
install -m 0644 "$tmp_dir"/selawik/*.ttf "$font_dir/"

cat >"$alias_tmp" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias binding="same">
    <family>Segoe UI</family>
    <accept>
      <family>Selawik</family>
    </accept>
  </alias>

  <alias binding="same">
    <family>Segoe UI Web</family>
    <accept>
      <family>Selawik</family>
    </accept>
  </alias>

  <alias binding="same">
    <family>Segoe UI Variable</family>
    <accept>
      <family>Selawik</family>
    </accept>
  </alias>
</fontconfig>
EOF
install -m 0644 "$alias_tmp" "$alias_file"

fc-cache -f "$font_dir" "$config_home/fontconfig"

printf 'installed Selawik fonts: %s\n' "$font_dir"
printf 'installed fontconfig aliases: %s\n' "$alias_file"
printf 'Segoe UI resolves to: '
fc-match 'Segoe UI'
