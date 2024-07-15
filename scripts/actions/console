#!/bin/bash

# display help
function help() {
  case $1 in
    console)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME console"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  console) console ${@:2};;
esac
