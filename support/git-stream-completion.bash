#!bash
#
# git-stream-completion
# =====================
#
# Bash completion support for [git-stream](https://github.com/mrkmg/git-stream)
#
#  * git-stream init and version
#  * feature, hotfix and release branches
#
#
# Installation
# ------------
#
# To achieve git-stream completion nirvana:
#
#  0. Install git-completion.
#
#  1. Install this file. Either:
#
#     a. Place it in a `bash-completion.d` folder:
#
#        * /etc/bash-completion.d
#        * /usr/local/etc/bash-completion.d
#        * ~/bash-completion.d
#
#     b. Or, copy it somewhere (e.g. ~/.git-stream-completion.sh) and put the following line in
#        your .bashrc:
#
#            source ~/.git-stream-completion.sh
#
#  2. If you are using Git < 1.7.1: Edit git-completion.sh and add the following line to the giant
#     $command case in _git:
#
#         stream)        _git_stream ;;
#
#
# The Fine Print
# --------------
#
# Author:
# Copyright 2012-2013 Peter van der Does.
#
# Original Author:
# Copyright (c) 2011 [Justin Hileman](http://justinhileman.com)
#
# Distributed under the [MIT License](http://creativecommons.org/licenses/MIT/)

_git_stream ()
{
    local subcommands="init feature release hotfix help version"
    local subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
        init)
            __git_stream_init
            return
            ;;
        feature)
            __git_stream_feature
            return
            ;;
        release)
            __git_stream_release
            return
            ;;
        hotfix)
            __git_stream_hotfix
            return
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

__git_stream_init ()
{
    local subcommands="help"
    local subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi
}

__git_stream_feature ()
{
    local subcommands="list start finish update help"
    local subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
        finish|update)
            __gitcomp_nl "$(__git_stream_list_local_branches 'feature')"
            return
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

__git_stream_release ()
{
    local subcommands="list start finish update help"
    local subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
        finish)
            __gitcomp_nl "$(__git_stream_list_local_branches 'release')"
            return
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

__git_stream_hotfix ()
{
    local subcommands="list start finish help"
    local subcommand="$(__git_find_on_cmdline "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
        start)
            __gitcomp_nl "$(__git_stream_list_tags 'version')"
            return
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

__git_stream_prefix ()
{
    case "$1" in
        feature|release|hotfix)
            git config "gitstream.prefix.$1" 2> /dev/null || echo "$1/"
            return
            ;;
        version)
            git config "gitstream.prefix.$1" 2> /dev/null || echo "$1"
            return
            ;;
    esac
}

__git_stream_list_local_branches ()
{
    if [ -n "$1" ]; then
        local prefix="$(__git_stream_prefix $1)"
        git for-each-ref --shell --format="ref=%(refname:short)" refs/heads/$prefix | \
            while read -r entry; do
                eval "$entry"
                ref="${ref#$prefix}"
                echo "$ref"
            done | sort
    else
        git for-each-ref --format="%(refname:short)" refs/heads/ | sort
    fi
}

__git_stream_list_branches ()
{
    local origin="$(git config gitstream.defaultpushremote 2> /dev/null || echo "origin")"
    if [ -n "$1" ]; then
        local prefix="$(__git_stream_prefix $1)"
        git for-each-ref --shell --format="ref=%(refname:short)" refs/heads/$prefix refs/remotes/$origin/$prefix | \
            while read -r entry; do
                eval "$entry"
                ref="${ref##$prefix}"
                echo "$ref"
            done | sort
    else
        git for-each-ref --format="%(refname:short)" refs/heads/ refs/remotes/$origin | sort
    fi
}

__git_stream_list_remote_branches ()
{
    local prefix="$(__git_stream_prefix $1)"
    local origin="$(git config gitstream.defaultpushremote 2> /dev/null || echo "origin")"
    git for-each-ref --shell --format='%(refname:short)' refs/remotes/$origin/$prefix | \
        while read -r entry; do
            eval "$entry"
            ref="${ref##$prefix}"
            echo "$ref"
        done | sort
}

__git_stream_list_tags ()
{
    if [ -n "$1" ]; then
        local prefix="$(__git_stream_prefix $1)"
        git for-each-ref --shell --format="ref=%(refname:short)" refs/tags | \
            while read -r entry; do
                eval "$entry"
                ref="${ref:${#prefix}}"
                echo "$ref"
            done | sort
    else
        git for-each-ref --format="%(refname:short)" refs/tags | sort
    fi
}

# alias __git_find_on_cmdline for backwards compatibility
if [ -z "`type -t __git_find_on_cmdline`" ]; then
    alias __git_find_on_cmdline=__git_find_subcommand
fi

