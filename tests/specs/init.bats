#!/usr/bin/env bats

load ../helpers/make-test-repo

TESTING_PATH="/dev/null"
STARTING_PATH="$(pwd)"
PATH="$(pwd)/bin:$PATH"

setup() {
    TESTING_PATH=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
    rm -rf ${TESTING_PATH}
    make_test_repo ${TESTING_PATH}
    cd ${TESTING_PATH}
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
}

@test "INIT: default options" {
    git stream init -d

    [ "$(git config gitstream.branch.working)" == "master" ]
    [ "$(git config gitstream.prefix.feature)" == "feature/" ]
    [ "$(git config gitstream.prefix.hotfix)" == "hotfix/" ]
    [ "$(git config gitstream.prefix.release)" == "release/" ]
    [ "$(git config gitstream.prefix.version)" == "" ]
}

@test "INIT: cli options" {
    git stream init --version-prefix "v" --feature-prefix "f"  --hotfix-prefix "h"  --release-prefix "r" --working-branch "w"

    [ "$(git config gitstream.branch.working)" == "w" ]
    [ "$(git config gitstream.prefix.feature)" == "f" ]
    [ "$(git config gitstream.prefix.hotfix)" == "h" ]
    [ "$(git config gitstream.prefix.release)" == "r" ]
    [ "$(git config gitstream.prefix.version)" == "v" ]
}

@test "INIT: interactive" {
    (
        echo "i_v"
        echo "i_f"
        echo "i_h"
        echo "i_r"
        echo "i_w"
    ) | git stream init

    [ "$(git config gitstream.branch.working)" == "i_w" ]
    [ "$(git config gitstream.prefix.feature)" == "i_f" ]
    [ "$(git config gitstream.prefix.hotfix)" == "i_h" ]
    [ "$(git config gitstream.prefix.release)" == "i_r" ]
    [ "$(git config gitstream.prefix.version)" == "i_v" ]
}