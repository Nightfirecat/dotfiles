#!/usr/bin/env bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# source global definitions (if any)
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# source x mod map (if any)
[ -f ~/.Xmodmap ] && type xmodmap >/dev/null 2>/dev/null && xmodmap ~/.Xmodmap


### shell options
# set shell options
set -o ignoreeof        # prevent Ctrl+D from exiting terminal
shopt -s cdspell        # allow minor misspellings in `cd` commands
shopt -s checkhash      # reference command hash table for executables
shopt -s checkwinsize   # update LINES and COLUMNS after each command
shopt -s cmdhist        # save all lines of multiline commands to history
shopt -s dotglob        # allow globing filenames beginning with '.'
shopt -s expand_aliases # use bash aliases
shopt -s extglob        # use pattern matching features (ref `man bash`)
shopt -s histappend     # append to history file instead of overwriting
shopt -s histreedit     # allow user to re-edit failed history appending
shopt -s histverify     # edit recalled history line before executing
shopt -s hostcomplete   # attempt hostname completion on word containing '@'
shopt -s lithist        # save multiline commands to history with embedded \n
shopt -s nocaseglob     # use case insensitive globs on filename expansion
shopt -s progcomp       # use bash programmable completion
shopt -s promptvars     # expand vars in prompt
shopt -s shift_verbose  # print error if shifting out of bounds
shopt -s sourcepath     # reference PATH to find executables

# unset shell options
shopt -u mailwarn       # don't spam mail read notifications
shopt -u nullglob       # `ls nonexist/*` should fail, not act like `ls`


### define colors
# Normal colors
export COLOR_Black='\e[0;30m'
export COLOR_Red='\e[0;31m'
export COLOR_Green='\e[0;32m'
export COLOR_Yellow='\e[0;33m'
export COLOR_Blue='\e[0;34m'
export COLOR_Purple='\e[0;35m'
export COLOR_Cyan='\e[0;36m'
export COLOR_White='\e[0;37m'

# Bright
export COLOR_BBlack='\e[1;30m'
export COLOR_BRed='\e[1;31m'
export COLOR_BGreen='\e[1;32m'
export COLOR_BYellow='\e[1;33m'
export COLOR_BBlue='\e[1;34m'
export COLOR_BPurple='\e[1;35m'
export COLOR_BCyan='\e[1;36m'
export COLOR_BWhite='\e[1;37m'

# Background
export COLOR_On_Black='\e[40m'
export COLOR_On_Red='\e[41m'
export COLOR_On_Green='\e[42m'
export COLOR_On_Yellow='\e[43m'
export COLOR_On_Blue='\e[44m'
export COLOR_On_Purple='\e[45m'
export COLOR_On_Cyan='\e[46m'
export COLOR_On_White='\e[47m'

# Color Reset
export COLOR_NC='\e[m'

# Alert color (bright white on red)
export COLOR_ALERT="${COLOR_BWhite}${COLOR_On_Red}"


### aliases
# sensible defaults
alias sudo='sudo '                   # allow sudo to execute aliases
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias df='df -Th'
alias mkdir='mkdir -pv'
alias less='less -R'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff -uNr --color=always'
alias ip='ip --color=auto'
alias tree='tree -Csuh'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias nohup='nohup >/dev/null &>/dev/null'

# simple shortcuts
alias aliases='alias -p'
alias -- -='cd -'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias more='less'
alias path='echo -e ${PATH//:/\\n}'  # print $PATH dirs on separate lines
alias now='date +"%T"'
alias nowtime='now'
alias nowdate='date +"%y-%m-%d"'
alias isodate='date -I'
alias isotime='date -Ihours'
alias headers='curl -I'              # get site headers
alias headersc='curl -I --compress'  # test gzip/mod_deflate support
alias auu='sudo apt update && sudo apt upgrade'

