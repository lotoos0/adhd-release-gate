#!/bin/bash
set -e

# Exit codes
EXIT_TESTS_FAILED=1
EXIT_WRONG_BRANCH=3
EXIT_DIRTY_GIT=4
EXIT_DEMO_FAILED=5
EXIT_PUSH_FAILED=6

# 1. Check branch
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
    echo "✗ Must be on main branch (currently: $BRANCH)"
    exit $EXIT_WRONG_BRANCH
fi

# 2. Check remote
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "✗ No 'origin' remote configured"
    exit $EXIT_PUSH_FAILED
fi

# 3. Run tests
echo "→ Running tests..."
make test || exit $EXIT_TESTS_FAILED

# 4. Run demo
echo "→ Running demo..."
make demo || exit $EXIT_DEMO_FAILED

# 5. Generate fingerprint
if [ ! -f artifacts/proof.txt ]; then
    echo "✗ Demo didn't create artifacts/proof.txt"
    exit $EXIT_DEMO_FAILED
fi
PROOF_HASH=$(sha256sum artifacts/proof.txt | awk '{print substr($1,1,8)}')

# 6. Check for staged files (before modifying anything)
STAGED_FILES=$(git diff --cached --name-only)
if [ -n "$STAGED_FILES" ]; then
    echo "✗ Staged files detected (clean index before release):"
    echo "$STAGED_FILES"
    exit $EXIT_DIRTY_GIT
fi

# 7. Append changelog
TAG=$(date +%Y%m%d-%H%M%S)
LAST_COMMIT=$(git log -1 --format=%s)
echo "$TAG | $LAST_COMMIT | proof:$PROOF_HASH" >> CHANGELOG.md

# 8. Commit changelog
git add CHANGELOG.md
if ! git diff --cached --quiet; then
    git commit -m "release: $TAG"
fi

# 9. Check clean
if [ -n "$(git status --porcelain)" ]; then
    echo "✗ Dirty git status after commit"
    exit $EXIT_DIRTY_GIT
fi

# 10. Tag
git tag "$TAG"

# 11. Push
echo "→ Pushing to origin..."
git push origin main --tags || exit $EXIT_PUSH_FAILED

echo "✓ Released: $TAG"
echo "  Proof: $PROOF_HASH"
