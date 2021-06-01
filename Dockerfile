# define ubuntu version, you can use --build-arg
ARG ubuntu_version="20.10"
FROM ubuntu:${ubuntu_version}

ARG image_version="v1.2"

# Default nvm version, you can use --build-arg
ARG nvm_version="v0.38.0"

# Default node version, you can use --build-arg
ARG node_version="v14.17.0"

# Default ruby version, you can use --build-arg
ARG ruby_version="3.0.1"

# Default ffi version, you can use --build-arg
ARG ffi_version="1.15.1"

# Default sassc version, you can use --build-arg
ARG sassc_version="2.4.0"

# Default chromedriver version, you can use --build-arg
ARG chromedriver_version="90.0.4430.24"

# refs. https://qiita.com/yagince/items/deba267f789604643bab
ENV DEBIAN_FRONTEND=noninteractive

# Dockerfile on bash
SHELL ["/bin/bash", "-c"]

# Fast download server
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

# Install packages
RUN \
  apt update && \
  apt install --no-install-recommends  -y \
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
  unzip \
  tzdata \
  git \
  curl

# Install chrome && chromedriver && `IPA font` for selenium
RUN \
  curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list && \
  curl -L http://chromedriver.storage.googleapis.com/${chromedriver_version}/chromedriver_linux64.zip -o chromedriver_linux64.zip && \
  unzip chromedriver_linux64.zip && \
  mv chromedriver /usr/local/bin/ && \
  apt update && \
  apt install --no-install-recommends  -y google-chrome-stable
RUN \
  curl https://moji.or.jp/wp-content/ipafont/IPAexfont/IPAexfont00401.zip -o IPAexfont00401.zip && \
  unzip IPAexfont00401.zip -d ~/.fonts/ && \
  fc-cache -fv

# Install yarn
RUN \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update && \
  apt install --no-install-recommends -y yarn


# Installv nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | bash
RUN echo '. /root/.nvm/nvm.sh' > /etc/profile.d/nvm.sh
RUN \
  . /etc/profile && \
  nvm install ${node_version} && \
  nvm alias default ${node_version}

# Install rvm
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
  curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
  curl -sSL https://get.rvm.io | bash -s stable && \
  . /etc/profile.d/rvm.sh && \
  rvm install ${ruby_version} && \
  gem install bundler selenium-webdriver sassc:${sassc_version} ffi:${ffi_version}

# Remove the files
RUN \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/sh"]