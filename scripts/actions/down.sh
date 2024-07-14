#!/bin/bash

# display help
function help() {
  case $1 in
    down)
      echo "stop a local dev environment"
      ;;
    *)
      echo "  $RUNNAME down"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  down) down ${@:2};;
esac

