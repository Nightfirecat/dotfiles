#!/usr/bin/env bash
set -e

# don't require ssh key setup if user is root
if [ "$EUID" -eq 0 ]; then
	return
fi

# set 0600 permissions on config file
# (setting permissions on a symlink does nothing; see chmod(1))
chmod 0600 "${DIR}/src/.ssh/config"

# prompt to create key if none exists
if [[ "$(find ~/.ssh -maxdepth 1 -type f -name '*.pub' | wc -l)" == 0 ]]; then
	echo 'No SSH keys found; creating one now.'
	ssh-keygen -t ed25519 -C 'nightfirecat@nightfirec.at'
fi
