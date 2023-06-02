#!/bin/python3

###
### Music transfer script useful for syncing a subset of music from a source
### (home computer, for example) to a portable device, converting files to mp3
### for portability.
###

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import (
	Set,
	Union,
)

KNOWN_EXTENSIONS: Set[str] = set([
	'.mp3',
	'.flac',
	'.m4a',
	'.opus',
])

# TODO: improve copying from ext4 to fs which can't handle ':' in paths
#       that is, don't munge all the possibly problematic chars, only do
#       the ones which cause problems on the target fs
# see: https://stackoverflow.com/a/35352640/540162
# getting filesystem type can be done like so: https://stackoverflow.com/a/25286268/540162
def munge_path(path: str) -> str:
	return re.sub(r'[\:*?"|<>]+', '-', path)

if len(sys.argv) != 3:
	print(f'Usage: {os.path.basename(__file__)} PATHS-FILE DESTINATION-DIR', file=sys.stderr)
	sys.exit(1)

paths_file: str = sys.argv[1]
destination_dir: str = sys.argv[2]

if not os.path.exists(paths_file):
	print(f'PATHS-FILE \'{paths_file}\' does not exist or is not readable', file=sys.stderr)
	sys.exit(2)


print('[DEBUG] Gathering destination files list')
destination_files: Set[Path] = set()
if os.path.isdir(destination_dir):
	for dirpath, _, files in os.walk(destination_dir):
		for file in files:
			path = Path(os.path.join(dirpath, file)).absolute()
			if path.suffix == '.mp3':
				if path in destination_files:
					print(f'Ignoring duplicate input entry: {file}')
				else:
					destination_files.add(path)
print(f'[DEBUG] Gathered {len(destination_files)} destination files')

print('[DEBUG] Gathering source files list')
source_files: Set[Path] = set()
for line in open(paths_file, 'r'):
	trimmed_line = line.strip()
	if not trimmed_line:
		continue

	path = Path(trimmed_line).absolute()
	if path.is_file():
		if path.suffix in KNOWN_EXTENSIONS:
			source_files.add(path)
		else:
			print(f'[TRACE] Unknown file extension of entry: {trimmed_line}', file=sys.stderr)
	elif path.is_dir():
		for dirpath, _, files in os.walk(path.absolute()):
			# TODO: DRY (see above)
			for file in files:
				file_path = Path(os.path.join(dirpath, file)).absolute()
				if file_path.suffix in KNOWN_EXTENSIONS:
					source_files.add(file_path)
				else:
					print(f'[TRACE] Unknown file extension of entry: {file}', file=sys.stderr)
	elif not path.exists():
		print(f'[ERROR] Could not find source path: {path}')
		sys.exit(3)

if len(source_files) == 0:
	print('No source files to transfer')
	sys.exit()
else:
    print(f'[DEBUG] Gathered {len(source_files)} source files')

print('[DEBUG] Finding longest common prefix of source files')
longest_prefix = next(iter(source_files)).parent
for file in source_files:
	if longest_prefix.as_posix() == '/':
		break

	while not file.as_posix().startswith(longest_prefix.as_posix()):
		longest_prefix = longest_prefix.parent

print('[DEBUG] Filtering files already present in destination')
# NOTE: this assumes all filenames are unique, which should already be the case in my music library
#       verify via `find . -type f -not -name '*.jpg' -not -name '*.png' -not -name '*.txt' -exec basename {} \; | sort | uniq -d`
# TODO: add a hash check so that we can overwrite songs on the target if source
#       has a version which is different (new metadata, or better version)
for source_path in list(source_files)[:]:
	found_destination_path: Union[Path, None] = next((destination_file for destination_file in destination_files if destination_file.stem == munge_path(source_path.stem)), None)
	if found_destination_path:
		source_files.remove(source_path)
		destination_files.remove(found_destination_path)

if len(source_files) == 0:
	print('All source files already exist in target')
	sys.exit()

# TODO: improve prompt (print 10+ file paths or exit to `PAGER` to view before prompt so user has more info before confirming)
if len(destination_files) > 0:
	delete_selection_made = False
	while not delete_selection_made:
		print(f'Files in destination not found in source files list:\n{destination_files}')
		delete_input = input(f'Delete {len(destination_files)} files not found in source files list? [y/n] ')
		if delete_input[0] == 'y' or delete_input[0] == 'Y':
			delete_selection_made = True
			for destination_file in destination_files:
				destination_file.unlink()
		elif delete_input[0] == 'n' or delete_input[0] == 'N':
			delete_selection_made = True

# TODO: list both number of files in songs list & number of files to be transferred
print(f'Copying {len(source_files)} songs to {destination_dir}')
print(f'[TRACE] Copying the following files to destination:\n{source_files}')

for source_file in source_files:
	source_copy_path = source_file.with_suffix('').as_posix().replace(longest_prefix.as_posix(), '', 1)
	destination_filename = munge_path(source_copy_path)
	destination_file_path = f'{destination_dir}/{destination_filename}.mp3'

	# TODO: double-check on this
	print(f'destination_file_path: {destination_file_path}')
	Path(destination_file_path).parent.mkdir(parents = True, exist_ok = True)

	if source_file.stem == '.mp3':
		shutil.copy2(source_file.as_posix(), destination_file_path)
	else:
		subprocess.call([
			'ffmpeg',
			'-loglevel', 'quiet',
			'-i', source_file.as_posix(),
			'-codec:a', 'libmp3lame',
			# convert to mp3 with quality level 3 vbr (average 175 kbit/s, ranges from 150-195 kbit/s)
			# see: https://trac.ffmpeg.org/wiki/Encode/MP3#VBREncoding
			'-q:a', '3',
			destination_file_path
		])


# TODO: improve this output (number of deleted files, number of new files, correct plural of 'files')
print(f'Finished copying {len(source_files)} new files to {destination_dir}')
