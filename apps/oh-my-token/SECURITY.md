---
title: "oh-my-token Security and Data Storage"
date: 2026-10-09
tags:
  - oh-my-token
  - security
  - cookie
  - keychain
  - privacy
---

# oh-my-token Security and Data Storage

This document describes where the app stores cookies and sessions.
It also describes what the app sends on the network.
In this document, `<bundle-id>` is the app bundle identifier.

## Read-only rule

- The app never sends a prompt or a conversation request.
- Every usage request is a read-only GET request.
- The shared request helper accepts no request body.
- The rule applies to every provider: Claude and ChatGPT.

The ChatGPT reader reads the website session access token.
It sends this token in an `Authorization: Bearer` header on its GET requests.
The token authenticates the read. The app does not use it for prompts.
A GET request cannot prove every server-side accounting effect.

## Usage read page

Each usage read loads the provider `/robots.txt` file in a hidden page.
This small text file gives the reader the provider origin and the account cookies.
The page does not load the provider web app.
The reader script runs on this page and sends its GET requests.
The app closes the page after each read.

## Sign-in browser

The sign-in window and every popup window show the actual origin of the current page.
The origin is the scheme and the host name, for example `https://claude.ai`.

- A page on a provider domain has no extra label.
- A page on a known SSO service has the label "Sign-in provider".
- Any other page has the label "External site" in orange.
- A page without HTTPS shows an open lock.

The main window and the popups use the same navigation rule for the top-level page.

- HTTPS pages and `about:` pages load in the app.
- A link that you click to an external site opens in the system browser.
- Other schemes, for example `http:`, `data:`, and `file:`, do not load in the app.

Company SSO redirects to other HTTPS hosts still load in the app.
Check the origin label before you type a password.

The provider domains are in `Account.swift`.
The SSO services are in `WebsiteOrigin.swift`.

The sign-in browser exists only while the sign-in window is open.
When you close the window, the app closes the browser and its popups.
The cookies stay in the account WebKit store.

## Normal website sign-in

The app uses one persistent WebKit store for each account.
The app calls `WKWebsiteDataStore(forIdentifier: profile.id)`.

- Base folder: `~/Library/WebKit/<bundle-id>/`
- One folder for each account: `WebsiteDataStore/<account-UUID>/`
- Cookies: `WebsiteDataStore/<account-UUID>/Cookies/Cookies.binarycookies`

The same folder holds other website data.
The other data includes `LocalStorage`, `IndexedDB`, `NetworkCache`, and `HSTS`.

WebKit writes the cookie file with normal file permissions in the home folder.
The cookie file is not in the Keychain.
The app does not encrypt the cookie file.

The account UUID matches the account ID in `Account.swift`.

## Imported session

The Import session action stores only the cookie name and value pairs.
It does not store a whole page or a token.

- Store: macOS Keychain, generic password
- Service: `<bundle-id>.imported-session`
- Account: the account UUID
- Accessibility: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`

The `ThisDeviceOnly` setting stops iCloud sync.
The item stays on this Mac only.

The app copies these cookies into the WebKit store only when the store has no sign-in cookie.
A newer website login wins over the imported session.

The Keychain item exists only after you use Import session.
A normal sign-in through the app browser does not create this item.

## App state

The app writes small state to UserDefaults.

- File: `~/Library/Preferences/<bundle-id>.plist`
- Keys: `connected.<account-UUID>` and `workspace.<account-UUID>`
- The app also stores the Accounts window frame.

These values are not secrets.
They record the connected accounts and the selected workspace.
The app saves a workspace only when the website still lists it.
If the saved workspace is gone, the app clears it.
An account with one workspace then uses that workspace.
An account with more than one workspace shows the picker.

## Disconnect

Disconnect removes two items for that account only.

1. The Keychain item, through `SessionImport.remove(for:)`.
2. The account WebKit website data, through `websiteDataStore.removeData`.

Disconnect is available also when the account check failed or did not run.
A failed check does not remove the local cookies.
Use Disconnect to remove them.

Other accounts keep their own cookies and sessions.

## Security notes

- The app never writes a cookie or a token to this repository.
- The app sends a cookie only to the provider website.
- The Keychain item is device only and not synced.
- The WebKit cookie file is on disk in the home folder.
- Treat the WebKit data as account credentials. A cookie gives full website access, not only usage access.
- Protect your macOS account and use disk encryption.

## Code references

- `Sources/OhMyToken/WebsiteSession.swift`: the per-account WebKit store, the sign-in browser, the usage read page, and the navigation rule.
- `Sources/OhMyToken/WebsiteOrigin.swift`: the origin label and the SSO services.
- `Sources/OhMyToken/SessionImport.swift`: the Keychain service and cookie validation.
- `Sources/OhMyToken/AccountStore.swift`: the UserDefaults keys.
- `Sources/OhMyToken/WebsiteScript.swift`: the read-only request helper.