# add colors for filetype and human-readable sizes in `ls`
alias ls='ls -h --color --show-control-chars'
alias lx='ls -lXB'   # sort by extension
alias lk='ls -lSr'   # sort by date, newest first
alias lt='ls -ltr'   # sort by date, newest last
alias lc='ls -ltcr'  # sort by/show change time, most recent last
alias lu='ls -ltur'  # sort by/show access time, most recent last

# add `ll` and derivatives
alias ll='ls -lv --group-directories-first'
alias lm='ll | more'
alias lr='ll -R'
alias la='ll -A'


### functions
## private functions (internal use only)
# only performs `ssh-add` on files in ~/.ssh/ which have a header indicating
# they are SSH keys, and which are not loaded in the agent
function _bashrc_ssh-add-keys {
	if ! [ -d ~/.ssh ]; then
		return
	fi

	if ! grep -E -q -- '-BEGIN (OPENSSH|RSA) PRIVATE KEY-' ~/.ssh/*; then
		return
	fi

	local loaded_idents file

	loaded_idents="$(ssh-add -l)"
	for file in ~/.ssh/*; do
		if [ -f "$file" ] && \
		grep -E -q -- '-BEGIN (OPENSSH|RSA) PRIVATE KEY-' "$file" && \
		! grep -q "$(ssh-keygen -lf "${file}.pub" | sed -E -e 's/^.+\b([^ ]+:[^ ]+)\b.+$/\1/' | tr -d '\n')" <<< "$loaded_idents";
		then
			ssh-add "$file"
		fi
	done
}

# test colors available in the terminal
# source: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
function _bashrc_colortest {
	local T FGs FG BG
	T='gYw'  # test text

	echo -e '\n                 40m     41m     42m     43m' \
	        '    44m     45m     46m     47m';

	for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' \
	           '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' \
	           '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
		do FG=${FGs// /}
		echo -en " $FGs \\033[$FG  $T  "
		for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
			do echo -en "$EINS \\033[$FG\\033[$BG  $T  \\033[0m";
		done
		echo
	done
	echo
}

# attempts to navigate to the passed path and print its canonical path
# (similar to `cd -`)
function _bashrc_.cd {
	if cd "$1"; then
		readlink -f .
	fi
}

# prints given elements in $2 ... joined by the string in $1
function _bashrc_join_by {
	if [ $# -lt 2 ]; then return 1; fi

	local d

	d="$1"
	shift
	echo -n "$1"
	shift
	printf '%s' "${@/#/$d}"
}

# prints a human-readable time from a passed number of epoch seconds
function _bashrc_displaytime {
	[ $# -ne 1 ] && echo "${FUNCNAME[0]}: 1 argument needed" >&2 && return 1

	local T D H M S
	T="$1"
	D=$((T/60/60/24))
	H=$((T/60/60%24))
	M=$((T/60%60))
	S=$((T%60))
	[ "$D" -gt 0 ] &&
		echo -n "${D}d "
	{ [ "$D" -gt 0 ] || [ "$H" -gt 0 ]; } &&
		printf '%02.0fh ' "$H"
	{ [ "$D" -gt 0 ] || [ "$H" -gt 0 ] || [ "$M" -gt 0 ]; } &&
		printf '%02.0fm ' "$M"
	printf '%02.0fs' "$S"
}

# prints the code for a random color readable on a black background shell
# omits COLOR_White as it is indistinguishable from default color
function _bashrc_randomcolor {
	local colors random_index
	colors=(
		# "$COLOR_Black" # cannot be read on black bg
		"$COLOR_Red"
		"$COLOR_Green"
		"$COLOR_Yellow"
		# "$COLOR_Blue" # very hard to read on black bg
		"$COLOR_Purple"
		"$COLOR_Cyan"
		# "$COLOR_White" # indistinguishable from default color
		"$COLOR_BRed"
		"$COLOR_BGreen"
		"$COLOR_BYellow"
		"$COLOR_BBlue"
		"$COLOR_BPurple"
		"$COLOR_BCyan"
		"$COLOR_BWhite"
	)
	random_index="$(shuf -i 1-"${#colors[@]}" -n 1)"
	random_index=$(( random_index - 1 ))
	echo -e "${colors[$random_index]}"
}

# prints a message of the day (time, shell info, system info, etc.)
function _bashrc_motd {
	if type neofetch >/dev/null 2>/dev/null; then
		neofetch --config ~/.neofetch.config.conf 2>/dev/null
		return
	fi

	local kernel_string uptime_seconds uptime_msg cpuinfo cpu_model cpu_cores \
	      cpu_msg k mem_decimals mem_units mem_label mem_percent_free \
	      mem_danger_cutoff_limit mem_danger_cutoff_percent \
	      mem_warning_cutoff_limit mem_warning_cutoff_percent mem_free_color \
	      mem_msg
	local -A memory

	# Print shell info
	echo -e "$(_bashrc_randomcolor)This is BASH" \
	        "$(_bashrc_randomcolor)${BASH_VERSION%.*}${COLOR_NC}"
	kernel_string="$(
		(
			uname -s
			uname -r
			uname -m
			uname -o
		) | tr "\\n" ' '
	)"
	echo -e "This kernel is: $(_bashrc_randomcolor)${kernel_string}${COLOR_NC}"

	# Print date and uptime
	echo -e "It's $(_bashrc_randomcolor)$(date)${COLOR_NC}"
	uptime_seconds="$(cut -d '.' -f 1 < /proc/uptime)"
	uptime_msg="This machine has been up for $(_bashrc_randomcolor)"
	uptime_msg+="$(_bashrc_displaytime "$uptime_seconds")${COLOR_NC}"
	echo -e "$uptime_msg"
	echo

	# Print CPU, memory, and HDD info
	cpuinfo="$(cat /proc/cpuinfo)"
	cpu_model="$(
		grep -m 1 'model name' <<< "$cpuinfo" |
		cut -d ':' -f 2 |
		sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
	)"
	cpu_cores="$(
		grep -m 1 'cpu cores' <<< "$cpuinfo" |
		cut -d ':' -f 2 |
		sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
	)"
	cpu_msg="CPU: $(_bashrc_randomcolor)${cpu_model} ${cpu_cores}-core processor"
	cpu_msg+="${COLOR_NC}"
	echo -e "$cpu_msg"
	memory['free']='MemFree'
	memory['total']='MemTotal'
	for k in "${!memory[@]}"; do
		memory["$k"]="$(
			grep "${memory["$k"]}" < /proc/meminfo |
			sed -r -e 's/^.+ ([[:digit:]]+).+$/\1/'
		)"
		(( memory["$k"] *= 1024 ))
	done
	# Determine memory divisor by available memory
	mem_decimals=2
	if [ "${memory['free']}" -gt $(( 1024 * 1024 * 1024 )) ]; then
		mem_units=$(( 1024 * 1024 * 1024 ))
		mem_label='GiB'
	elif [ "${memory['free']}" -gt $(( 1024 * 1024 )) ]; then
		mem_units=$(( 1024 * 1024 ))
		mem_label='MiB'
	elif [ "${memory['free']}" -gt 1024 ]; then
		mem_decimals=1
		mem_units=1024
		mem_label='KiB'
	else
		mem_decimals=0
		mem_units=1
		mem_label='B'
	fi
	# Determine memory "safety" by comparing available-to-total memory
	# and by the following hard cutoffs for available memory:
	#  - available < 100mb or available / total < 0.1 :: danger
	#  - 100mb < available < 300mb or available / total < 0.3 :: warning
	mem_percent_free="$(
		awk -v free="${memory['free']}" -v total="${memory['total']}" \
			'BEGIN { print free / total }'
	)"
	mem_danger_cutoff_limit="$(( 100 * 1024 * 1024 ))"
	mem_danger_cutoff_percent='0.1'
	mem_warning_cutoff_limit="$(( 300 * 1024 * 1024 ))"
	mem_warning_cutoff_percent='0.3'
	if (
		[ "${memory['free']}" -lt "$mem_danger_cutoff_limit" ] ||
		echo "$mem_percent_free" "$mem_danger_cutoff_percent" | \
			awk '{exit $1 < $2 ? 0 : 1}'
	); then
		mem_free_color="${COLOR_BRed}"
	elif (
		[ "${memory['free']}" -lt "$mem_warning_cutoff_limit" ] ||
		echo "$mem_percent_free" "$mem_warning_cutoff_percent" | \
			awk '{exit $1 < $2 ? 0 : 1}'
	); then
		mem_free_color="${COLOR_BYellow}"
	else
		mem_free_color="${COLOR_BGreen}"
	fi
	# Format memory display
	for k in "${!memory[@]}"; do
		memory["$k"]="$(
			awk -v m="${memory["$k"]}" -v u="$mem_units" -v d="$mem_decimals" \
				'BEGIN { printf "%.*f", d, m / u }'
		)"
	done
	mem_msg="Memory: ${mem_free_color}${memory['free']}${COLOR_NC}/"
	mem_msg+="${COLOR_BWhite}${memory['total']}${COLOR_NC} ${mem_label} available"
	echo -e "$mem_msg"
	echo 'HDDs:'
	echo -en "$(_bashrc_randomcolor)" &&
		df -mh \
		--type=btrfs \
		--type=ext4 \
		--type=ext3 \
		--type=ext2 \
		--type=vfat \
		--type=tiso9660 \
		--type=xfs \
		--type=fuseblk \
		--type=ntfs \
		&&
		echo -en "${COLOR_NC}"
	echo
}

# returns completion items for .* functions
# notably returns files/dirs in parent directories from PWD
function _bashrc_.complete {
	local cmd word
	cmd="$1"
	word=${COMP_WORDS[COMP_CWORD]}

	if ! grep -q -E '^\.[.1-9]$' <<< "$cmd"; then
		echo "${FUNCNAME[0]}: parent function must match '.[.1-9]'"
		return 1
	fi

	COMPREPLY=()

	# don't try to find matches if the search term starts with '/'
	if [[ "${word:0:1}" == '/' ]]; then
		return
	fi

	local parent_depth path_array i IGNORE_CASE search_path search_term \
	      search_word matched_words matched_word
	parent_depth="${cmd//.}"
	if [ -z "$parent_depth" ]; then
		parent_depth=1
	fi
	path_array=()
	for (( i=0; i<parent_depth; i++ )); do
		path_array+=( '..' )
	done

	# don't append a space to completed words
	compopt -o nospace

	# save configured value of readline's completion-ignore-case value to match
	# behavior
	IGNORE_CASE=( "$(
		bind -V |
		grep 'completion-ignore-case' |
		grep -q "\`on'$" &&
			echo '-i'
	)" )

	# search_path and search_term store the currently-searched path and
	# remaining search term from the original search word, after traversing into
	# directories. Eg. `.. foo/bar/baz`
	search_path="$(_bashrc_join_by '/' "${path_array[@]}")"
	search_term="$word"
	while # do-while loop
		# search_word refers to the string/directory to search for in the
		# current directory, eg. `foo/`, `bar/`, or `baz`
		search_word="$(sed -r -e 's|^([^/]+/?).*$|\1|' <<< "$search_term")"
		# directories matching the search word
		matched_words=()
		while IFS='' read -r matched_word; do
			# this loop is executed once with an empty string value even if
			# `find` yields no results; it's not a valid entry, so skip it
			if [[ -z "$matched_word" ]]; then
				continue
			fi

			# add found directory as a match if the search word is present as a
			# prefix of it
			if grep -q -E "${IGNORE_CASE[@]}" "/${search_word}[^/]*/?$" <<< "${matched_word}/"; then
				matched_words+=( "$matched_word/" )
			fi
		done <<< "$(find "$search_path" -mindepth 1 -maxdepth 1 -type d | sort -V)"

		# continue searching through the next nested directory if only one
		# result was found (assumed to be exact result) and the remaining search
		# term has more directories to search through
		if [[ "${#matched_words[@]}" == 1 && "$search_term" == */* ]]; then
			search_path="${matched_words[0]}"
			search_term="$(cut -d '/' -f 2- <<< "$search_term")"
			continue
		fi

		for matched_word in "${matched_words[@]}"; do
			# transform each line in the following manner:
			#  1. remove all leading `../` so the file or directory appears as
			#     it would from the parent path
			#  2. escape ` ` as would be needed to prevent argument splitting in
			#     the shell
			COMPREPLY+=( "$(sed -e 's|^\(../\)*||' -e 's| |\\ |g' <<< "$matched_word")" )
		done
	do break; done
}

# Prints color sequence according to the token type passed
# Prints red if user is root
function _ps1_color {
	if [ $# -ne 1 ]; then return; fi
	local color

	if [ "$1" = 'prompt' ]; then
		# process this before root check so typed text is not colored
		color="${COLOR_NC}"
	elif [ "$EUID" -eq 0 ]; then
		# this user is root, color the ps1 red!
		color="${COLOR_Red}"
	else
		case "$1" in
			bracket)
				color="${COLOR_White}"
				;;
			user|host)
				# use different color if SSH_CLIENT var is set
				if [[ -n "$SSH_CLIENT" ]]; then
					color="${COLOR_Blue}"
				else
					color="${COLOR_Green}"
				fi
				;;
			path)
				color="${COLOR_Yellow}"
				;;
			branch)
				color="${COLOR_Cyan}"
				;;
			preprompt)
				color="${COLOR_White}"
				;;
			\@)
				color="${COLOR_Red}"
				;;
			*)
				color="${COLOR_NC}"
				;;
		esac
	fi
	echo -e "$color"
}

# history appender
function _bashrc_prompt_command {
	# append last command to history
	history -a
}

# exit function
# source: http://tldp.org/LDP/abs/html/sample-bashrc.html
function _bashrc_exit {
	echo -e "$(_bashrc_randomcolor)Bye!${COLOR_NC}"
	sleep 0.5
}
trap _bashrc_exit EXIT


## public functions (intended for termial use)
# find a file with a pattern in its name
# source: http:/tldp.org/LDP/abs/html/sample-bashrc.html
function ff {
	find . -type f -iname '*'"$*"'*' -ls ;
}

# simple extract script
# source: http://tldp.org/LDP/abs/html/sample-bashrc.html
function extract {
	for arg in "$@"; do
		if [ -f "$arg" ]; then
			dir="${arg%%.*}"
			mkdir "$dir"
			case "$arg" in
				*.tar.bz2)  tar xvjf "$arg" -C "$dir"              ;;
				*.tar.gz)   tar xvzf "$arg" -C "$dir"              ;;
				*.tar.xz)   tar xJf "$arg" -C "$dir"               ;;
				*.rar)      unrar x "$arg" "$dir"                  ;;
				*.tar)      tar xvf "$arg" -C "$dir"               ;;
				*.tbz2)     tar xvjf "$arg" -C "$dir"              ;;
				*.tgz)      tar xvzf "$arg" -C "$dir"              ;;
				*.zip)      unzip "$arg" -d "$dir"                 ;;
				*.7z)       7z x "$arg" -o"$dir"                   ;;
				*.bz2)      bunzip2 -ck "$arg" > "$dir/${arg%.*}"  ;;
				*.gz|*.Z)   gunzip -ck "$arg" > "$dir/${arg%.*}"   ;;
				*.xz)       unxz -ck "$arg" > "$dir/${arg%.*}"     ;;
				*)          echo "'$arg' cannot be extracted "\
				                 "via >${FUNCNAME[0]}<"            ;;
			esac
		else
			echo "'$arg' is not a valid file!"
		fi
	done
}

# functions for fast traversal through parent directories
# each processes at most one parameter containing the path to traverse
# after going up N levels, where N is the number in the function name
function .. {
	.1 "$1"
}

function .1 {
	local prepend_path
	prepend_path=..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .2 {
	local prepend_path
	prepend_path=../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .3 {
	local prepend_path
	prepend_path=../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .4 {
	local prepend_path
	prepend_path=../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .5 {
	local prepend_path
	prepend_path=../../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .6 {
	local prepend_path
	prepend_path=../../../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .7 {
	local prepend_path
	prepend_path=../../../../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .8 {
	local prepend_path
	prepend_path=../../../../../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}

function .9 {
	local prepend_path
	prepend_path=../../../../../../../../..
	_bashrc_.cd "${prepend_path}/${1}"
}


# programmable completion
# source available completion file
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# common completions
complete -A hostname             rsh rcp telnet rlogin ftp ping disk
complete -A export               printenv
complete -A variable             export local readonly unset
complete -A enabled              builtin
complete -A alias                alias unalias
complete -A function             function
complete -A user                 su mail finger
complete -A helptopic            help
complete -A shopt                shopt
complete -A stopped   -P '%'     bg
complete -A job       -P '%'     fg jobs disown
complete -A directory            mkdir rmdir
complete -A directory -o default cd

# compression
complete -f -o default -X '*.+(zip|ZIP)'     zip
complete -f -o default -X '!*.+(zip|ZIP)'    unzip
complete -f -o default -X '*.+(z|Z)'         compress
complete -f -o default -X '!*.+(z|Z)'        uncompress
complete -f -o default -X '*.+(gz|GZ)'       gzip
complete -f -o default -X '!*.+(gz|GZ)'      gunzip
complete -f -o default -X '*.+(bz2|BZ2)'     bzip2
complete -f -o default -X '!*.+(bz2|BZ2)'    bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|xz|XZ|bz2|BZ2)'   extract

complete -f -o default -X '!*.pl'            perl perl5

complete -F _bashrc_.complete .. .1 .2 .3 .4 .5 .6 .7 .8 .9

### run setup
# load SSH keys
_bashrc_ssh-add-keys

# echo motd
_bashrc_motd

### set PS1/PS2, appends to history

# see _ps1_color for color reference for each PS1 segment
# Note: all non-printing sequences must be surrounded by \[ \]
# Note: bash PS1 title can only reference variables eg. $PWD
#       (calling functions causes errors in title eg. pwd)

# set window title
# format:  $PWD; $?=#
PS1='\[\e]0;'"$PWD"'; \$?=$?\007\]'
PS1+='\n'

# set window title during command execution
# format:  $PWD: (command)
trap 'echo -ne "\033]0;$PWD: (${BASH_COMMAND})\007"' DEBUG

# set first line
# format:  [user@host path] (git branch)
PS1+='\[$(_ps1_color bracket)\][\[$(_ps1_color user)\]\u\[$(_ps1_color @)\]@\[$(_ps1_color host)\]\[$(hostname -f 2>/dev/null || hostname)\] \[$(_ps1_color path)\]\w\[$(_ps1_color bracket)\]]\[$(_ps1_color branch)\]\[$(__git_ps1 2>/dev/null)\]\[$(_ps1_color prompt)\]'
PS1+='\n'

# set second line
# format:  $
PS1+='\[$(_ps1_color preprompt)\]\$\[$(_ps1_color prompt)\] '
PS2='\[$(_ps1_color preprompt)\]>\[$(_ps1_color prompt)\] '
PROMPT_COMMAND="_bashrc_prompt_command"


# source post-bashrc script (if present)
if [ -f ~/.bashrc.after ]; then
	. ~/.bashrc.after
fi
