# Design Notes

## Goal

Provide a solid Linux shell for Microsoft 365 web apps without pretending that
unsupported Windows Office desktop apps are native Linux software.

## Architecture

- System Chromium-family browser as the runtime.
- Shared isolated profile for Microsoft 365 SSO.
- Separate desktop entries for each app, including Teams.
- `mailto:` handler for Outlook compose.
- Teams protocol handlers for meeting and chat links.
- Optional HTTP/HTTPS router for Microsoft 365, Teams, OneDrive, and SharePoint links.

## Why Not Windows Office Under Wine

Office under Wine or similar compatibility layers can be useful for experiments,
but it is not an official Microsoft-supported Linux path and is not a reliable
foundation for a public app. The supported Linux path is Microsoft 365 for the
web in a compatible browser.
