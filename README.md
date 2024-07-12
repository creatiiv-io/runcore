README.md

Caddyfile
docker-compose.yaml
install
runcore

/core
  /config
  /languages
  /legal
  /metadata
  /migrations
  /public
  /seeds
/system
  /init
    *.sql
  /admin
  /support
  up-development.yaml
  up-production.yaml
/scripts
  pg-init.sh
  pg-load.sh
  runcore-*.sh

app
  .env
  .runcore
  docker-compose.yaml
  
  /config
    settings -> .env
  /languages
  /legal
  /metadata
  /migrations

runcore init
runcore version
runcore help
runcore tutorial
runcore update [ver]

runcore
runcore dev
runcore mobile
runcore desktop
runcore down
runcore reset
runcore console
runcore seed
runcore sql

runcore env
runcore env [name]
runcore env [name] [secret]
runcore serve [name]
runcore deploy [name]
runcore health [name]
runcore monitor [name]
runcore publish [name]
runcore backup [name]
runcore restore [name]

RUNCORE_ENV_{NAME}=secret