#!/bin/bash

# display help
function help() {
  case $1 in
    update)
      echo "update runcore to a newer version"
      ;;
    *)
      echo "  $RUNNAME update"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  update) update ${@:2};;
esac
