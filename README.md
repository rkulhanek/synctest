Script for synchronizing gitlab and di2e repos

0) Set up however many remotes you want to using git remote add. I'll use gitlab and di2e as the example names below.
1) Run ./sync --pull gitlab di2e
2) Run ./sync --push gitlab di2e

If you need to abort ./sync.sh --pull for any reason, you will need to fix
whatever's wrong with the current branch manually and commit the changes, but
then you should be able to just run ./sync.sh --pull again and it'll continue
where it left off.

