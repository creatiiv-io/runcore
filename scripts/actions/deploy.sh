#!/bin/bash

# display help
function help() {
  case $1 in
    deploy)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME deploy"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  deploy) deploy ${@:2};;
esac
