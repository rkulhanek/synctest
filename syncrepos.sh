#!/bin/bash -x

#remotes=(github gitlab)
remotes=(remote0 remote1)

# TODO: Set a working directory other than the current one to do this in. If things
# get weird, I want it clobbering a directory I don't care about

# TODO: handle it correctly when saying "n" to the "was a merge resolved" message from mergetool

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

# Verify no uncommited local changes
git diff-index --quiet HEAD
if [ 0 -ne "$?" ]; then
	error_msg 'There exist uncommitted changes. Commit them before synchronizing remote repos.'
	exit 1
fi

git branch -r
for remote in ${remotes[@]}; do
	AWK_FILTER="/^$remote/ { print(substr(\$0, 2+length(\"$remote\"))) }"
	git fetch -- "$remote" # needed to make new branches show up in git branch -r

	remote_branches=$(git branch -r | grep -v ' -> ' | sed 's/^ *//' | awk "$AWK_FILTER") # skip, e.g. HEAD -> origin/HEAD
	color $BRIGHT_BLUE "remote: $remote"
	for branch in $remote_branches; do
		color $BRIGHT_BLUE "branch: $remote/$branch"
		git checkout "$branch"
		git pull -- "$remote" "$branch"
		git mergetool
		if [ 0 -eq "$?" ]; then
			git commit -m "merged $remote/$branch"
		else
			error_msg "Skipping commit for $remote/$branch"
		fi
	done
done

exit 0

# TODO: Actually, the push should be a separate script.

# TODO: add a -y option that bypasses this
while true; do
	read -p "$(color $DEFAULT_COLOR 'Push changes (yes/no)? ')" yn
	if [ 'yes' == "$yn" ]; then
		break
	elif [ 'no' == "$yn" ]; then
		echo 'Aborting'
		exit 1
	fi
done

color $RED 'TODO: remote below exit'
exit 0


# Done merging
#for remote in ${remotes[@]}; do
#	git push --all "$remote"
#done

