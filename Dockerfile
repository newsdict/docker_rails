# define ubuntu version, you can use --build-arg
ARG ubuntu_version="20.10"
FROM ubuntu:${ubuntu_version}

# refs. https://qiita.com/yagince/items/deba267f789604643bab
ENV DEBIAN_FRONTEND=noninteractive

# Dockerfile on bash
SHELL ["/bin/bash", "-c"]

# Default nvm version, you can use --build-arg
ARG nvm_version="0.35.2"

# Default node version, you can use --build-arg
ARG node_version="v14.3.0"

# Default ruby version, you can use --build-arg
ARG ruby_version="2.7.1"

# Default ffi version, you can use --build-arg
ARG ffi_version="1.13.1"

# Default sassc version, you can use --build-arg
ARG sassc_version="2.4.0"

# Fast download server
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

# Install packages
RUN apt update \
  && apt install --no-install-recommends  -y \
  gnupg2 \
  gnupg1 \
  gnupg \
  libmagickwand-dev \
  libmecab-dev \
  libxslt-dev \
  mecab-ipadic \
  mecab-ipadic-utf8 \
  mecab-utils \
  openjdk-8-jdk \
  graphicsmagick \
  graphviz \
  nginx \
  python2 \
  git \
  curl

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update \
  && apt install --no-install-recommends -y yarn

# Installv nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash
ENV NVM_DIR "/root/.nvm"
RUN . ${NVM_DIR}/nvm.sh \
  && nvm install ${node_version} \
  && nvm alias default ${node_version}

# Install rvm
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - \
  && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - \
  && curl -sSL https://get.rvm.io | bash -s stable \
  && . /etc/profile.d/rvm.sh \
  && rvm install ${ruby_version} \
  && gem install bundler

# Install sassc. For fast install of gem.
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc
RUN . /etc/profile.d/rvm.sh && \
  gem install "sassc:${sassc_version}" "ffi:${ffi_version}"

# Install chrome && chromedriver && `IPA font` for selenium
RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt update \
    && apt install --no-install-recommends -y google-chrome-stable unzip
RUN curl -L http://chromedriver.storage.googleapis.com/$(curl http://chromedriver.storage.googleapis.com/LATEST_RELEASE )/chromedriver_linux64.zip -o chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip \
    && mv chromedriver /usr/local/bin/
RUN . /etc/profile.d/rvm.sh && \
    gem install selenium-webdriver
RUN curl https://ipafont.ipa.go.jp/IPAexfont/IPAexfont00401.zip -o IPAexfont00401.zip \
    && unzip IPAexfont00401.zip -d ~/.fonts/ \
    && fc-cache -fv

# Remove the files
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/sh"]
