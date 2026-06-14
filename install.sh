#!/usr/bin/env bash
set -euo pipefail

APP_ID="io.github.kwran420.M365LinuxShell"
APP_NAME="Microsoft 365 Linux Shell"

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bindir="${XDG_BIN_HOME:-$HOME/.local/bin}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
apps_dir="$data_home/applications"
icons_dir="$data_home/icons/hicolor/scalable/apps"
launcher_file="$bindir/m365-linux-shell"
icon_file="$icons_dir/$APP_ID.svg"
router_desktop="$apps_dir/$APP_ID.Router.desktop"

install_fonts=1
install_apt_fonts=0
with_http_router=1
dry_run=0
uninstall=0

app_entries=(
  "Teams:teams:Microsoft Teams chat, meetings, and calls"
  "Outlook:outlook:Outlook email and calendar"
  "Microsoft 365:m365:Microsoft 365 home"
  "Word:word:Word for the web"
  "Excel:excel:Excel for the web"
  "PowerPoint:powerpoint:PowerPoint for the web"
  "OneDrive:onedrive:OneDrive files"
  "Outlook Calendar:calendar:Calendar for Outlook on the web"
)

usage() {
  cat <<USAGE
Install $APP_NAME for the current user.

Usage:
  ./install.sh
  ./install.sh --no-http-router
  ./install.sh --with-apt-fonts
  ./install.sh --no-fonts
  ./install.sh --dry-run
  ./install.sh --uninstall

The default install registers Outlook mailto handling and HTTP/HTTPS Microsoft
365 link routing. Non-Microsoft links are forwarded to your saved real browser.
USAGE
}

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf 'dry-run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

desktop_id_for_app() {
  local app="$1"
  printf '%s.%s.desktop\n' "$APP_ID" "$app"
}

icon_id_for_app() {
  local app="$1"
  printf '%s.%s\n' "$APP_ID" "$app"
}

startup_wm_class_for_app() {
  case "$1" in
    teams) printf '%s\n' "M365LinuxTeams" ;;
    outlook) printf '%s\n' "M365LinuxOutlook" ;;
    calendar) printf '%s\n' "M365LinuxCalendar" ;;
    word) printf '%s\n' "M365LinuxWord" ;;
    excel) printf '%s\n' "M365LinuxExcel" ;;
    powerpoint) printf '%s\n' "M365LinuxPowerPoint" ;;
    onedrive) printf '%s\n' "M365LinuxOneDrive" ;;
    *) printf '%s\n' "M365LinuxShell" ;;
  esac
}

write_app_desktop() {
  local name="$1"
  local app="$2"
  local comment="$3"
  local desktop_file
  local startup_wm_class
  local icon_id
  desktop_file="$apps_dir/$(desktop_id_for_app "$app")"
  startup_wm_class="$(startup_wm_class_for_app "$app")"
  icon_id="$(icon_id_for_app "$app")"

  cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Version=1.5
Name=$name
GenericName=Microsoft 365 Web App
Comment=$comment
Exec=$launcher_file run $app
Icon=$icon_id
Terminal=false
Categories=Office;
StartupNotify=true
StartupWMClass=$startup_wm_class
Actions=OpenWork;OpenPersonal;Doctor;DisableRouter;

[Desktop Action OpenWork]
Name=Open Work Profile
Exec=$launcher_file launch $app --profile work

[Desktop Action OpenPersonal]
Name=Open Personal Profile
Exec=$launcher_file launch $app --profile personal

[Desktop Action Doctor]
Name=Run Doctor
Exec=$launcher_file doctor

[Desktop Action DisableRouter]
Name=Disable Link Routing
Exec=$launcher_file disable-router
EOF
}

write_router_desktop() {
  cat >"$router_desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.5
Name=Microsoft 365 Linux Shell Router
GenericName=Microsoft 365 Link Router
Comment=Route Microsoft 365 and mailto links to the Microsoft 365 Linux Shell
Exec=$launcher_file route %U
Icon=$APP_ID
Terminal=false
NoDisplay=true
Categories=Office;
MimeType=x-scheme-handler/mailto;x-scheme-handler/msteams;x-scheme-handler/ms-teams;x-scheme-handler/web+msteams;x-scheme-handler/teams;x-scheme-handler/http;x-scheme-handler/https;
EOF
}

