# Microsoft 365 Linux Shell

A native-feeling Linux shell for Microsoft 365 web apps. It installs real
desktop entries for Teams, Outlook, Microsoft 365, Word, Excel, PowerPoint,
OneDrive, and Calendar, runs them in a shared isolated Chromium profile, and
routes Microsoft 365 links back into the shell.

This does not install Windows Office on Linux. Microsoft does not provide
supported Linux desktop Office apps. This project uses the supported Microsoft
365 web apps and makes them behave like Linux desktop apps.

## Install

```bash
./install.sh
```

The default install:

- Adds app menu entries for Teams, Outlook, Microsoft 365, Word, Excel,
  PowerPoint, OneDrive, and Outlook Calendar.
- Installs distinct original icons for each app entry.
- Registers `mailto:` links to Outlook web compose.
- Registers Teams protocol links such as `msteams:` and `web+msteams:`.
- Registers HTTP/HTTPS routing for Microsoft 365 links.
- Forwards non-Microsoft links back to your saved browser.
- Installs Selawik font aliases so Microsoft web fonts look right on Linux.

Install without HTTP/HTTPS routing:

```bash
./install.sh --no-http-router
```

Install extra Office-compatible fallback fonts on apt-based distros:

```bash
./install.sh --with-apt-fonts
```

## Usage

Open Outlook:

```bash
m365-linux-shell
```

Open a specific app:

```bash
m365-linux-shell launch outlook
m365-linux-shell launch teams
m365-linux-shell launch word
m365-linux-shell launch excel
m365-linux-shell launch powerpoint
m365-linux-shell launch onedrive
m365-linux-shell launch calendar
m365-linux-shell launch m365
```

Use a separate account profile:

```bash
m365-linux-shell launch outlook --profile personal
```

## Link Routing

Linux desktops route URLs by scheme, not by domain. To catch normal Microsoft
365 links such as `https://outlook.cloud.microsoft/...`, Teams meeting links,
or SharePoint/OneDrive links, the shell becomes the default HTTP/HTTPS handler,
classifies the URL, and forwards non-Microsoft URLs to your saved real browser.

Disable routing:

```bash
m365-linux-shell disable-router
```

Re-enable routing:

```bash
m365-linux-shell enable-router
```

Uninstall and restore handlers:

```bash
./install.sh --uninstall
```

## Diagnostics

```bash
m365-linux-shell doctor
```

## Validation

```bash
./tests/smoke.sh
```

## Sources

- Microsoft 365 web apps: https://support.microsoft.com/en-us/office/get-started-with-my-microsoft-365-apps-91a4ec74-67fe-4a84-a268-f6bdf3da1804
- Microsoft 365 web browser support: https://support.microsoft.com/en-us/office/which-browsers-work-with-microsoft-365-for-the-web-and-microsoft-365-add-ins-ad1303e0-a318-47aa-b409-d3a5eb44e452
- Outlook on the web browser support: https://support.microsoft.com/en-us/office/supported-browsers-for-outlook-on-the-web-and-outlook-com-ca350265-6284-4682-9abd-85fc2bd37934
- Microsoft Teams PWA on Linux: https://learn.microsoft.com/en-us/microsoftteams/teams-progressive-web-apps
- Unified `cloud.microsoft` domain: https://learn.microsoft.com/en-us/microsoft-365/enterprise/cloud-microsoft-domain
- Chromium user data directories: https://chromium.googlesource.com/chromium/src/+/HEAD/docs/user_data_dir.md

## Disclaimer

This project is independent and is not affiliated with Microsoft. Microsoft,
Microsoft 365, Teams, Outlook, Word, Excel, PowerPoint, and OneDrive are
Microsoft products and trademarks. The included icon is original and
intentionally not a Microsoft logo.
