From ruby:2.5.3-slim

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y curl git-core wget gnupg

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y imagemagick libpq-dev \
zlib1g-dev build-essential libssl-dev libreadline-dev \ 
libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \ 
libcurl4-openssl-dev software-properties-common libffi-dev nodejs

ENV INSTALL_PATH /app

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

Copy Gemfile ./

ENV BUNDLE_PATH /gems

COPY . .