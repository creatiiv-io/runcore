#!/bin/bash

# display help
function help() {
  case $1 in
    restore)
      echo "restore everything to a zipfile"
      ;;
    *)
      echo "  $RUNNAME restore"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  restore) restore ${@:2};;
esac
