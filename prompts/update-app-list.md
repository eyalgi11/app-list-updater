# Job

You are maintaining the Markdown app inventory in `apps.md`.

This job is AI-native. The user should not have to add apps by hand.

Use the runtime discovery snapshot appended below this prompt, plus any additional safe local inspection commands you need, to discover installed user-facing applications.

## Discovery Rules

Add missing apps to `apps.md` when they are likely user-facing applications, especially:

- GUI apps from `.desktop` launchers
- browsers, editors, terminals, media tools, office tools, communication tools, developer tools, and app stores
- apps installed in `/home/eyal/.local/opt`, `/opt`, Flatpak, Snap, AppImage locations, or obvious user-local paths

Skip items that are probably internal components, helpers, MIME handlers, settings panels, package internals, duplicated launchers, or background services.

If you are unsure whether something is user-facing, prefer not adding it unless there is strong evidence.

Add at most 10 newly discovered apps per run. Prioritize user-local installs, browsers, core productivity apps, developer tools, app stores, and other high-confidence daily-use applications. Existing rows should always be checked even when the add cap is reached.

For AppImage and manual executable candidates:

- Add them only when the file clearly appears to be a user-facing app, not a helper/library/test binary.
- Use `Install Type` = `appimage` for `.AppImage` files.
- Use `Install Type` = `user-local` for manually installed executable apps in user-local directories.
- Use `Update Method` = `manual` unless there is a specific, reliable updater or project-supported AppImage update flow.
- Use `Auto Update` = `no` for manual/AppImage entries unless this project already has a dedicated handler for that app.
- Use `Repo Version` = `n/a` when no package manager owns the app.
- Put enough path/source detail in `Notes` for a future handler to be written.

## Update Rules

For every existing or newly added app row:

1. Determine the installed/current version from local commands or files where practical.
2. Determine `Install Type`: `rpm`, `flatpak`, `snap`, `appimage`, `user-local`, `source`, or `unknown`.
3. Determine `Update Method`: `zypper`, `flatpak`, `snap`, `appimage`, `custom-waterfox`, `codex-update`, `manual`, or `unknown`.
4. Determine `Auto Update`: `yes`, `no`, or `partial`.
5. Determine `Repo Version`: the package-manager candidate version when applicable. Use `n/a` for installs without a repository owner.
6. Check the official source URL first when it exists.
7. If `Source URL` is missing, find the official project/vendor release or download page and fill it in.
8. Verify `Upstream Version`, meaning the latest stable release available from the upstream project/vendor for Linux x86_64 when applicable.
9. Compare `Current Version` with `Repo Version` to decide whether the configured updater can update it.
10. Compare `Current Version` with `Upstream Version` only to report whether newer upstream exists.
11. Update `Install Type`, `Update Method`, `Auto Update`, `Current Version`, `Repo Version`, `Upstream Version`, `Source URL`, `Last Checked`, and `Notes`.
12. For `zypper` apps, describe installable updates using `Repo Version`, not `Upstream Version`.
13. If `Upstream Version` is newer but `Repo Version` is current, say "newer upstream exists" or "held by distro repo"; do not call it an unattended-upgrade failure.
14. Do not install, remove, upgrade, or change applications. This job only updates Markdown.
15. Preserve the Markdown table format.

`Auto Update` means any updater in this project can apply updates without normal user interaction. Do not rely only on `config.env`: that file controls the user-level upgrade run. If the runtime snapshot shows the root `app-list-system-upgrade.timer` and `app-list-system-upgrade.service` with `AUTO_UPGRADE_SYSTEM=1`, then RPM/zypper apps are auto-updated by the root timer and should use `Auto Update` = `yes`.

Use the current date for `Last Checked`.

Prefer primary sources: official websites, official release feeds, vendor documentation, or official GitHub/GitLab releases. If a source is unavailable, write that clearly in `Notes`.

Keep the final response short and include:

- apps discovered
- apps checked
- apps added
- apps outdated
- files changed

# Runtime Discovery Snapshot
