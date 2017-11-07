#!/bin/sh
cd gh-pages
git rm -rf .
cd ..

# create new version
cd blog
hugo -t slim -d ../new-gh-pages
cd ..

echo "mrbuk.de" > new-gh-pages/CNAME
cp -R gh-pages/.git* new-gh-pages/

cd new-gh-pages
git config --global user.email "co-pilot@doesnt.exist"
git config --global user.name "Co-Pilot"

git add .
git commit -m 'autobuild'
