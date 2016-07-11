#!/usr/bin/env bash

make_change() {
    echo "New" >> file1
    git add file1
    git commit -m $1
}