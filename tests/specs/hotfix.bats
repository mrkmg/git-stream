#!/usr/bin/env bats

load ../helpers/make-test-repo
load ../helpers/git-current-branch
load ../helpers/populate-example-branches
load ../helpers/make-change
load ../helpers/create-hooks

TESTING_PATH="/dev/null"
STARTING_PATH="$(pwd)"
PATH="$(pwd)/bin:$PATH"

setup() {
    TESTING_PATH=`mktemp -d 2>/dev/null || mktemp -d -t 'git-stream-test'`
    rm -rf ${TESTING_PATH}
    make_test_repo ${TESTING_PATH}
    cd ${TESTING_PATH}
    git stream --debug init -d --version-prefix 'v' >/dev/null
    git stream --debug release start 1.0.0
    git stream --debug release finish 1.0.0
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "HOTFIX: start" {
    git stream --debug hotfix start 1.0.0 hotfix1

    git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: start with successful pre hook" {
    create_hook_success pre hotfix start

    OUTPUT=$(git stream hotfix start 1.0.0 hotfix1)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: start with failure pre hook" {
    create_hook_failure pre hotfix start

    ! OUTPUT=$(git stream hotfix start 1.0.0 hotfix1)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: start with successful post hook" {
    create_hook_success post hotfix start

    OUTPUT=$(git stream hotfix start 1.0.0 hotfix1)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: start with failure post hook" {
    create_hook_failure post hotfix start

    OUTPUT=$(git stream hotfix start 1.0.0 hotfix1)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: finish and merge" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1

    git rev-parse "v1.0.1"                      #Added Tag
    ! git rev-parse "hotfix/1.0.0-hotfix1"      #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]     #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]     #Merged hotfixed changes
}

@test "HOTFIX: finish and merge message" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish -m "Merge Message" 1.0.0-hotfix1 1.0.1

    [ "$(git --no-pager log -1 --pretty=%B --decorate=short | head -n 1)" == "Merge Message" ] #Has merge message
}

@test "HOTFIX: finish and leave branch" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish -l 1.0.0-hotfix1 1.0.1

    git rev-parse "hotfix/1.0.0-hotfix1"        #Kept hotfix branch
}

@test "HOTFIX: finish and skip merge" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish -d 1.0.0-hotfix1 1.0.1

    [ "$(cat file1 | tail -n 1)" != "New" ]     #Didn't merge hotfixed changes
}

@test "HOTFIX: finish with successful pre hook" {
    create_hook_success pre hotfix finish

    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    OUTPUT=$(git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "hotfix/1.0.0-hotfix1"

}

@test "HOTFIX: finish with failure pre hook" {
    create_hook_failure pre hotfix finish

    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    ! OUTPUT=$(git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1)

    [[ "$OUTPUT" == *"Bad"* ]]       # Hook did run
    git rev-parse "hotfix/1.0.0-hotfix1" # Canceled merge
}


@test "HOTFIX: finish with successful post hook" {
    create_hook_success post hotfix finish

    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    OUTPUT=$(git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "hotfix/1.0.0-hotfix1"
}


@test "HOTFIX: finish with failure post hook" {
    create_hook_failure post hotfix finish

    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    OUTPUT=$(git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1)

    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "hotfix/1.0.0-hotfix1"
}

@test "HOTFIX: list" {
    populate_example_branches

    hotfix_branches=$(git stream --debug hotfix list)
    expected_branches="$(echo -e "0.0.0-hotfix1\n0.0.0-hotfix2")"

    git branch

    [ "${hotfix_branches}" == "${expected_branches}" ] #Branchs matc
}
