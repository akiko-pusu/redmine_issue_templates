#!/bin/sh
cd /tmp/redmine

# switch target version of redmine
hg pull
cat << HERE >> config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3
HERE

# move redmine source to wercker source directory
rm -fr ${WERCKER_OUTPUT_DIR}/*
mkdir -p ${WERCKER_OUTPUT_DIR}
mkdir -p ${WERCKER_OUTPUT_DIR}/plugins/${WERCKER_APPLICATION_NAME}
cp -fr /tmp/redmine/* ${WERCKER_OUTPUT_DIR}
cp -fr /tmp/redmine/.* ${WERCKER_OUTPUT_DIR}
cp ${WERCKER_SOURCE_DIR}/Gemfile.local ${WERCKER_OUTPUT_DIR}/
cp -r ${WERCKER_SOURCE_DIR}/* ${WERCKER_OUTPUT_DIR}/plugins/${WERCKER_APPLICATION_NAME}/
cp -r ${WERCKER_SOURCE_DIR}/ ${WERCKER_OUTPUT_DIR}/plugins/${WERCKER_APPLICATION_NAME}/

