#!/bin/bash

OPTS=$(getopt -o '' -lpull,merge,push -- "$@")
action=''
remotes=()

DEFAULT_COLOR=0
RED=31
GREEN=32
YELLOW=33
BLUE=34
BRIGHT_RED=91
BRIGHT_GREEN=92
BRIGHT_YELLOW=93
BRIGHT_BLUE=94

function color {
	if [ "$DEFAULT_COLOR" -eq "$1" ]; then
		echo "$2"
		return
	fi
	echo -e "\x1b[$1m$2\x1b[0m";
}

function error_msg {
	color "$BRIGHT_RED" "ERROR: $1"
}

function help {
	echo "Usage: $0 --pull remote0 remote1 ..." > /dev/stderr
	echo "Usage: $0 --merge" > /dev/stderr
	echo "Usage: $0 --push remote0 remote1 ..." > /dev/stderr
	echo "Run them in that order."
	exit 1
}

function pull {
	# Verify no uncommited local changes
	git diff-index --quiet HEAD
	if [ 0 -ne "$?" ]; then
		error_msg 'There exist uncommitted changes. Commit them before synchronizing remote repos.'
		exit 1
	fi

	# fetch changes
	for remote in ${remotes[@]}; do
		AWK_FILTER="/^$remote/ { print(substr(\$0, 2+length(\"$remote\"))) }"
		git fetch -- "$remote" # needed to make new branches show up in git branch -r

		remote_branches=$(git branch -r | grep -v ' -> ' | sed 's/^ *//' | awk "$AWK_FILTER") # skip, e.g. HEAD -> origin/HEAD
		color $BRIGHT_BLUE "remote: $remote"
		for branch in $remote_branches; do
			color $BRIGHT_BLUE "branch: $remote/$branch"
			git checkout "$branch"
			git pull -- "$remote" "$branch"
		done
	done
}

function merge {
	for remote in ${remotes[@]}; do
		AWK_FILTER="/^$remote/ { print(substr(\$0, 2+length(\"$remote\"))) }"
		remote_branches=$(git branch -r | grep -v ' -> ' | sed 's/^ *//' | awk "$AWK_FILTER") # skip, e.g. HEAD -> origin/HEAD
		for branch in $remote_branches; do
			color $BRIGHT_BLUE "merge branch: $remote/$branch"
			git mergetool
			if [ 0 -eq "$?" ]; then
				git commit -m "merged $remote/$branch"
			else
				error_msg "Skipping commit for $remote/$branch"
			fi
		done
	done
}

function push {
	for remote in ${remotes[@]}; do
		git push --all "$remote"
	done
}

## Start

function setaction {
	if [ ! -z "$action" ]; then
		error_msg "multiple actions specified. Set exactly one of --pull --merge --push"
		exit 1
	fi
	action="$1"
}

## main ##
while [ $# -gt 0 ]; do
	case "$1" in
		--pull) 
			setaction "pull"
			shift 
			;;
		--merge) 
			setaction "merge"
			shift 
			;;
		--push) 
			setaction "push"
			shift 
			;;
		--)
			shift
			break
			;;
		*) 
			remotes+=("$1")
			shift
			;;
	esac
done

while [ $# -gt 0 ]; do
	remotes+=("$1")
	shift
done

if [ 'merge' != "$action" -a 0 -eq "${#remotes[@]}" ]; then
	error_msg "--$action action requires a list of remote repositories"
	help
	exit 1
fi

$action

