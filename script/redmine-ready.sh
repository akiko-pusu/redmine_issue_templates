#!/bin/sh
cd /tmp/redmine

# switch target version of redmine
hg up ${REDMINE_TARGET}
cat << HERE >> config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3
HERE

mkdir -p /tmp/redmine/plugins/${PLUGIN_NAME}
cp -r ${WERCKER_SOURCE_DIR}/* /tmp/redmine/plugins/${PLUGIN_NAME}/
cp -r ${WERCKER_SOURCE_DIR}/.git /tmp/redmine/plugins/${PLUGIN_NAME}/

cd ${WERCKER_SOURCE_DIR}
ls -a | grep -v -E 'wercker\.yml' | xargs rm -rf

# move redmine source to wercker source directory
mv /tmp/redmine/* ./


