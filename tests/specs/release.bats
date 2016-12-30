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
    git stream init -d --version-prefix 'v' >/dev/null
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "RELEASE: start" {
    run git stream --debug release start 1.0.0

    git rev-parse "release/v1.0.0" >/dev/null 2>&1
}

@test "RELEASE: start with successful pre hook" {
    create_hook_success pre release start

    OUTPUT=$(git stream release start 1.0.0)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "release/v1.0.0"
}

@test "RELEASE: start with failure pre hook" {
    create_hook_failure pre release start

    ! OUTPUT=$(git stream release start 1.0.0)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "release/v1.0.0"
}

@test "RELEASE: start with successful post hook" {
    create_hook_success post release start

    OUTPUT=$(git stream release start 1.0.0)
    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    git rev-parse "release/v1.0.0"
}

@test "RELEASE: start with failure post hook" {
    create_hook_failure post release start

    OUTPUT=$(git stream release start 1.0.0)
    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    git rev-parse "release/v1.0.0"
}

@test "RELEASE: finish" {
    run git stream --debug release start 1.0.0
    make_change Release >/dev/null 2>&1
    run git stream --debug release finish 1.0.0

    git rev-parse "v1.0.0" >/dev/null 2>&1                  #Added Tag
    ! git rev-parse "release/v1.0.0" >/dev/null 2>&1        #Removed release branch
    [ "$(git_current_branch)" == "master" ]                 #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]                 #Merged release changes
}

@test "RELEASE: finish with message" {
    git stream --debug release start 1.0.0
    make_change Release
    git stream --debug release finish -m "Merge Message" 1.0.0

    [ "$(git --no-pager log -1 --pretty=%B --decorate=short | head -n 1)" == "Merge Message" ]
}

@test "RELEASE: finish and skip merge" {
    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    run git stream --debug release finish -d 1.0.0

    git rev-parse "v1.0.0" >/dev/null 2>&1      #Added Tag
    ! git rev-parse "release/v1.0.0"            #Removed hotfix branch
    [ "$(git_current_branch)" == "master" ]     #Changed to master
    [ "$(cat file1 | tail -n 1)" != "New" ]     #Didn't merge release
}

@test "RELEASE: finish and leave" {
    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    run git stream --debug release finish -l 1.0.0

    git rev-parse "v1.0.0" >/dev/null 2>&1      #Added Tag
    git rev-parse "release/v1.0.0"              #Kept hotfix branch
    [ "$(git_current_branch)" == "master" ]     #Changed to master
    [ "$(cat file1 | tail -n 1)" == "New" ]     #Merged release changes
}

@test "RELEASE: finish with successful pre hook" {
    create_hook_success pre release finish

    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    OUTPUT=$(git stream --debug release finish 1.0.0)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "release/v1.0.0"

}

@test "RELEASE: finish with failure pre hook" {
    create_hook_failure pre release finish

    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    ! OUTPUT=$(git stream --debug release finish 1.0.0)

    [[ "$OUTPUT" == *"Bad"* ]]       # Hook did run
    git rev-parse "release/v1.0.0" # Canceled merge
}


@test "RELEASE: finish with successful post hook" {
    create_hook_success post release finish

    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    OUTPUT=$(git stream --debug release finish 1.0.0)

    [[ "$OUTPUT" == *"Good"* ]]  # Hook did run
    ! git rev-parse "release/v1.0.0"
}


@test "RELEASE: finish with failure post hook" {
    create_hook_failure post release finish

    run git stream --debug release start 1.0.0
    make_change Release > /dev/null 2>&1
    OUTPUT=$(git stream --debug release finish 1.0.0)
    echo "$OUTPUT"

    [[ "$OUTPUT" == *"Bad"* ]]  # Hook did run
    ! git rev-parse "release/v1.0.0"
}

@test "RELEASE: list" {
    run populate_example_branches

    release_branches=$(git stream release list)
    expected_branches="$(echo -e "v0.0.1\nv0.0.2")"

    [ "${release_branches}" == "${expected_branches}" ]
}
