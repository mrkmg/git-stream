#!/usr/bin/env bats

load ../helpers/make-test-repo

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
}

teardown() {
    cd ${STARTING_PATH}
    rm -rf ${TESTING_PATH}
    rm -rf ${TESTING_REMOTE}
}

@test "INIT: default options" {
    git stream --debug init -d

    [ "$(git config gitstream.branch.working)" == "master" ]
    [ "$(git config gitstream.prefix.feature)" == "feature/" ]
    [ "$(git config gitstream.prefix.hotfix)" == "hotfix/" ]
    [ "$(git config gitstream.prefix.release)" == "release/" ]
    [ "$(git config gitstream.prefix.version)" == "" ]
    [ "$(git config gitstream.defaultpushremote)" == "origin" ]
}

@test "INIT: cli options" {
    git stream --debug init --version-prefix "c_v" --feature-prefix "c_f"  --hotfix-prefix "c_h"  --release-prefix "c_r" --working-branch "c_w" --default-push-remote "c_p"

    [ "$(git config gitstream.branch.working)" == "c_w" ]
    [ "$(git config gitstream.prefix.feature)" == "c_f" ]
    [ "$(git config gitstream.prefix.hotfix)" == "c_h" ]
    [ "$(git config gitstream.prefix.release)" == "c_r" ]
    [ "$(git config gitstream.prefix.version)" == "c_v" ]
    [ "$(git config gitstream.defaultpushremote)" == "c_p" ]
}

@test "INIT: interactive" {
    (
        echo "i_v"
        echo "i_f"
        echo "i_h"
        echo "i_r"
        echo "i_w"
        echo "i_p"
    ) | git stream --debug init

    [ "$(git config gitstream.branch.working)" == "i_w" ]
    [ "$(git config gitstream.prefix.feature)" == "i_f" ]
    [ "$(git config gitstream.prefix.hotfix)" == "i_h" ]
    [ "$(git config gitstream.prefix.release)" == "i_r" ]
    [ "$(git config gitstream.prefix.version)" == "i_v" ]
    [ "$(git config gitstream.defaultpushremote)" == "i_p" ]
}
