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
cp -r source/* redmine-${REDMINE_VERSION}/plugins/${PLUGIN_NAME}/

cd source
ls -a | grep -v -E 'redmine-ready\.sh|wercker\.yml' | xargs rm -rf

mv ../redmine-${REDMINE_VERSION}/* ./
gem install simplecov simplecov-rcov yard
gem update bundler

# bundle install実施
#cd redmine-${REDMINE_VERSION}

#bundle install  --path vendor/bundle --without mysql postgreql rmagick --with test

# migration 実施
#bundle exec rake db:migrate RAILS_ENV=test
#bundle exec rake redmine:plugins:migrate RAILS_ENV=test

# ここまででRedmineの準備完了 / テストに移る
#bundle exec rake redmine:plugins:test PLUGIN=${PLUGIN_NAME}


