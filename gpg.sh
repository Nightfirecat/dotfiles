#!/usr/bin/env bash
set -e

# don't require gpg key setup if user is root
if [ "$EUID" -eq 0 ]; then
	return
fi

# prompt to create key if none exists
if [[ "$(find ~/.gnupg -maxdepth 2 -type f -wholename '*private-keys-v1.d/*.key' | wc -l)" == 0 ]]; then
	echo 'No GPG keys found; creating one now.'
	echo 'Using 4096 bit size is recommended for this setup.'
	gpg --full-generate-key
fi
