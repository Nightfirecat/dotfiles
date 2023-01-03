#!/usr/bin/env bash
set -e

# don't build diff-highlight if it's already in PATH
if type diff-highlight >/dev/null 2>&1; then
	return
fi

REQUIRED_BUILD_FILES=(
	Makefile
	diff-highlight.perl
	DiffHighlight.pm
)

# create temp directory
pushd "$(mktemp -d)" >/dev/null

# fetch diff-highlight build files and build the binary
for file in "${REQUIRED_BUILD_FILES[@]}"; do
	curl -s -O "https://git.kernel.org/pub/scm/git/git.git/plain/contrib/diff-highlight/${file}"
done
make --quiet

# move the created script to ~/.bin, which is in PATH
mv diff-highlight ~/.bin

# remove the temp directory and move back to the previous directory
rm -rf "$(pwd)"
popd >/dev/null
