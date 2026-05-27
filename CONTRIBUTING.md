# Contributing

This project is intentionally shell-first so it can run on a plain openSUSE workstation.

Before sending changes, run:

```bash
make test
```

Keep scripts portable across user home directories and clone paths:

- Do not hardcode `/home/<user>` or a fixed project directory.
- Prefer `APP_LIST_UPDATER_DIR`, `APP_LIST_USER_HOME`, or paths derived from the script location.
- Keep systemd units templated with `@PROJECT_DIR@` and `@USER_HOME@`; `scripts/install` renders them.
- Treat `apps.md`, `config.env`, logs, locks, and generated dashboards as local state.

The main supported target is openSUSE. Other Linux distributions may work, but dependency installation and RPM/zypper handling are openSUSE-focused.
