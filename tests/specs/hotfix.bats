#!/usr/bin/env bats

load ../helpers/make-test-repo
load ../helpers/git-current-branch
load ../helpers/populate-example-branches
load ../helpers/make-change

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

@test "HOTFIX: finish and merge" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish 1.0.0-hotfix1 1.0.1

    git rev-parse "v1.0.1"                       #Added Tag
    ! git rev-parse "hotfix/1.0.0-hotfix1"      #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]     #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]     #Merged hotfixed changes
}

@test "HOTFIX: finish and merge message" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish -m "Merge Message" 1.0.0-hotfix1 1.0.1

    [ "$(git --no-pager log -1 --pretty=%B --decorate=short | head -n 1)" == "Merge Message" ]
}

@test "HOTFIX: finish and skip merge" {
    git stream --debug hotfix start 1.0.0 hotfix1
    make_change Hotfix
    git stream --debug hotfix finish -l 1.0.0-hotfix1 1.0.1

    git rev-parse "v1.0.1"                       #Added Tag
    ! git rev-parse "hotfix/1.0.0-hotfix1"      #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]     #Changed to master
    [ "$(cat file1 | tail -n 1)" != "New" ]     #Didn't merged hotfixed changes
}

@test "HOTFIX: list" {
    populate_example_branches

    hotfix_branches=$(git stream --debug hotfix list)
    expected_branches="$(echo -e "0.0.0-hotfix1\n0.0.0-hotfix2")"

    git branch

    [ "${hotfix_branches}" == "${expected_branches}" ]
}