#!/bin/sh
set -e
# Local-only deploy: build here, then sync dist/ to the GitHub Pages branch.

BRANCH="pages"
DEPLOY_DIR=$(mktemp -d)

TEMP_BRANCH=""

cleanup() {
  cd "$(git rev-parse --show-toplevel)"
  git worktree remove --force "$DEPLOY_DIR" 2>/dev/null || true
  if [ -n "$TEMP_BRANCH" ]; then
    git branch -D "$TEMP_BRANCH" >/dev/null 2>&1 || true
  fi
  rm -rf "$DEPLOY_DIR"
}
trap cleanup EXIT

echo "🔨  Building site..."
npm run build

git fetch origin --prune

echo "🌿  Preparing '$BRANCH' branch..."

# Always deploy from the freshly fetched remote branch. A local pages branch may
# be stale after the remote branch is rewritten, so it must not be used here.
REMOTE_EXISTS=$(git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo yes || echo no)

if [ "$REMOTE_EXISTS" = "yes" ]; then
  git worktree add --detach "$DEPLOY_DIR" "origin/$BRANCH"
else
  # First deploy — create a temporary orphan branch (requires Git >= 2.36).
  # The branch is removed by cleanup so pages is never retained locally.
  echo "  No '$BRANCH' branch found, creating orphan..."
  TEMP_BRANCH_CANDIDATE="deploy-$BRANCH-$$"
  git worktree add --orphan -b "$TEMP_BRANCH_CANDIDATE" "$DEPLOY_DIR"
  TEMP_BRANCH="$TEMP_BRANCH_CANDIDATE"
fi

echo "📦  Copying dist/ to deploy worktree..."
# Wipe everything except the .git reference file that worktree needs
find "$DEPLOY_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
cp -r dist/. "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"
git add -A

if git diff --cached --quiet; then
  echo "✅  Nothing new to deploy — already up to date."
else
  git commit -m "deploy: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "🚀  Pushing to origin/$BRANCH..."
  # Push the detached/temp commit without force so concurrent remote changes are
  # rejected rather than overwritten.
  git push origin "HEAD:$BRANCH"
  echo "✅  Deployed! Your site is live on the '$BRANCH' branch."
fi
