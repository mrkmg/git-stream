#!/usr/bin/env bats

load ../helpers/make-test-repo
load ../helpers/git-current-branch

TESTING_PATH="/dev/null"
STARTING_PATH="$(pwd)"
PATH="$(pwd)/bin:$PATH"

setup() {
    TESTING_PATH=`mktemp -d 2>/dev/null || mktemp -d -t 'git-stream-test'`
    rm -rf ${TESTING_PATH}
    make_test_repo ${TESTING_PATH}
    cd ${TESTING_PATH}
    git stream init -d >/dev/null
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "RELEASE: start" {
    run git stream release start 1.0.0

    git rev-parse "release/1.0.0" >/dev/null 2>&1
}

@test "FEATURE: finish" {
    run git stream release start 1.0.0
    echo "New" >> file1
    run git add file1
    run git commit -m "Release 1.0.0"
    run git stream release finish 1.0.0

    git rev-parse "1.0.0" >/dev/null 2>&1                   #Added Tag
    ! git rev-parse "release/1.0.0" >/dev/null 2>&1         #Removed release branch
    [ "$(git_current_branch)" == "master" ]                 #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]                 #Merged release changes
}