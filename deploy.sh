#!/bin/bash
set -o errexit -o nounset
PKG_REPO=$PWD
cd ..

addToDrat(){
  mkdir drat; cd drat

  ## Set up Repo parameters
  git init
  git config user.name "jn"
  git config user.email "tupiszakaczki@gmail.com"
  git config --global push.default simple

  ## Get drat repo
  git remote add upstream "https://$GH_TOKEN@github.com/nowosad/drat.git"
  git fetch upstream 2>err.txt
  git checkout gh-pages

  Rscript -e "drat::insertPackage('$PKG_REPO/$PKG_TARBALL', \
    repodir = '.', \
    commit='Travis update $PKG_REPO: build $TRAVIS_BUILD_NUMBER')"

  git push origin gh-pages "https://$GH_TOKEN@github.com/nowosad/drat.git"

}

addToDrat

## Other options:
## Only add if the commit is tagged: so something like:
#if [ $TRAVIS_TAG ] ; then
#   addToDrat
#fi
##but will need to edit .travis.yml since $TRAVIS_BRANCH will now equal $TRAVIS_TAG

