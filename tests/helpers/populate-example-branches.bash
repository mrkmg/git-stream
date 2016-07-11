#!/usr/bin/env bash


populate_example_branches() {
    git checkout master >/dev/null 2>&1
    git stream --debug release start 0.0.0 >/dev/null 2>&1
    git stream --debug release finish 0.0.0 >/dev/null 2>&1

    git checkout master >/dev/null 2>&1
    git stream --debug feature start feature1 >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git stream --debug feature start feature2 >/dev/null 2>&1

    git checkout master >/dev/null 2>&1
    git stream --debug release start 0.0.1 >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git stream --debug release start 0.0.2 >/dev/null 2>&1

    git checkout master >/dev/null 2>&1
    git stream --debug hotfix start 0.0.0 hotfix1 >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git stream --debug hotfix start 0.0.0 hotfix2 >/dev/null 2>&1

    git checkout master >/dev/null 2>&1
}