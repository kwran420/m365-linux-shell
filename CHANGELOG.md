# Changelog

## v1.0.0

Stable release.

- Includes Teams, Outlook, Microsoft 365, Word, Excel, PowerPoint, OneDrive, and Outlook Calendar.
- Installs separate Linux desktop entries and original per-app icons.
- Uses a shared isolated Chromium profile for Microsoft 365 sign-in.
- Handles Outlook `mailto:` links.
- Handles Teams protocol links: `msteams:`, `ms-teams:`, `web+msteams:`, and `teams:`.
- Routes Microsoft 365, Teams, Outlook, OneDrive, and SharePoint links into the shell.
- Forwards non-Microsoft links to the saved real browser.
- Installs Segoe-compatible font aliases through Selawik.
- Provides diagnostics with `m365-linux-shell doctor`.

## v0.1.2

- Added distinct original app icons.

## v0.1.1

- Integrated Teams into the Microsoft 365 shell.

## v0.1.0

- Initial Microsoft 365 Linux Shell release.
