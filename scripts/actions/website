#!/bin/bash

# display help
function help() {
  case $1 in
    website)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME website"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  website) website ${@:2};;
esac
