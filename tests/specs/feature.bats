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
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "FEATURE: start" {
    run git stream feature start feature1

    git rev-parse "feature/feature1" >/dev/null 2>&1
}

@test "FEATURE: finish" {
    run git stream feature start feature1
    echo "New" >> file1
    run git add file1
    run git commit -m feature1
    run git stream feature finish feature1

    ! git rev-parse "feature/feature1" >/dev/null 2>&1      #Removed Branch
    [ "$(git_current_branch)" == "master" ]                 #Put back on master
    [ "$(cat file1 | tail -n 1)" == "New" ]                 #Merged change
}

@test "FEATURE: list" {
    run populate_example_branches

    feature_branches=$(git stream feature list)
    expected_branches="$(echo -e "feature1\nfeature2")"

    [ "${feature_branches}" == "${expected_branches}" ]
}