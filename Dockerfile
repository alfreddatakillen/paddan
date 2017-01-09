FROM debian:jessie

MAINTAINER Alfred Godoy <alfred@thebrewery.se>

ENV NODE_VERSION 7.3.0

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

RUN apt-get -y update
RUN apt-get -y install curl xz-utils
RUN curl -L "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" | tar xJvf - -C /usr/local --strip-components=1
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN apt-get -y install unzip

ENV ETHERPAD_VERSION 1.6.1

WORKDIR /opt/

RUN curl -SL https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip > /tmp/etherpad.zip
RUN unzip /tmp/etherpad.zip && rm /tmp/etherpad.zip
RUN mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite
RUN chown node:node -R etherpad-lite

RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb >/tmp/dumb-init.deb
RUN dpkg -i /tmp/dumb-init.deb
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

RUN mkdir -p /data
RUN chown node:node /data

USER node
WORKDIR /opt/etherpad-lite

RUN bin/installDeps.sh
RUN npm install sqlite3
COPY settings.json settings.json

EXPOSE 9001
CMD ["bin/run.sh"]

