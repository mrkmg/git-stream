#!/usr/bin/env bats

load ../helpers/make-test-repo
load ../helpers/git-current-branch
load ../helpers/populate-example-branches
load ../helpers/make-change
load ../helpers/create-hooks

TESTING_PATH="/dev/null"
TESTING_REMOTE="/dev/null"
STARTING_PATH="$(pwd)"
PATH="$(pwd)/bin:$PATH"

setup() {
    TESTING_PATH=`mktemp -d 2>/dev/null || mktemp -d -t 'git-stream-test'`
    TESTING_REMOTE=`mktemp -d 2>/dev/null || mktemp -d -t 'git-stream-test'`
    rm -rf ${TESTING_PATH}
    rm -rf ${TESTING_REMOTE}
    make_test_repo ${TESTING_PATH} ${TESTING_REMOTE}
    cd ${TESTING_PATH}
    git stream --debug init -d --version-prefix 'v' >/dev/null
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "FEATURE: start" {
    git stream --debug feature start feature1

    git rev-parse "feature/feature1"
}

@test "FEATURE: start with successful pre hook" {
    create_hook_success pre feature start

    OUTPUT=$(git stream feature start feature1)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "feature/feature1"
}

@test "FEATURE: start with failure pre hook" {
    create_hook_failure pre feature start

    ! OUTPUT=$(git stream feature start feature1)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "feature/feature1"
}

@test "FEATURE: start with successful post hook" {
    create_hook_success post feature start

    OUTPUT=$(git stream feature start feature1)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "feature/feature1"
}

@test "FEATURE: start with failure post hook" {
    create_hook_failure post feature start

    OUTPUT=$(git stream feature start feature1)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    git rev-parse "feature/feature1"
}

@test "FEATURE: finish" {
    git stream --debug feature start feature1
    make_change feature1
    git stream --debug feature finish feature1

    ! git rev-parse "feature/feature1"        #Removed Branch
    [ "$(git_current_branch)" == "master" ]   #Put back on master
    [ "$(cat file1 | tail -n 1)" == "New" ]   #Merged change
    [ $(git rev-parse HEAD) == $(git rev-parse @{u}) ]      #Pushed changes
}

@test "FEATURE: finish with message" {
    git stream --debug feature start feature1
    make_change feature1
    git stream --debug feature finish -m "Merge Message" feature1

    [ "$(git --no-pager log -1 --pretty=%B --decorate=short | head -n 1)" == "Merge Message" ]
}

@test "FEATURE: finish and leave" {
    git stream --debug feature start feature1
    make_change feature1
    git stream --debug feature finish -l feature1

    git rev-parse "feature/feature1"        #Kept Branch
}

@test "FEATURE: finish and no push" {
    git stream --debug feature start feature1
    make_change feature1
    git stream --debug feature finish -p feature1

    ! git rev-parse "feature/feature1"        #Removed Branch
    [ "$(git_current_branch)" == "master" ]   #Put back on master
    [ "$(cat file1 | tail -n 1)" == "New" ]   #Merged change
    [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]      #Didn't push changes
}

@test "FEATURE: finish with successful pre hook" {
    create_hook_success pre feature finish

    git stream --debug feature start feature1
    make_change feature1
    OUTPUT=$(git stream --debug feature finish feature1)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "feature/feature1"

}

@test "FEATURE: finish with failure pre hook" {
    create_hook_failure pre feature finish

    git stream --debug feature start feature1
    make_change feature1
    ! OUTPUT=$(git stream --debug feature finish feature1)

    [[ "$OUTPUT" == *"Bad"* ]]       # Hook did run
    git rev-parse "feature/feature1" # Canceled merge
}


@test "FEATURE: finish with successful post hook" {
    create_hook_success post feature finish

    git stream --debug feature start feature1
    make_change feature1
    OUTPUT=$(git stream --debug feature finish feature1)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "feature/feature1"
}


@test "FEATURE: finish with failure post hook" {
    create_hook_failure post feature finish

    git stream --debug feature start feature1
    make_change feature1
    OUTPUT=$(git stream --debug feature finish feature1)

    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "feature/feature1"
}

@test "FEATURE: list" {
    populate_example_branches

    feature_branches=$(git stream --debug feature list)
    expected_branches="$(echo -e "feature1\nfeature2")"

    [ "${feature_branches}" == "${expected_branches}" ]
}
