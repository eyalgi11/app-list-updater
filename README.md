# App List Updater

AI-native Linux app maintenance for openSUSE workstations.

The project discovers installed user-facing apps, keeps a Markdown inventory, runs supported unattended updates, sends a desktop notification, and serves a local dashboard at `http://127.0.0.1:8765/`.

The main supported target is openSUSE Leap/Tumbleweed. Other Linux systems may work for discovery, but dependency installation and RPM updates are openSUSE-focused.

## Quick Install

Clone the repo, install dependencies, and enable the user services:

```bash
git clone <repo-url> ~/projects/app-list-updater
cd ~/projects/app-list-updater
scripts/install --deps
```

Open the dashboard:

```text
http://127.0.0.1:8765/
```

Optional root system package updates:

```bash
scripts/install --with-system-upgrades
```

That installs a root timer that runs `bin/upgrade-apps` with `AUTO_UPGRADE_SYSTEM=1`. Leave this off if you only want user-local apps and Flatpaks updated automatically.

Uninstall services without deleting project files:

```bash
scripts/uninstall
scripts/uninstall --system-upgrades
```

## Requirements

Install openSUSE dependencies manually:

```bash
scripts/install-deps-opensuse
```

Core dependencies:

- `bash`, `coreutils`, `findutils`, `gawk`, `util-linux`
- `git`
- `make`
- `curl`, `tar`, `bzip2`, `file`
- `python3`
- `systemd`
- `rpm`, `zypper`, `sudo`
- `flatpak`
- optional: `kdialog` for KDE desktop notifications
- Codex CLI available as `codex` on `PATH`, or set `CODEX_BIN=/path/to/codex`

## Local State

These files are intentionally machine-local and ignored by git:

- `apps.md`
- `config.env`
- `logs/`
- `tmp/`
- `status.html`
- `index.html`

Fresh installs copy:

- `apps.example.md` to `apps.md`
- `config.example.env` to `config.env`

## Files

- `apps.md` is Codex's local app inventory.
- `apps.example.md` is the starter inventory template.
- `ROADMAP.md` tracks planned improvements and the current implementation focus.
- `prompts/update-app-list.md` is the job prompt sent to `codex exec`.
- `bin/collect-installed-apps` builds the runtime discovery snapshot from launchers, local installs, PATH commands, Flatpak, Snap, and RPM metadata.
- `config.env` controls unattended upgrade policy.
- `bin/update-app-list` runs the AI discovery/check job and writes logs.
- `bin/upgrade-apps` performs supported unattended upgrades after the AI check.
- `bin/weekly-maintenance` runs discovery/check, upgrades, then discovery/check again.
- `bin/status` summarizes timers, tracked apps, outdated state, and latest logs.
- `bin/last-run` shows the latest update/upgrade/final log.
- `bin/notify-maintenance` sends a desktop notification after weekly maintenance, with a log fallback.
- `bin/generate-dashboard` writes `status.html` from `apps.md`.
- `bin/serve-dashboard` serves the dashboard at `http://127.0.0.1:8765/`.
- `scripts/install-deps-opensuse` installs OS packages.
- `scripts/install` renders and enables systemd services.
- `scripts/uninstall` disables/removes installed services.
- `systemd/app-list-updater.service` and `systemd/app-list-updater.timer` run it weekly.
- `systemd/*.service` files are templates rendered by `scripts/install`; do not copy them directly without replacing `@PROJECT_DIR@` and `@USER_HOME@`.

## Run Manually

```bash
cd ~/projects/app-list-updater
bin/update-app-list
```

Run the full weekly flow:

```bash
bin/weekly-maintenance
```

Run only supported upgrades:

```bash
bin/upgrade-apps
```

Check status:

```bash
bin/status
bin/last-run
bin/last-run update
bin/last-run upgrade
```

Send a test notification:

```bash
bin/notify-maintenance success
```

Generate the HTML dashboard:

```bash
bin/generate-dashboard
```

Serve the dashboard on localhost:

```bash
bin/serve-dashboard
```

When the user service is enabled, open:

```text
http://127.0.0.1:8765/
```

To see the exact command without running Codex:

```bash
bin/update-app-list --dry-run
```

## Weekly Schedule

The timer is configured for Mondays at 09:00 local time, with a randomized delay of up to 30 minutes.

Useful commands:

```bash
systemctl --user status app-list-updater.timer
systemctl --user list-timers app-list-updater.timer
journalctl --user -u app-list-updater.service
```

## Dashboard Server

The dashboard server binds only to localhost and serves the project directory at:

```text
http://127.0.0.1:8765/
```

Install and enable it as a user service:

```bash
scripts/install --no-timer
```

## AI-Native Discovery

You do not need to add apps by hand. Each run gives Codex a fresh local discovery snapshot, and Codex decides which user-facing apps should be added to `apps.md`.

Manual edits are still fine when you want to correct a source URL or add a note, but the normal path is: install apps normally, then let the weekly job discover and track them.

Each app row includes install/update metadata:

- `Install Type`: where the app came from, such as `rpm`, `flatpak`, or `user-local`
- `Update Method`: which updater owns it, such as `zypper`, `flatpak`, or `custom-waterfox`
- `Auto Update`: whether this project currently updates it unattended
- `Current Version`: what is installed now
- `Repo Version`: what the configured package manager can install
- `Upstream Version`: what the vendor/project has released upstream

The discovery snapshot also looks for AppImages and manual executables in:

- `~/Applications`
- `~/Downloads`
- `~/.local/bin`
- `~/.local/opt`
- `/opt`

These are tracked as `appimage` or `user-local` only when they look like real user-facing apps. They default to `Update Method: manual` and `Auto Update: no` until a reliable per-app handler exists.

## Unattended Upgrades

The weekly timer now runs `bin/weekly-maintenance`, which checks the app list and then runs `bin/upgrade-apps`.

The full flow is:

```text
pre-upgrade AI inventory check
supported unattended upgrades
post-upgrade AI inventory re-check
generate HTML dashboard
```

The second check updates `Current Version` after successful user-local or Flatpak upgrades in the same run.

After the flow completes, the user-level job sends a desktop notification summarizing tracked apps, installable updates, newer-upstream-only apps, and unsupported/manual apps. Notification attempts are also logged to `logs/notifications.log`.

Supported unattended upgrade paths:

- Waterfox installed in `~/.local/opt/waterfox`
- Flatpak apps, if any are installed
- openSUSE RPM packages through `zypper`, only when `AUTO_UPGRADE_SYSTEM=1` and the script is run as root or with passwordless sudo for the exact zypper command

The default policy upgrades user-local apps and Flatpaks, but does not mutate system RPM packages as an unprivileged user.

When system RPM upgrades are enabled, `bin/upgrade-apps` writes extra audit logs:

- `logs/system-upgrade-plan-*.log`: zypper dry-run with details before changes
- `logs/system-upgrade-result-*.log`: zypper result with details
- `logs/system-upgrade-health-*.log`: reboot and service-restart hints after changes

## Development

Run local checks:

```bash
make test
```

Run an openSUSE container portability test:

```bash
scripts/test-portable-docker
```

This clones the public GitHub repo inside a fresh openSUSE container, installs required packages, runs `make test`, and verifies first-run local state creation.

Initialize a repository:

```bash
git init
git add .
git status
```

Because live inventory and policy files are ignored, commit the example templates instead of `apps.md` or `config.env`.
