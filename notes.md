deploy@appcore.run
register

core/config/schema.table
core/settings/name

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


deploy key is environment specific


