#!/bin/bash

# display help
function help() {
  case $1 in
    serve)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME serve"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  serve) serve ${@:2};;
esac
