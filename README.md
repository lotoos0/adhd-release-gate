# ADHD Release Gate

A tiny workflow template to stop "almost done" projects from dying.

Runs tests, generates a deterministic demo proof, fingerprints it, appends a 3-line changelog entry, tags with a timestamp, and pushes — all via `make release`.

## 3 Rules

1. **One feature at a time** — `make feature` blocks new `feat:` commits until you `make release`
2. **Proof or nothing** — every release requires working demo saved to `artifacts/proof.txt` (<10s)
3. **Release from main** — `make release` works only from `main` branch with clean git status

## 7 Commands

```bash
# Initialize in new repo (idempotent)
make init

# Check system status (last tag, gate status, working tree)
make status

# Check if you can start new feature
make feature

# Run tests (default dummy, replace in scripts/test.sh)
make test

# Run demo (replace in scripts/demo.sh with your quick demo)
make demo

# Check gate without success message
make gate-check

# Make release: test → demo → fingerprint → changelog → tag → push
make release
```

## Exit Codes

- `0` — success
- `1` — tests failed
- `2` — gate blocked (unreleased feat commits)
- `3` — wrong branch (not main)
- `4` — dirty git or staged files
- `5` — demo failed
- `6` — push failed

## Quick Start

```bash
git clone <this-repo>
cd <your-project>
make init                    # creates structure
# Replace scripts/demo.sh with your quick demo
git add -A
git commit -m "feat: initial setup"
make release                 # first release
# From now on: make feature → work → make release
```
