FROM ruby:2.4.2
LABEL maintainer="AKIKO TAKANO / (Twitter: @akiko_pusu)" \
  description="Image to run Redmine simply with sqlite to try/review plugin."

### get Redmine source
### Replace shell with bash so we can source files ###
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

### install default sys packeges ###

RUN apt-get update
RUN apt-get install -qq -y \
    git vim mercurial         \
    sqlite3 libmysqlclient-dev

RUN cd /tmp && hg clone https://bitbucket.org/redmine/redmine-all redmine
WORKDIR /tmp/redmine


# add database.yml (for development, development with mysql, test)
RUN echo $'test:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_test.sqlite3\n\
  encoding: utf8mb4\n\
development:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_development.sqlite3\n\
  encoding: utf8mb4\n\
development_mssql:\n\
  adapter: sqlserver\n\
  host: mssql\n\
  database: redmine_development\n\
  username: sa\n\
  password: StrongPassw0rd!\n\
development_mysql:\n\
  adapter: mysql2\n\
  host: mysql\n\
  password: pasword\n\
  database: redemine_development\n\
  username: root\n'\
>> config/database.yml

RUN gem update bundler
RUN bundle install --without postgresql rmagick
RUN bundle exec rake db:migrate