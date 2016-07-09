#!/usr/bin/env bash

git_current_branch () {
  local _saved_ifs _branch
  _saved_ifs=${IFS}
  IFS=:
  _branch=`git branch 2> /dev/null`
  if [ $? -eq 0 ]; then
    echo -n "$1`echo ${_branch} | grep '^*' | sed -e 's/\*\ //'`$2"
  fi
  IFS=${_saved_ifs}
}