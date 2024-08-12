runcore settings
runcore settings category.name something

runcore config
runcore config file.name
runcore config file.name +data:with:link
runcore config file.name -data:with:link

.runcore/.settings
.runcore/.secret

runcore config deploy.server appcore.run

runcore identify email@address.com
ssh-keygen -t ed25519 -C "email@address.com" -N "" -f .identity
ssh identify@runcore.app -c reponame

runcore identify --global email@address.com
.runcore/.identity
~/.runcore-identity

cat ~/.ssh/id_ed25519.pub | verify@appcore.host $totp
cat ~/.ssh/id_ed25519.pub | verify@appcore.host verify $totp

  Please enter token from your email.

runcore identify asdfasdfasdfasdfasdfasdf
ssh identify@runcore.app -c reponame asdfasdfasdfasdfasdfasdf

.runcore/.secret

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
