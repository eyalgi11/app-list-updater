PREFIX ?= /usr/local

.PHONY: install deps uninstall status dashboard test test-docker

install:
	./scripts/install

deps:
	./scripts/install-deps-opensuse

uninstall:
	./scripts/uninstall

status:
	./bin/status

dashboard:
	./bin/serve-dashboard

test:
	test -f apps.md || cp apps.example.md apps.md
	find bin scripts -type f -exec bash -n {} \;
	./bin/generate-dashboard >/dev/null
	./bin/weekly-maintenance --dry-run >/dev/null

test-docker:
	./scripts/test-portable-docker
