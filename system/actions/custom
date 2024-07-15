#!/bin/bash

# display help
function help() {
  case $1 in
    custom)
      echo "custom Docker and Caddy"
      ;;
    *)
      echo "  $RUNNAME custom"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  custom) custom ${@:2};;
esac
