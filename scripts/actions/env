#!/bin/bash

# display help
function help() {
  case $1 in
    env)
      echo "start a local dev environment"
      ;;
    *)
      echo "  $RUNNAME env"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  env) env ${@:2};;
esac
