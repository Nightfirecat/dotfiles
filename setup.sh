#!/usr/bin/env bash
set -e

# Accept the `--remove` argument to delete symlinks of the files to be copied
# This is useful for testing a clean installation (eg. `setup.sh --remove && setup.sh`)
# Note: Normal setup overwrites all old symlinks, so re-installation in place is idempotent
if [ "$1" == '--remove' ]; then
	remove=1
else
	remove=0
fi

DIR="$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )"
SRC_DIR="$DIR/src"

# read file basenames to copy_files array
copy_files=()
files_to_remove=()
while IFS=  read -r -d $'\0'; do
	copy_files+=( "$(basename "$REPLY")" )
done < <(find "$SRC_DIR" -type f -print0)

if [ $remove -eq 1 ]; then
	for file in "${copy_files[@]}"; do
		if [ -L "$file" ]; then
			rm -v "$file"
		else
			echo "Skipping deletion of ${file} because it is not a symlink"
		fi
	done
elif [ $remove -eq 0 ]; then
	# Ensure all files are absent in $HOME
	for file in "${copy_files[@]}"; do
		if [ -e "${HOME}/${file}" ] && ! [ -L "${HOME}/${file}" ]; then
			files_to_remove+=( "$file" )
		fi
	done

	if [ "${#files_to_remove}" -ne 0 ]; then
		echo "Remove the following files from home directory and re-run setup!"
		printf '%s\n' "${files_to_remove[@]}"
		exit 1
	fi

	# Symlink files to $HOME, overwrite old symlinks
	for file in "${copy_files[@]}"; do
		source="${SRC_DIR}/${file}"
		target="${HOME}/${file}"
		if [[ -h "$target" ]] && [[ "$source" == "$(readlink -f "$target")" ]]; then
			echo "Skipping '${source}' -> '${target}' link as it is already linked"
		else
			ln -sv "${SRC_DIR}/${file}" "${HOME}/${file}"
		fi
	done
fi
