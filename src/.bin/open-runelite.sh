#!/usr/bin/env bash

###
### Quick-start build-and-run script for RuneLite, merging dev branches for a
### custom build.
###

# OPTIONS
RUNELITE_REPO_DIR="$HOME/Documents/git/runelite"
BRANCHES_TO_MERGE=(
	add-tablecomponent-to-overlay-ui
	# dev-update-opponent-info-table-bounty-target
	lookup-players-that-despawn
	#differentiate-gauntlet-loots # conflicts with discord sub-regions
	charlie-texts
	discord-sub-regions
	multi-step-cryptic-spade
	quest-speedrunning-widget-overlays
	fixed-thrall-timer
	fix-grand-exchange-offer-slot-wrapping
	gwd-altar-timer
)
MAX_AGE_BEFORE_REBUILD="$(( 18 * 60 * 60 ))" # 18 hours
UPSTREAM_REMOTE='upstream'
UPSTREAM_BRANCH='master'
for branch in "${BRANCHES_TO_MERGE[@]}"; do
	if grep -qE '^internal' <<< "$branch"; then
		UPSTREAM_REMOTE='internal-upstream'
		UPSTREAM_BRANCH='internal'
		break
	fi
done

# Show exit output on script completion
# On script error, wait for user input to close
function orl_exit {
	exit_code=$?
	if [ "$exit_code" -eq 0 ]; then
		echo 'Running runelite!'
		sleep 3
	else
		echo 'An error occurred while running command'
		echo "  ${BASH_COMMAND}"
		echo 'Press any key to exit...'
		read -n1 -r
	fi
}
trap orl_exit EXIT

DIR="$(dirname "${BASH_SOURCE[0]}")"
RUNELITE_TARGET_COMMIT_FILENAME="$DIR/commit"
function build_client {
	# Update local dev branch and build
	git checkout dev || git checkout -b dev upstream/master
	git reset --hard upstream/master
	git merge --no-gpg-sign --no-edit "${BRANCHES_TO_MERGE[@]}" || exit 1
	mvn clean package -DskipTests -U || exit 1
	git checkout -
	# copy shaded jar to script's directory, removing any old shaded jars
	find "$DIR" -name 'client-*-SNAPSHOT-shaded.jar' -delete
	cp -f "$COMPILED_SHADED_JAR" "$DIR"
	echo "$UPSTREAM_MASTER_COMMIT" > "$RUNELITE_TARGET_COMMIT_FILENAME"
}

set -e

# go to repo
cd "$RUNELITE_REPO_DIR"

# check if jar is up-to-date with latest upstream tag
git fetch -q "$UPSTREAM_REMOTE"
UPSTREAM_MASTER_COMMIT="$(git rev-parse "$UPSTREAM_REMOTE"/"$UPSTREAM_BRANCH")"
# TODO: use `git describe [--abbrev=0]` ? (may not work due to point releases)
# TODO: add --exclude to ^ to avoid describing point releases (TODO: don't do that--we need point release for latest hub plugins)
PREVIOUS_TAG="$(git tag -l | grep -v 'internal' | sort -rV | head -n 1 | sed -r -e 's/.*-(.+)/\1/')"
MAJOR_VERSION="$(cut -d '.' -f 1 <<< "$PREVIOUS_TAG")"
MINOR_VERSION="$(cut -d '.' -f 2 <<< "$PREVIOUS_TAG")"
PATCH_VERSION="$(cut -d '.' -f 3 <<< "$PREVIOUS_TAG")"
NEXT_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.$((PATCH_VERSION + 1))"
SHADED_JAR_FILENAME="client-${NEXT_VERSION}-SNAPSHOT-shaded.jar"
COMPILED_SHADED_JAR=runelite-client/target/"$SHADED_JAR_FILENAME"
CACHED_JAR="$DIR"/"$SHADED_JAR_FILENAME"

# build a new client if one doesn't already exist or if the current shaded jar
# is older than the max rebuild age and is behind upstream master's commit
if ! [ -f "$CACHED_JAR" ]; then
	echo "No build exists for current snapshot; rebuilding"
	build_client
else
	SHADED_JAR_MTIME="$(stat -c %Y "$CACHED_JAR")"
	CURRENT_MTIME="$(date +%s)"
	if [ "$(( "$CURRENT_MTIME" - "$SHADED_JAR_MTIME" ))" -gt "$MAX_AGE_BEFORE_REBUILD" ]; then
		if ! [ -f "$RUNELITE_TARGET_COMMIT_FILENAME" ] \
			|| [ "$UPSTREAM_MASTER_COMMIT" != "$(cat "$RUNELITE_TARGET_COMMIT_FILENAME")" ]; then
			echo "Current built client is old enough for rebuild and master has new commits; rebuilding"
			build_client
		else
			echo "Current built client is old enough for rebuild, but there no new commits to build; skipping rebuild"
		fi
	else
		echo "Current built client is not beyond max age before rebuild; skipping rebuild"
	fi
fi

# run the dev client
nohup java -ea -Drunelite.pluginhub.version="${PREVIOUS_TAG}" -jar "$CACHED_JAR" --developer-mode --debug </dev/null >/dev/null 2>&1 &
