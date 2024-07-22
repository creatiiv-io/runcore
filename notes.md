runcore is development environment
appcore is hosting environment

appcore has two 
deploy@appcore.run

core/config/schema.table
core/settings/name

.runcore/.settings
.runcore/.name-secret

runcore env
runcore env [name] [secret] [deploy@domain.name]

runcore settings
runcore settings category.name something

runcore config
runcore config file.name
runcore config file.name +data:with:link
runcore config file.name -data:with:link

system/actions
system/actions/development
system/actions/management
system/actions/deployment

runcore remote domain.name
runcore remote secret

.runcore/.settings
.runcore/.secret

runcore config core.reponame appcore.run
runcore config core.email email@address.com

runcore identify email@address.com
ssh-keygen -t ed25519 -C "email@address.com" -N "" -f .secret
ssh identify@runcore.app -c reponame

cat ~/.ssh/id_ed25519.pub | verify@appcore.host $totp
cat ~/.ssh/id_ed25519.pub | verify@appcore.host verify $totp

  Please enter token from your email.

runcore identify asdfasdfasdfasdfasdfasdf
ssh identify@runcore.app -c reponame asdfasdfasdfasdfasdfasdf

runcore register
(
  GIT_SSH_COMMAND='ssh -i "${RUNCORE}/.secret"'
  git archive --remote="deploy@${CORE_APPHOST}:core.git" "HEAD:${ENVNAME}" "core/settings"
) | tar -xC "$GITROOT"

runcore delegate email@address.com
ssh delegate@runcore.app -c reponame email@address.com

runcore deploy name
(
  GIT_SSH_COMMAND='ssh -i "${RUNCORE}/.secret"'
  git push -f "${deploy}:core.git" "HEAD:${ENVNAME}"
)

runcore node location-1

runcore env name

runcore branch name
runcore status
runcore commit message

runcore clone

# issues

runcore issue board ##

.issues
  type/
    statuses
    status/
      issue/
        issue.md
        user-timestamp.md
