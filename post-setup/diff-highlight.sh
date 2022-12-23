#!/usr/bin/env bash
set -e

# don't build diff-highlight if it's already in PATH
if type diff-highlight >/dev/null 2>&1; then
	return
fi

# create temp directory
pushd "$(mktemp -d)" >/dev/null

# copy the diff-highlight source files distributed with git to this temp
# directory and build it
cp -R --preserve=mode,timestamps "$(dpkg -L git | grep diff-highlight | head -1)"/* .
make --quiet

# move the created script to ~/.bin, which is in PATH
mv diff-highlight ~/.bin

# remove the temp directory and move back to the previous directory
rm -rf "$(pwd)"
popd >/dev/null
