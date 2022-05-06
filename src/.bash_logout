#!/bin/bash

# kill running ssh agent
if [ -n "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -k)"
fi
