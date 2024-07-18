runcore is development environment
appcore is hosting environment

deploy@appcore.run

core/config/schema.table
core/settings

.runcore/.settings
.runcore/.name-secret

runcore env
runcore env [name] [secret]


runcore settings
runcore settings category.name something

runcore config file.name
runcore config file.name +data:with:link
pg_dataadd file.name line:with:data
runcore config file.name -data:with:link
pg_datadel file.name line:with:data
runcore config file.name +
pg_dataload file.name
runcore config file.name =
pg_datadump file.name


runcore login domain.name
login@domain.name

email:

runcore deploy name


.issues
  number/
  issue.md
  comment-user-timestamp.md
