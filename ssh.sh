#!/usr/bin/env bash
set -e

# set 0600 permissions on config file
# (setting permissions on a symlink does nothing; see chmod(1))
chmod 0600 "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )/src/.ssh/config"

# prompt to create key if none exists
if [[ "$(find ~/.ssh -maxdepth 1 -type f -name '*.pub' | wc -l)" == 0 ]]; then
	echo 'No SSH keys found; creating one now.'
	ssh-keygen -t ed25519 -C 'nightfirecat@nightfirec.at'
fi