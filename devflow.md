runcore init
git add *
git commit -m "init runcore"
runcore up
runcore console
git add *
git commit -m "added database"
cd public/
vim index.html
runcore website
git add *
git commit -m "added webfiles"
runcore down

runcore settings deploy.servicehost appcore.host

runcore identify asdf@example.com
runcore identify code:sadfasdfasdfasdfasdf

runcore delegate otherdev@example.com

runcore link 

runcore enviroment production
runcore settings deploy.appdomain example.com
runcore deploy production

runcore hosting

runcore watch 1234124/production


