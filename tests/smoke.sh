#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export HOME="$tmp_dir/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"

python3 -m py_compile "$repo_dir/bin/m365-linux-shell"
bash -n "$repo_dir/install.sh"
bash -n "$repo_dir/extras/install-fonts.sh"

"$repo_dir/install.sh" --no-fonts >/tmp/m365-linux-shell-install.log

test -x "$HOME/.local/bin/m365-linux-shell"
test -f "$XDG_DATA_HOME/icons/hicolor/scalable/apps/io.github.kwran420.M365LinuxShell.svg"
test -f "$XDG_DATA_HOME/applications/io.github.kwran420.M365LinuxShell.outlook.desktop"
test -f "$XDG_DATA_HOME/applications/io.github.kwran420.M365LinuxShell.teams.desktop"
test -f "$XDG_DATA_HOME/applications/io.github.kwran420.M365LinuxShell.word.desktop"
test -f "$XDG_DATA_HOME/applications/io.github.kwran420.M365LinuxShell.Router.desktop"
grep -q '^Exec=.*m365-linux-shell run outlook$' "$XDG_DATA_HOME/applications/io.github.kwran420.M365LinuxShell.outlook.desktop"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$XDG_DATA_HOME"/applications/io.github.kwran420.M365LinuxShell.*.desktop
fi

"$repo_dir/bin/m365-linux-shell" classify 'mailto:test@example.com?subject=Hello&body=Body' | grep -q 'mailto app=outlook'
"$repo_dir/bin/m365-linux-shell" classify 'https://outlook.cloud.microsoft/mail/' | grep -q 'm365 app=outlook'
"$repo_dir/bin/m365-linux-shell" classify 'https://word.cloud.microsoft/' | grep -q 'm365 app=word'
"$repo_dir/bin/m365-linux-shell" classify 'https://teams.cloud.microsoft/' | grep -q 'm365 app=teams'
"$repo_dir/bin/m365-linux-shell" classify 'msteams:/l/meetup-join/example' | grep -q 'm365 app=teams'
"$repo_dir/bin/m365-linux-shell" classify 'https://example.com/' | grep -q 'external'
"$repo_dir/bin/m365-linux-shell" run --dry-run outlook | grep -q '^bootstrap: enable mailto and Microsoft 365 link routing'
"$repo_dir/bin/m365-linux-shell" route --dry-run 'https://excel.cloud.microsoft/' | grep -q '^excel:work:'
"$repo_dir/bin/m365-linux-shell" route --dry-run 'https://teams.cloud.microsoft/' | grep -q '^teams:work:'
"$repo_dir/bin/m365-linux-shell" route --dry-run 'msteams:/l/meetup-join/example' | grep -q '^teams:work:'
"$repo_dir/bin/m365-linux-shell" route --dry-run 'https://example.com/' | grep -q '^forward:'

echo "smoke tests passed"
