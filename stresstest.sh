#!/bin/bash

TESTDIR="$HOME/code/QA/synctest/stresstest"

if [ -e "$TESTDIR" ]; then
	echo "Directory '$TESTDIR' already exists. Delete it or change \$TESTDIR before starting this." > /dev/stderr
	exit 1
fi

mkdir -p "$TESTDIR"
cd "$TESTDIR"

# Create repos.
mkdir local
mkdir remote0
mkdir remote1
cd "$TESTDIR/remote0"
git init --bare
cd "$TESTDIR/remote1"
git init --bare

# create common starting point
cd "$TESTDIR/local"
git init
echo 'original foo' > foo
git add foo
git commit -m 'init'
git branch A
git commit -m 'add branch A'
git remote add remote0 "$TESTDIR/remote0"
git remote add remote1 "$TESTDIR/remote1"
git push --all remote0
git push --all remote1

# Other users show up and push changes to remote repos without synchronizing
cd "$TESTDIR"
git clone remote0 user0
git clone remote1 user1

cd "$TESTDIR/user0"
git branch B
echo 'user0 foo' > foo
git add foo
git commit -m 'user0 modified foo'
git checkout A
echo 'user0 Abar' > Abar
git add Abar
git commit -m 'user0 added Abar'
git checkout B
echo 'user0 Bfoo' > Bfoo
echo 'user0 Bbaz' > Bbaz
git add Bfoo Bbaz
git commit -m 'user0 added files to branch B'
git push --all
git checkout master

cd "$TESTDIR/user1"
git branch '$Crazy"name' # n.b. git won't allow branches with : in the name, so we don't need to test for that.
echo 'user1 foo' > foo
git add foo
git commit -m 'user1 modified foo'
git checkout '$Crazy"name'
echo 'Cfoo' > Cfoo
git add Cfoo
git commit -m 'user1 added Cfoo'
git push --all
git checkout master

# And now we make our own incompatible changes
cd "$TESTDIR/local"
git branch B
echo 'local foo' > foo
git add foo
git commit -m 'local modified foo (all three repos now have incompatible copies of foo)'
git checkout A
echo 'local Afoo' > Afoo
git add Afoo
git commit -m 'local added Afoo'
git checkout B
echo 'local Bfoo' > Bfoo
echo 'local Bbar' > Bbar
git add Bfoo Bbar
git commit -m 'local added Bfoo (incompatible with remote0 version), Bbar'
# explicitly staying out of master branch. make sure it doesn't try to check out master into B

# TODO: run synctest here
# TODO: checkout a new copy of each of remote0, remote1, and verify that each is identical to local

