.PHONY: init test demo gate-check feature release

init:
	@mkdir -p artifacts scripts
	@touch .gitignore
	@grep -qxF "artifacts/" .gitignore || echo "artifacts/" >> .gitignore
	@[ -f CHANGELOG.md ] || echo "# Release Log" > CHANGELOG.md
	@if [ ! -f scripts/test.sh ]; then \
		printf '#!/bin/bash\n# Replace with real tests\necho "Running tests..."\nexit 0\n' > scripts/test.sh; \
	fi
	@if [ ! -f scripts/demo.sh ]; then \
		printf '#!/bin/bash\n# PROJECT-SPECIFIC: Replace this\necho "=== DEMO ===" > artifacts/proof.txt\necho "Demo complete"\nexit 0\n' > scripts/demo.sh; \
	fi
	@chmod +x scripts/test.sh scripts/demo.sh scripts/release.sh 2>/dev/null || true
	@echo "✓ Initialized (idempotent)"

test:
	@bash scripts/test.sh || exit 1

demo:
	@bash scripts/demo.sh || exit 5

gate-check:
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	if [ -z "$$LAST_TAG" ]; then \
		FEAT_COUNT=$$(git log --oneline --grep="^feat:" | wc -l | tr -d '[:space:]'); \
		if [ $$FEAT_COUNT -gt 0 ]; then \
			echo "✗ Gate blocked: $$FEAT_COUNT feat commits, no releases yet"; \
			echo "  Run 'make release' to create first release"; \
			exit 2; \
		fi; \
		exit 0; \
	fi; \
	FEAT_COUNT=$$(git log $$LAST_TAG..HEAD --oneline --grep="^feat:" | wc -l | tr -d '[:space:]'); \
	if [ $$FEAT_COUNT -gt 0 ]; then \
		echo "✗ Gate blocked: $$FEAT_COUNT feat commits since $$LAST_TAG"; \
		echo "  Run 'make release' first"; \
		exit 2; \
	fi; \
	exit 0

feature:
	@make gate-check && echo "✓ OK to start new slice"

release:
	@bash scripts/release.sh
