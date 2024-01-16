#!/usr/bin/env bash

###
### Helper script for quickly setting up a git branch and directory/file
### structure for creating a new release post for runelite.net
###

set -e

description() {
	echo 'Creates a new branch and file structure for the weekly release blog post in the runelite.net repository'
}
helpdoc() {
	echo
	echo "usage: $(basename "$0") [<options>]"
	echo
	echo 'options:'
	echo '    -a <author>   first name to use, defaults to `git config user.name'"'"
	echo '    -f <version>  version number to generate shortlog from, defaults to previous'
	echo '                  major release'
	echo '    -n <version>  version number to increment to, defaults to a patch version'
	echo '                  bump'
	echo '    -p <path>     path of runelite repository relative to runelite.net repo,'
	echo '                  defaults to `../runelite'"'"
	echo '    -t            mark the blog post for today'"'"'s date, not tomorrow'"'"'s date'
}

# process args
while getopts ':a:f:n:p:th' arg; do
	case "$arg" in
		a)
			blog_author="$OPTARG"
			;;
		f)
			previous_version="$OPTARG"
			;;
		h)
			description
			helpdoc
			exit 0
			;;
		n)
			version="$OPTARG"
			;;
		p)
			runelite_repo_path="$OPTARG"
			;;
		t)
			blog_date='today'
			;;
		\?)
			echo "Invalid option: ${OPTARG}" >&2
			helpdoc
			exit 1
			;;
		:)
			echo "Option -${OPTARG} requires an argument." >&2
			helpdoc
			exit 1
			;;
	esac
done

# remove args processed with getopts
shift $(( OPTIND-1 ))

# ensure shell is in runelite.net repo, navigate to root dir if necessary, fetch upstream
if ! (git remote -v | grep -q -E 'upstream[[:space:]]+git@github.com:runelite/runelite.net.git'); then
	echo 'You do not appear to be in a clone of the runelite.net repository!' >&2
	exit 1
fi
cd "$(git rev-parse --show-toplevel)"
git fetch -q upstream

# ensure runelite repo path is correct, fetch upstream in runelite repo
default_path='../runelite'
repo_path="${runelite_repo_path:-$default_path}"

if ! (git -C "$repo_path" remote -v | grep -q -E 'upstream[[:space:]]+git@github.com:runelite/runelite.git'); then
	echo "The repo path '${repo_path}' does not appear to be a clone of the runelite repository!" >&2
	exit 1
fi
(git -C "$repo_path" git fetch -q upstream) >/dev/null

# validate versions
latest_tag="$(git -C "$repo_path" tag -l | grep -v 'internal' | sort -rV | head -n 1 | sed -r -e 's/(.*-)([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+).*/\1\2/')"
LATEST_TAG_VERSION="${latest_tag##*-}"
if [ -z "$previous_version" ]; then
	: # no-op
elif ! [[ "$previous_version" =~ ^[1-9][[:digit:]]*\.([[:digit:]]|[1-9][[:digit:]]*)\.([[:digit:]]|[1-9][[:digit:]]*)(\.([[:digit:]]|[1-9][[:digit:]]*))?$ ]]; then
	echo "Invalid previous version number: '$previous_version'" >&2
	helpdoc
	exit 1
else
	latest_tag="runelite-parent-${previous_version}"
fi

if [ -z "$version" ]; then
	patch_number="${LATEST_TAG_VERSION##*.}"
	version="${LATEST_TAG_VERSION%.*}.$((patch_number + 1))"
elif ! [[ "$version" =~ ^[1-9][[:digit:]]*\.[1-9][[:digit:]]*\.[1-9][[:digit:]]*$ ]]; then
	echo "Invalid version number: '$version'" >&2
	helpdoc
	exit 1
fi

NEW_VERSION="$version"

# get data, define vars
git_username_trimmed="$(git config user.name | cut -d ' ' -f '1')"
default_date='+1 day'
BLOG_DATE="${blog_date:-$default_date}"
BLOG_AUTHOR="${blog_author:-$git_username_trimmed}"
git_shortlog_options=(--no-merges --perl-regexp '--author=^((?!Runelite auto updater|RuneLite Cache-Code Autoupdater|RuneLite updater).*)$' "${latest_tag}"..upstream/master)
SHORTLOG_SINCE_LAST_TAG="$(git -C "$repo_path" --no-pager shortlog "${git_shortlog_options[@]}")"
NUMBER_OF_CONTRIBUTORS="$(git -C "$repo_path" --no-pager shortlog -s "${git_shortlog_options[@]}" | wc -l)"
BLOG_POST_DATE="$(date -d "${BLOG_DATE} 10:00am" +'%Y-%m-%d-%H-%M')"

# create new branch, deleting branch of same name if it exists
git checkout master >/dev/null 2>&1
if git branch | grep -q "$NEW_VERSION"; then
	git branch -D "$NEW_VERSION" >/dev/null 2>&1
fi
(git pull --ff-only && git checkout -b "$NEW_VERSION") >/dev/null 2>&1

# create dirs and files
relative_img_path="img/blog/${NEW_VERSION}-Release"
img_name="placeholder.png"
IMAGE_DIR="public/${relative_img_path}/${img_name}"
PLACEHOLDER_IMAGE_PATH="${relative_img_path}/${img_name}"
BLOG_FILE_PATH="src/_posts/${BLOG_POST_DATE}-${NEW_VERSION}-Release.md"

install -Dv /dev/null "${IMAGE_DIR}" >/dev/null
tee "${BLOG_FILE_PATH}" >/dev/null 2>&1 <<EOF
---
title: '${NEW_VERSION} Release'
description: 'TODO: A major feature, an important bug fix, and other important news'
author: ${BLOG_AUTHOR}
---

TODO: The RuneLite plugin now has a new major feature. Thanks to [@Test](https://github.com/test) for
this contribution.

TODO: ![Alt text for this new feature](/${PLACEHOLDER_IMAGE_PATH})

TODO: Another plugin has a new feature. Thanks to [@Example](https://github.com/example) for this
contribution.

TODO: ![Alt text for this new feature](/${PLACEHOLDER_IMAGE_PATH})

TODO: Other information, such as more major features (with or without images), important news, or other
information such as removal of features/plugins can be placed here.

There are also several smaller improvements and bug fixes, including:

- TODO: use real changes below
- The RuneLite plugin will no longer cause the client to crash
- Obstacle highlighting has been added for the Test area
- The idle notifier will notify you when you've stopped writing code
- etc...

Enjoy!

\\- ${BLOG_AUTHOR}

### New commits

We had ${NUMBER_OF_CONTRIBUTORS} contributors this release!

\`\`\`
${SHORTLOG_SINCE_LAST_TAG}
\`\`\`
EOF

echo 'Blog branch and structure created!'
