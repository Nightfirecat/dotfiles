#!/usr/bin/env bash
set -e

# Accept the `--remove` argument to delete symlinks of the files to be copied
# This is useful for testing a clean installation (eg. `setup.sh --remove && setup.sh`)
# Note: Normal setup overwrites all incorrect symlinks, so re-installation in place is idempotent
if [ "$1" == '--remove' ]; then
	remove=1
else
	remove=0
fi

DIR="$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )"
SRC_DIR="$DIR/src"
POST_SETUP_SCRIPTS=(
	vscode.sh         # install vscode configs
	ssh.sh            # set up SSH config and create key if needed
	gpg.sh            # create GPG key if needed
	diff-highlight.sh # build diff-highlight script from git source
)

# read file basenames to copy_files array
copy_files=()
files_to_remove=()
while IFS=  read -r -d $'\0'; do
	# remove leading $SRC_DIR/ from found files
	# this allows directories to be preserved
	copy_files+=( "${REPLY//$SRC_DIR\//}" )
done < <(find "$SRC_DIR" -type f -print0)

# clear symlinks pointing to non-existent src files
symlink_check_dirs=()
while IFS=  read -r -d $'\0'; do
	symlink_check_dirs+=( "$(sed -r -e "s|^${SRC_DIR}/?||" <<< "$REPLY")" )
done < <(find "$SRC_DIR" -type d -print0)
for dir in "${symlink_check_dirs[@]}"; do
	while IFS=  read -r -d $'\0'; do
		# it is possible for `readlink` to fail if the link target does not
		# exist (within multiple non-existent subdirectories?); such entries
		# aren't valid to check anyway, skip them
		link_target="$(readlink -f "$REPLY")" || continue

		# if a symlink is found which points to a SRC_DIR file but there's no
		# file that it's pointing at, it's an old and outdated link; delete it
		if [[ "$link_target" =~ ^"$SRC_DIR" && ! -f "$link_target" ]]; then
			echo "Removing dead dotfiles symlink: '$REPLY'"
			rm "$REPLY"
		fi
	done < <(find "$HOME/$dir" -maxdepth 1 -type l -print0)
done

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
		source="${SRC_DIR}/${file}"
		target="${HOME}/${file}"
		if { [ -e "$target" ] && ! [ -L "$target" ]; } \
			|| { [ -L "$target" ] && [[ "$source" != "$(readlink -f "$target")" ]]; }; then
			files_to_remove+=( "$file" )
		fi
	done

	if [ "${#files_to_remove}" -ne 0 ]; then
		echo "Remove the following files/symlinks from home directory and re-run setup!"
		printf '%s\n' "${files_to_remove[@]}"
		exit 1
	fi

	# Symlink files to $HOME, overwrite incorrect symlinks
	for file in "${copy_files[@]}"; do
		source="${SRC_DIR}/${file}"
		target="${HOME}/${file}"
		if [[ -h "$target" ]] && [[ "$source" == "$(readlink -f "$target")" ]]; then
			echo "Skipping '${source}' -> '${target}' link as it is already linked"
		else
			target_dir="$(dirname "$target")"
			while [ ! -d "$target_dir" ]; do
				target_parent="$target_dir"
				while [ ! -d "$(dirname "$target_parent")" ]; do
					target_parent="$(dirname "$target_parent")"
				done
				mkdir -vm 0700 "$target_parent"
			done

			ln -sv "$source" "$target"
		fi
	done
fi

for script in "${POST_SETUP_SCRIPTS[@]}"; do
	source "${DIR}/post-setup/${script}"
done
