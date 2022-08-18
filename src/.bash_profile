#!/bin/bash

### environment vars
# Ensure $HOME/.bin exists, add it to PATH
mkdir -vp "$HOME/.bin"
export PATH="${PATH}:$HOME/.bin"

# some programs (pip, notably) install into ~/.local/bin, add that to PATH too
export PATH="${PATH}:$HOME/.local/bin"

# bash options
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=5000

# XDG
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="/run/user/$UID"

# x settings
export GTK_IM_MODULE="xim"  # use x input method for GTK apps

# Default editor
hash vim >/dev/null 2>&1 && export EDITOR='vim' VISUAL='vim'

# Pager and man pager
if hash less >/dev/null 2>&1; then
	# set sensible default for less
	export LESS='-R'

	# Enhanced man pages
	export MANPAGER='less -R -s -M'

	if [ "$(less -V | head -n 1 | cut -f 2 -d' ' )" -ge 580 ]; then
		export MANPAGER="${MANPAGER} --use-color -Dd+r -Du+b"
	else
		# Add man page colors
		# Sourced from: https://unix.stackexchange.com/a/329092/136537
		export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
		export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
		export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
		export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
		export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
		export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
		export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
		export GROFF_NO_SGR=1                  # for konsole and gnome-terminal
	fi
fi

# Maven
export JAVA_HOME=/lib/jvm/default-java
export PATH="${PATH}:/opt/maven/bin"

# JShell
export CLASSPATH="/opt/libs/commons-lang3-3.7.jar:/opt/libs/guava-23.2-jre.jar"

# rg config
export RIPGREP_CONFIG_PATH="$HOME"/.ripgreprc

# shell check config
export SHELLCHECK_OPTS='--color'

### commands
# Start SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)"
fi

# if running interactively, source .bashrc
[ -n "$PS1" ] && source "$HOME/.bashrc"
