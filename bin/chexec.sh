#!/usr/bin/env bash

function main {
  source ~/.bash_profile

  set -efu
  cd "$1"; shift
  exec "$@"
}

main "$@"
