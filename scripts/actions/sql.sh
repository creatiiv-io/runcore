#!/bin/bash

# display help
function help() {
  case $1 in
    sql)
      echo "start console"
      ;;
    *)
      echo "  $RUNNAME sql"
      ;;
  esac
}

# run something
case $1 in
  help) help ${@:2};;
  sql) sql ${@:2};;
esac
