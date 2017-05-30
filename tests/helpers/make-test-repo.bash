#!/usr/bin/env bash

make_test_repo() {
    local location remotelocation cwd

    location=$1
    remotelocation=$2

    if [ -a ${location} ]; then
        echo "${location} already exists."
        exit 1
    fi

    if [ -a ${remotelocation} ]; then
        echo "${remotelocation} already exists."
        exit 1
    fi

    mkdir ${location}
    cd ${location}

    (
       echo "Example 1"
       echo
       echo "Test"
    ) > file1

    (
        echo "Example 2"
        echo
        echo "Test"
    ) > file2

    git init >/dev/null 2>&1
    git add . >/dev/null 2>&1
    git commit -m "initial" >/dev/null 2>&1

    git clone --bare ${location} ${remotelocation} >/dev/null 2>&1

    git remote add origin file://${remotelocation} >/dev/null 2>&1

    git push origin -u master

    cd ${cwd}
}
