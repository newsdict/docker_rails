# define ubuntu version, you can use --build-arg
ARG ubuntu_version="19.10"
FROM ubuntu:${ubuntu_version}

# Dockerfile on bash
SHELL ["/bin/bash", "-c"]

# default node version, you can use --build-arg
ARG node_version="v12.11.1"

# default ruby version, you can use --build-arg
ARG ruby_version="2.6.5"

# default nvm version, you can use --build-arg
ARG nvm_version="0.35.0"

# fast download server
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

# install packages
RUN apt update \
  && apt install --no-install-recommends -y gnupg2 gnupg1 gnupg git curl libmecab-dev mecab-ipadic mecab-ipadic-utf8 mecab-utils libmagickwand-dev openjdk-8-jdk graphicsmagick graphviz nginx

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update \
  && apt install --no-install-recommends -y yarn

# installv nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash
ENV NVM_DIR "/root/.nvm"
RUN . ${NVM_DIR}/nvm.sh \
  && nvm install ${node_version} \
  && nvm alias default ${node_version}

# install rvm
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - \
  && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - \
  && curl -sSL https://get.rvm.io | bash -s stable \
  && . /etc/profile.d/rvm.sh \
  && rvm install ${ruby_version} \
  && gem install bundler

# remove the files
RUN apt-get remove -y curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
CMD ["/bin/sh"]
