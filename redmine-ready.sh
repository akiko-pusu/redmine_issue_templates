#!/bin/sh
cd ..
rm -fr redmine-*
hg clone https://bitbucket.org/redmine/redmine-all redmine-${REDMINE_VERSION}
cat << HERE >> redmine-${REDMINE_VERSION}/config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3
HERE

mkdir -p redmine-${REDMINE_VERSION}/plugins/${PLUGIN_NAME}
shopt -s dotglob
cp -r source/* redmine-${REDMINE_VERSION}/plugins/${PLUGIN_NAME}/
cp -r source/.git redmine-${REDMINE_VERSION}/plugins/${PLUGIN_NAME}/

cd source
ls -a | grep -v -E 'redmine-ready\.sh|wercker\.yml' | xargs rm -rf

shopt -s dotglob
mv ../redmine-${REDMINE_VERSION}/* ./
gem install simplecov simplecov-rcov yard
gem update bundler



