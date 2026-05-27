# Roadmap

This project should become an AI-native app maintenance loop: discover apps, understand how each one updates, apply supported updates, and keep a readable audit trail.

## 1. Add explicit app metadata

Status: done

Add stable columns to `apps.md`:

- `Install Type`: `rpm`, `flatpak`, `snap`, `appimage`, `user-local`, `source`, `unknown`
- `Update Method`: `zypper`, `flatpak`, `snap`, `appimage`, `custom-waterfox`, `manual`, `unknown`
- `Auto Update`: `yes`, `no`, or `partial`

Why: the scripts should not infer update behavior from prose notes or paths forever.

## 2. Separate distro, repo, and upstream versions

Status: done

For RPM/system packages, track:

- installed version
- repository candidate version
- upstream version

Why: openSUSE Leap may intentionally ship older, supported packages. The app should distinguish "newer upstream exists" from "zypper can update this."

## 3. Add post-upgrade re-check

Status: done

After upgrades run, refresh installed versions and update `apps.md` immediately.

Why: after an upgrade succeeds, the table should become accurate in the same run instead of waiting for next week.

## 4. Add status and summary commands

Status: done

Add commands like:

```bash
bin/status
bin/last-run
```

They should show:

- next AI check
- next system upgrade
- last run result
- outdated apps
- unsupported apps

## 5. Add desktop notifications

Status: done

Notify after weekly maintenance:

- upgraded apps
- already-current apps
- apps held by distro/repo
- failures

## 6. Add AppImage and manual install support

Status: done

Detect likely AppImages and manual installs in:

- `~/Applications`
- `~/Downloads`
- `~/.local/bin`
- `~/.local/opt`
- `/opt`

Add per-app handlers only when the update source is reliable.

## 7. Add safer system package reporting

Status: done

Before system upgrades, capture:

- packages that zypper plans to update
- whether reboot is recommended
- whether services need restart

Why: unattended system updates need good audit data.

## 8. Add Codex CLI auto-update handler

Status: done

Teach `bin/upgrade-apps` how to update the user-local Codex CLI entry with `codex update`.

Why: `Codex CLI` is currently the only tracked app marked manual.

## 9. Run a full real maintenance test

Status: done

Run `bin/weekly-maintenance` end to end after the new handlers are in place.

Why: the weekly path should be proven as one workflow, not just tested piece by piece.

## 10. Add richer notification details

Status: done

Include the most useful app names in the notification, not just counts:

- installable updates
- manual/unsupported apps
- newer-upstream-only apps

Why: the notification should be useful without immediately opening logs.

## 11. Add an HTML status dashboard

Status: done

Generate a local `status.html` from `apps.md`.

Why: a simple visual dashboard makes the app inventory easier to scan than a wide Markdown table.

## 12. Serve dashboard on localhost

Status: done

Serve the generated dashboard from a local-only web server at `http://127.0.0.1:8765/`.

Why: the dashboard should be easy to open in a browser without navigating into the project directory.

## 13. Make the project portable and GitHub-ready

Status: done

Add openSUSE dependency installation, one-command user service installation, optional root system-upgrade installation, uninstall support, example config/inventory templates, license, contribution notes, and path-portable scripts.

Why: the project should be cloneable on another Linux machine without hand-editing hardcoded paths.
