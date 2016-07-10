#Git Stream

[![Build Status](https://travis-ci.org/mrkmg/git-stream.svg?branch=master)](https://travis-ci.org/mrkmg/git-stream)

Git Stream is a branching model inspired by [git-flow](https://github.com/nvie/gitflow). I really enjoy what git-flow offers, but the multiple primary branches, the multiple branches which do the same thing (feature/support/bugfix), and dealing with pull requests always kind of bugged me. After reading this [blog](http://endoflineblog.com/gitflow-considered-harmful) I decided I would build my own "git-flow".

The name "Git Stream" was chosen as this plugin should streamline some of the repetitious actions in git.

####Warning

Git Stream is still very new, with minimal testing by a single person so far. While I am open to suggestions, bug reports, etc know that this project is a long ways away from being ready for real use. As the project matures, this warning will be updated.

##Installation

Installation should be easy, and compatible with any platform which has bash and git installed.

Basic Procedure

- Clone Repo Somewhere
- Checkout the latest version
- Test on your platform. If you encounter a failing test, please report it as an issue
- Install

Example Installation on Linux

    git clone https://github.com/mrkmg/git-stream.git /tmp/git-stream
    cd /tmp/git-stream
    git checkout 0.2.0
    make test
    sudo make install

By default, git-stream will be installed to `/usr/local/bin`. If you would prefer to install somewhere else, you can change the prefix. for example:

    sudo make install PREFIX=/usr

##Usage

All Git Stream commands are issued as follows:

    git stream <command>

####Commands

**init**

Initialize Git Stream on the current project.

    -d, --defaults             Initialize with all default options
    -f, --force                Force Initialization
    --version-prefix {prefix}  Version Prefix []
    --feature-prefix {prefix}  Feature Branch Prefix [feature/]
    --hotfix-prefix {prefix}   Hotfix Branch Prefix [hotfix/]
    --release-prefix {prefix}  Release Branch Prefix [release/]
    --working-branch {prefix}  Working Branch [master]

**hotfix**

Work with hotfixes. Hotfixes are used to fix a bug in a release.

    start {version} {hotfix-name}
    finish [-n] {version} {hotfix-name} {new-version}
    list

    -n, --no-merge    Do not merge hotfix back to master

`--no-merge` would be useful when hot-fixing an LTS version

**feature**

Work with features. Features are used to implement new functionality.

    start {feature-name}
    finish {feature-name}
    list


**release**

Work with releases. Releases are used to mark specific versions.

    start {version}
    end {version}
    list


##Example

The following is a contrived example of working on a library with Git Stream.

If you have not already, initialize Git on your project.

    git init
    git add .
    git commit -m "Initial Commit"

Next, initialize Git Stream. (the -d makes Git Stream use all the default options)

    git stream init -d

You should now be on the master branch. This branch is where changes are stored for the next release.

So lets say you want to implement a new feature. Run the following:

    git stream feature start new-feature


In the above command, "new-feature" is the name of the new feature. This will create a new branch named "feature/new-feature" forked from master. This is where you would implement your new feature and put you into that branch.

Feel free to switch back to master, or any other branch. Your branch will stay there and allow you to come back and work on the new feature anytime.

After you finish writing the new feature, go ahead and finish up the feature.

    git stream feature finish new-feature

If you run into the message `Failed to merge feature/new-feature into master. Rebase Needed`, that means you can not simply merge the feature into master as master has been changed. This can often happen if multiple features are being finished. The fix is very easy. Rebase master into your new feature branch.

While on the feature/new-feature branch, run the following commands:

    git rebase master

Fix all the conflicts, then finish the rebase

    git add -a
    git rebase --continue
    git stream feature finish new-feature

If you would prefer to merge, you can merge master into feature/new-feature as well.

Now, your new feature is integrated into master, so lets make a release with this new feature. Start a new release.

    git stream release start 1.1.0

A new branch will be made named "release/1.1.0". This branch will be used to make the release. Actions may include updating version numbers in documentation and source files, producing compiled files, etc. After you have completed making all the changes and committed them, finish the release.

    git stream release finish 1.1.0

This should not have any conflicts, but if it does you can rebase like you did with features. This will merge the release back into master and create a tag for the version. At this point you probably would want to publish the version, so you can do that as simply as:

    git push origin --tags

The last feature is the hotfix. Lets say some time goes by, you have committed to master a few times, started a couple new features, but then a bug is reported that needs an immediate fix. This is where Hot Fixes come into play. If back in version 1.1.0 a critical bug was introduced. We would want the release a version 1.1.1 which addresses this bug.

To make that fix, you start the hotfix.

    git stream hotfix start 1.1.0 security-flaw-bug

This will create a branch named "hotfix/1.1.0-security-flaw-bug" forked from the tag 1.1.0. Fix the bug and then finish the hotfix, and implementing it in 1.1.1.

    git stream hotfix finish 1.1.0 security-flaw-bug 1.1.1

This will tag your current hotfix branch as 1.1.1 and then rebase master with the fix.

If the output is "Hot Fix security-flaw-bug failed to be merged into master. Please manually merge.", you will need to manually merge the bugfix into master. This can be caused if work done on master conflicts with the hotfix. Run the following while checked out of master:

    git merge 1.1.1

Make the proper corrections, stage them, then make a commit.

###Other Notes

If you are working on a long running feature, you may want to occasionally bring the feature branch up to date. This can be done via a rebase or merge. If we want to merge, issue the following while on your feature branch:

    git merge master

Not all use cases are covered here, for example putting multiple hotfixes in one release. Git Stream is very minimal and you can use it when you want. For small, single-developer projects, it may be fine to work on new features directly on the master branch.

Much is left to the native git command, and Git Stream's goal is not to duplicate existing functionality of git, which is why merging, rebasing, pushing, pulling, etc are left up to git. Those commands already work perfectly and is not really needed.

###Roadmap

Please see the ROADMAP file.

###License

The MIT License (MIT)
Copyright (c) 2016 Kevin Gravier <kevin@mrkmg.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
