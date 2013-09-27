#!/bin/bash
mkdir krakatoa-experimental && cd krakatoa-experimental

git init
git config core.sparsecheckout true
touch .git/info/sparse-checkout

git remote add origin git@github.com:krakatoa/experimental.git
git pull origin master

echo $1/ > .git/info/sparse-checkout
git checkout

# rm ./bootstrap.sh
