#!/bin/bash

# display help
function help() {
  case $1 in
    seed)
      echo "seed databse"
      ;;
    *)
      echo "  $RUNNAME seed"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  seed) seed ${@:2};;
esac
