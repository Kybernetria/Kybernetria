#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
REMOTE="$TMP/remote.git"
SOURCE="$TMP/source"
REWRITER="$TMP/rewriter"

cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT HUP INT TERM

# Build a tiny isolated repository so the regression test never touches the
# working tree or remote configured for the project under test.
git init --bare "$REMOTE" >/dev/null
git init -b main "$SOURCE" >/dev/null
git -C "$SOURCE" config user.name "Deploy test"
git -C "$SOURCE" config user.email "deploy-test@example.invalid"
cat > "$SOURCE/package.json" <<'EOF'
{"scripts":{"build":"rm -rf dist && mkdir dist && printf 'generated site\\n' > dist/index.html"}}
EOF
cp "$ROOT/deploy.sh" "$SOURCE/deploy.sh"
chmod +x "$SOURCE/deploy.sh"
git -C "$SOURCE" add package.json deploy.sh
git -C "$SOURCE" commit -m "test fixture" >/dev/null
git -C "$SOURCE" remote add origin "$REMOTE"
git -C "$SOURCE" push -u origin main >/dev/null

# The first deploy creates the remote pages branch without retaining a local
# pages branch.
(
  cd "$SOURCE"
  ./deploy.sh
) >/dev/null
if git -C "$SOURCE" show-ref --verify --quiet refs/heads/pages; then
  echo "first deploy retained a local pages branch" >&2
  exit 1
fi

# Recreate the stale local branch that older deploy.sh versions used.
git -C "$SOURCE" branch pages refs/remotes/origin/pages

git clone "$REMOTE" "$REWRITER" >/dev/null
git -C "$REWRITER" config user.name "Deploy rewrite test"
git -C "$REWRITER" config user.email "deploy-rewrite-test@example.invalid"
git -C "$REWRITER" switch --orphan rewritten-pages >/dev/null
git -C "$REWRITER" rm -rf . >/dev/null 2>&1 || true
printf 'force-orphan rewrite\n' > "$REWRITER/index.html"
git -C "$REWRITER" add -A
git -C "$REWRITER" commit -m "force orphan pages rewrite" >/dev/null
git -C "$REWRITER" push --force origin HEAD:pages >/dev/null

# A second deploy must fetch the rewritten remote tip, not use the stale local
# pages branch. Its generated output should replace the rewrite.
(
  cd "$SOURCE"
  ./deploy.sh
) >/dev/null

REMOTE_CONTENT=$(git --git-dir="$REMOTE" show refs/heads/pages:index.html)
if [ "$REMOTE_CONTENT" != "generated site" ]; then
  echo "second deploy did not replace the force-orphan remote rewrite" >&2
  printf 'remote content: %s\n' "$REMOTE_CONTENT" >&2
  exit 1
fi

echo "deploy repeat/orphan rewrite regression: passed"
