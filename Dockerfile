FROM ruby:2.6
LABEL maintainer="AKIKO TAKANO / (Twitter: @akiko_pusu)" \
  description="Image to run Redmine simply with sqlite to try/review plugin."

### get Redmine source
### Replace shell with bash so we can source files ###
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

### install default sys packeges ###

RUN apt-get update
RUN apt-get install -qq -y \
    git vim        \
    sqlite3 default-libmysqlclient-dev
RUN apt-get install -qq -y build-essential libc6-dev

# for e2e test env
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update && apt-get install -y google-chrome-stable
RUN google-chrome --version | perl -pe 's/([^0-9]+)([0-9]+)(\.[0-9]+).+/$2/g' > chrome-version-major
RUN curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE_`cat chrome-version-major` > chrome-version
RUN curl -O -L http://chromedriver.storage.googleapis.com/`cat chrome-version`/chromedriver_linux64.zip && rm chrome-version*
RUN unzip chromedriver_linux64.zip && mv chromedriver /usr/local/bin

RUN cd /tmp && svn co http://svn.redmine.org/redmine/trunk redmine
WORKDIR /tmp/redmine

COPY . /tmp/redmine/plugins/redmine_issue_templates/


# add database.yml (for development, development with mysql, test)
RUN echo $'test:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_test.sqlite3\n\
  encoding: utf8mb4\n\
development:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_development.sqlite3\n\
  encoding: utf8mb4\n\
development_mysql:\n\
  adapter: mysql2\n\
  host: mysql\n\
  password: pasword\n\
  database: redemine_development\n\
  username: root\n'\
>> config/database.yml

RUN gem update bundler
RUN bundle install
RUN bundle exec rake db:migrate
EXPOSE  3000
CMD ["rails", "server", "-b", "0.0.0.0"]
