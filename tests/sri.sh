#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CMS_INDEX="$ROOT/public/admin/index.html"
EXPECTED_SRC='https://unpkg.com/@sveltia/cms@0.188.0/dist/sveltia-cms.js'
EXPECTED_INTEGRITY='sha384-4RRqZDvLaOSWvmgekxgQ+js7AmU5sxNh9T74t4xl6CYqD5GHQ7JLGPuG/ZkIk3hN'

src=$(sed -n 's/.*src="\([^"]*sveltia-cms\.js\)".*/\1/p' "$CMS_INDEX")
integrity=$(sed -n 's/.*integrity="\([^"]*\)".*/\1/p' "$CMS_INDEX")

if [ "$src" != "$EXPECTED_SRC" ]; then
  printf '%s\n' "Sveltia CMS URL is not pinned to 0.188.0" >&2
  exit 1
fi

case "$integrity" in
  sha384-*)
    digest=${integrity#sha384-}
    ;;
  *)
    printf '%s\n' "Sveltia CMS integrity must use sha384" >&2
    exit 1
    ;;
esac

if [ "${#digest}" -ne 64 ]; then
  printf '%s\n' "Sveltia CMS SHA-384 digest must be exactly 64 Base64 characters" >&2
  exit 1
fi

if [ "$integrity" != "$EXPECTED_INTEGRITY" ]; then
  printf '%s\n' "Sveltia CMS integrity digest does not match the verified asset" >&2
  exit 1
fi

printf '%s\n' "Sveltia CMS SRI validation: passed"
