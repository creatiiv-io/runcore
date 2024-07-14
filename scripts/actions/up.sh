#!/bin/bash

# display help
function help() {
  case $1 in
    up)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME up"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  up) up ${@:2};;
esac
