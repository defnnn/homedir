#!/usr/bin/env bash

function main {
  source ~/.bash_profile
  exec "$@"
}

main "$@"
