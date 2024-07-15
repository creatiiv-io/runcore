#!/bin/bash

# display help
function help() {
  case $1 in
    backup)
      echo "backup everything to a zipfile"
      ;;
    *)
      echo "  $RUNNAME backup"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  backup) backup ${@:2};;
esac
