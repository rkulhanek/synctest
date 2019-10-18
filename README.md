Script for synchronizing gitlab and di2e repos

# Configuration

## Add links to all the remote repositories.
The form of the URI should be specified by whatever git service you're using.
For example:
`remote add gitlab git@gitlab.com:example/test.git`
`remote add github https://github.com/example/test.git`

The labels (gitlab and github in those examples) are what git-sync will refer to.

## Specify a default mergetool
git-sync will use whatever mergetool you have specified to handle the manual merges. If you don't
specify one, it will prompt for one each time.

`git mergetool --tool-help` will list a set of available mergetools. vimdiff and emerge are the ones
that use vim and emacs, respectively. Generally, mergetools will open multiple buffers:

	* The more recent common version of the file
	* The local version
	* The remote version
	* The version that you will modify and merge into the repository.

Exact details will vary depending on the mergetool.

You can set a default merge tool using, e.g., `git config --global merge.tool vimdiff`

By default, mergetools will make a backup named *filename*.orig whenever there's a manual merge. You can
disable this behavior using git config --global mergetool.keepBackup false

# Usage
0) Set up however many remotes you want to using git remote add. I'll use gitlab and di2e as the example names below.
1) Run ./git-sync.sh --pull gitlab di2e
2) Run ./git-sync.sh --push gitlab di2e

An alternative to specifying remotes manually is to pass the --all option.
That will get the list of all remotes configured for the repository.
If multiple remotes point to the same server, it will only use one of them.

If you need to abort ./sync.sh --pull for whatever reason, you will need to fix
whatever's wrong with the current branch manually and commit the changes, but
then you should be able to just run ./sync.sh --pull again and it'll continue
where it left off.

