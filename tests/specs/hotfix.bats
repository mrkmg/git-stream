#!/usr/bin/env bats

load ../helpers/make-test-repo
load ../helpers/git-current-branch
load ../helpers/populate-example-branches

TESTING_PATH="/dev/null"
STARTING_PATH="$(pwd)"
PATH="$(pwd)/bin:$PATH"

setup() {
    TESTING_PATH=`mktemp -d 2>/dev/null || mktemp -d -t 'git-stream-test'`
    rm -rf ${TESTING_PATH}
    make_test_repo ${TESTING_PATH}
    cd ${TESTING_PATH}
    git stream init -d >/dev/null
    git stream release start 1.0.0
    git stream release finish 1.0.0
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "HOTFIX: start" {
    run git stream hotfix start 1.0.0 hotfix1

    git rev-parse "hotfix/1.0.0-hotfix1" >/dev/null 2>&1
}

@test "HOTFIX: finish and merge" {
    run git stream hotfix start 1.0.0 hotfix1
    echo "New" >> file1
    run git add file1
    run git commit -m "Hotfix"
    run git stream hotfix finish 1.0.0 hotfix1 1.0.1

    git rev-parse "1.0.1" >/dev/null 2>&1                   #Added Tag
    ! git rev-parse "hotfix/1.0.0-hotfix1" >/dev/null 2>&1  #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]                 #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]                 #Merged hotfixed changes
}

@test "HOTFIX: finish and skip merge" {
    run git stream hotfix start 1.0.0 hotfix1
    echo "New" >> file1
    run git add file1
    run git commit -m "Hotfix"
    run git stream hotfix finish -n 1.0.0 hotfix1 1.0.1

    git rev-parse "1.0.1" >/dev/null 2>&1                   #Added Tag
    ! git rev-parse "hotfix/1.0.0-hotfix1" >/dev/null 2>&1  #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]                 #Changed to master
    [ "$(cat file1 | tail -n 1)" != "New" ]                 #Merged hotfixed changes
}

@test "HOTFIX: list" {
    run populate_example_branches

    release_branches=$(git stream hotfix list)
    expected_branches="$(echo -e "0.0.0-hotfix1\n0.0.0-hotfix2")"

    git branch

    echo ${release_branches}
#    echo ${expected_branches}

    [ "${release_branches}" == "${expected_branches}" ]
}