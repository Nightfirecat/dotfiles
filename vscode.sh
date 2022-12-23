#!/usr/bin/env bash
set -e

###
### Install a base of vscode extensions I expect to have in all installations and install settings
### and keybindings config files.
###

# determine OS / vscode path & executable
case "$OSTYPE" in
	linux-gnu*)
		VSCODE_CONFIG_PATH="$HOME/.var/app/com.visualstudio.code/config/Code/User"
		VSCODE_BINARY=(flatpak run com.visualstudio.code)
		;;
	darwin*)
		VSCODE_CONFIG_PATH="$HOME/Library/Application Support/Code/User"
		VSCODE_BINARY=('/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code')
		;;
	cygwin|msys|win32)
		# TODO: implement this later
		# windows
		;;
	*)
		# unknown
		echo 'Unknown OS, skipping vscode setup'
		return
		;;
esac

if [[ ! -d "$VSCODE_CONFIG_PATH" ]]; then
	echo "Could not locate vscode config path (expected at '$VSCODE_CONFIG_PATH')"
	echo "Skipping vscode setup"
	return
elif ! type "${VSCODE_BINARY[0]}" >/dev/null 2>/dev/null; then
	echo "Could not identify vscode binary (expected '${VSCODE_BINARY[*]}')"
	echo "Skipping vscode setup"
	return
fi

# install extensions
while read -r line; do
	"${VSCODE_BINARY[@]}" --install-extension "$line"
done < "$DIR"/vscode/extensions

# backup settings/keybinds files, then create symlinks
# TODO: do the same for snippets dir files
for file in settings.json keybindings.json; do
	source="$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )/vscode/$file"
	target="$VSCODE_CONFIG_PATH/$file"
	if [[ -h "$target" ]] && [[ "$source" == "$(readlink -f "$target")" ]]; then
		echo "Skipping '$source' -> '$target' link as it is already linked"
		continue
	elif [[ -f "$target" ]]; then
		mv "$target" "$target.bak"
		echo "Backed up existing $file to $target.bak"
	fi

	ln -sv "$source" "$target"
done
