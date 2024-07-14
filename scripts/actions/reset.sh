#!/bin/bash

# display help
function help() {
  case $1 in
    reset)
      echo "reset database"
      ;;
    *)
      echo "  $RUNNAME reset"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  reset) reset ${@:2};;
esac
