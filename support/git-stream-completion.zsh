#!zsh
#
# Author: Copyright 2016 Kevin Gravier
#
#  Original Author: Copyright 2012-2013 Peter van der Does.
#
#  Original Author: Copyright (c) 2011 Justin Hileman
#
#  Distributed under the MIT License

_git-stream ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '--debug[Enable Debug Mode]'\
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'init:Initialize an existing git repo with Git Stream.'
                'feature:Manage your feature branches.'
                'release:Manage your release branches.'
                'hotfix:Manage your hotfix branches.'
                'version:Shows version information.'
            )
            _describe -t commands 'git stream' subcommands
        ;;

        (options)
            case $line[1] in

                (init)
                _arguments \
                    -f'[Force setting of gitstream branches, even if already configured]'\
                    -d'[Use the default configuration]'\
                    --version-prefix'[Version Prefix]:version-prefix'\
                    --feature-prefix'[Feature Prefix]:feature-prefix'\
                    --release-prefix'[Release Prefix]:release-prefix'\
                    --hotfix-prefix'[Hotfix Prefix]:hotfix-prefix'\
                    --working-branch'[Working Branch]:branch:__git_branch_names'
                ;;

                (hotfix)
                    __git-stream-hotfix
                ;;

                (release)
                    __git-stream-release
                ;;

                (feature)
                    __git-stream-feature
                ;;

            esac
        ;;
    esac
}

__git-stream-release ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:Start a new release branch.'
                'finish:Finish a release branch.'
                'list:List all your release branches.'
            )
            _describe -t commands 'git stream release' subcommands
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        ':version'
                ;;

                (finish)
                    _arguments \
                        {-m,--message}'[Use the given tag message]:message'\
                        {-n,--no-ff}'[No Fast-Forward]'\
                        {-d,--no-merge}'[Do not merge the release branch back into the working branch]'\
                        {-l,--leave}'[Do not delete the release branch]'\
                        ':release:__git_stream_release_list'
                ;;
            esac
        ;;
    esac
}

__git-stream-hotfix ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:Start a new hotfix branch.'
                'finish:Finish a hotfix branch.'
                'list:List all your hotfix branches.'
            )
            _describe -t commands 'git stream hotfix' subcommands
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        ':version:__git_stream_version_list'\
                        ':branch-name'
                ;;

                (finish)
                    _arguments \
                        {-m,--message}'[Use the given tag message]:message'\
                        {-n,--no-ff}'[No Fast-Forward]'\
                        ':hotfix:__git_stream_version_list'\
                        ':branch-name:__git_stream_hotfix_list'\
                        ':new-version'
                ;;
            esac
        ;;
    esac
}

__git-stream-feature ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:Start a new feature branch.'
                'finish:Finish a feature branch.'
                'list:List all your feature branches.'
                'update:Rebase a feature branch to master.'
            )
            _describe -t commands 'git stream feature' subcommands
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        ':feature'
                ;;

                (finish)
                    _arguments \
                        {-m,--message}'[Use the given tag message]:message'\
                        {-n,--no-ff}'[No Fast-Forward]'\
                        ':feature:__git_stream_feature_list'
                ;;

                (finish)
                    _arguments \
                        ':feature:__git_stream_feature_list'
                ;;

            esac
        ;;
    esac
}

__git_stream_version_list ()
{
    local expl
    declare -a versions

    versions=(${${(f)"$(_call_program versions git tag 2> /dev/null)"}})
    __git_command_successful || return

    _wanted versions expl 'version' compadd $versions
}

__git_stream_feature_list ()
{
    local expl
    declare -a features

    features=(${${(f)"$(_call_program features git stream feature list 2> /dev/null)"}})
    __git_command_successful || return

    _wanted features expl 'feature' compadd $features
}

__git_stream_release_list ()
{
    local expl
    declare -a releases

    releases=(${${(f)"$(_call_program releases git stream release list 2> /dev/null)"}})
    __git_command_successful || return

    _wanted releases expl 'release' compadd $releases
}


__git_stream_hotfix_list ()
{
    local expl
    declare -a hotfixes

    hotfixes=(${${(f)"$(_call_program hotfixes git stream hotfix list 2> /dev/null)"}})
    __git_command_successful || return

    _wanted hotfixes expl 'hotfix' compadd $hotfixes
}

__git_branch_names () {
    local expl
    declare -a branch_names

    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
    __git_command_successful || return

    _wanted branch-names expl branch-name compadd $* - $branch_names
}

__git_command_successful () {
    if (( ${#pipestatus:#0} > 0 )); then
        _message 'not a git repository'
        return 1
    fi
    return 0
}

zstyle ':completion:*:*:git:*' user-commands stream:'provide high-level repository operations'