install_font_setup() {
  if [[ "$install_fonts" != "1" ]]; then
    printf '%s\n' "skipped font setup"
    return 0
  fi

  local font_args=()
  if [[ "$install_apt_fonts" == "1" ]]; then
    font_args+=(--with-apt-compat)
  fi

  if [[ "$dry_run" == "1" ]]; then
    printf 'dry-run:'
    printf ' %q' "$repo_dir/extras/install-fonts.sh" "${font_args[@]}"
    printf '\n'
    return 0
  fi

  if ! "$repo_dir/extras/install-fonts.sh" "${font_args[@]}"; then
    if [[ "$install_apt_fonts" == "1" ]]; then
      return 1
    fi
    printf '%s\n' "warning: font setup failed; run ./extras/install-fonts.sh manually"
  fi
}

install_app() {
  run install -d "$bindir" "$apps_dir" "$icons_dir"
  run install -m 0755 "$repo_dir/bin/m365-linux-shell" "$launcher_file"
  run install -m 0644 "$repo_dir/assets/m365-linux-shell.svg" "$icon_file"
  local entry name app comment
  for entry in "${app_entries[@]}"; do
    IFS=: read -r name app comment <<<"$entry"
    run install -m 0644 "$repo_dir/assets/$app.svg" "$icons_dir/$(icon_id_for_app "$app").svg"
  done

  if [[ "$dry_run" == "1" ]]; then
    for entry in "${app_entries[@]}"; do
      IFS=: read -r _name app _comment <<<"$entry"
      printf 'dry-run: write %q\n' "$apps_dir/$(desktop_id_for_app "$app")"
    done
    printf 'dry-run: write %q\n' "$router_desktop"
  else
    for entry in "${app_entries[@]}"; do
      IFS=: read -r name app comment <<<"$entry"
      write_app_desktop "$name" "$app" "$comment"
    done
    write_router_desktop
  fi

  if command -v desktop-file-validate >/dev/null 2>&1 && [[ "$dry_run" != "1" ]]; then
    local desktop
    for desktop in "$apps_dir"/"$APP_ID".*.desktop; do
      desktop-file-validate "$desktop"
    done
  fi

  if command -v update-desktop-database >/dev/null 2>&1 && [[ "$dry_run" != "1" ]]; then
    update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
  fi

  install_font_setup

  local router_args=()
  if [[ "$with_http_router" != "1" ]]; then
    router_args+=(--no-http-router)
  fi

  if [[ "$dry_run" == "1" ]]; then
    printf 'dry-run:'
    printf ' %q' "$launcher_file" post-install "${router_args[@]}"
    printf '\n'
  else
    "$launcher_file" post-install "${router_args[@]}"
  fi

  printf 'installed launcher: %s\n' "$launcher_file"
  printf 'installed desktop entries: %s/%s.*.desktop\n' "$apps_dir" "$APP_ID"
  printf 'installed icon: %s\n' "$icon_file"
}

uninstall_app() {
  if [[ -x "$launcher_file" && "$dry_run" != "1" ]]; then
    "$launcher_file" pre-uninstall || true
  elif [[ "$dry_run" == "1" ]]; then
    printf 'dry-run:'
    printf ' %q' "$launcher_file" pre-uninstall
    printf '\n'
  fi

  run rm -f "$launcher_file" "$icon_file" "$apps_dir"/"$APP_ID".*.desktop "$icons_dir"/"$APP_ID".*.svg

  if command -v update-desktop-database >/dev/null 2>&1 && [[ "$dry_run" != "1" ]]; then
    update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
  fi
  printf '%s\n' "removed installed launcher, desktop entries, and icon"
  printf 'profile data is left in %s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/m365-linux-shell"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --no-http-router)
      with_http_router=0
      shift
      ;;
    --with-apt-fonts)
      install_fonts=1
      install_apt_fonts=1
      shift
      ;;
    --no-fonts)
      install_fonts=0
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --uninstall)
      uninstall=1
      shift
      ;;
    *)
      printf 'unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$uninstall" == "1" ]]; then
  uninstall_app
else
  install_app
fi
