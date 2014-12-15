#!/bin/sh -e

git cm -am "$@"
cabal run rebuild

cd gh-deploy
git fetch
git merge origin/master
rsync -a ../_site/ .
git add .
git cm -m "Auto-update"
git push origin master

