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
  /seeds
  /public
/system
  development.yaml
  production.yaml
  /init
    *.sql
  /admin
  /support
/scripts
  pg-load.sh
  pg-seed.sh
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

runcore up
runcore down
runcore backup
runcore update [ver]

runcore console
runcore clear
runcore seed
runcore sql

runcore serve [secret]
runcore secret [secret]
runcore deploy [secret]
runcore health [secret]

runcore mobile
runcore publish [secret]

