FROM debian:latest

## etherpad setup

RUN adduser --system --home=/opt/etherpad --group etherpad

## install dependencies

RUN apt-get update && apt-get install -y \
gzip \
git-core \
curl \
python \
libssl-dev \
build-essential \
abiword \
python-software-properties

## install nodejs & npm

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get install -y nodejs


## create service for etherpad


RUN mkdir /var/log/etherpad-lite \

	&& touch /var/log/etherpad-lite/etherpad-lite.log \
	&& chown etherpad.etherpad /var/log/etherpad-lite \
	&& chmod -R 777 /var/log/etherpad-lite

##  create file etherpad-lite under /etc/init.d
COPY  etherpad-lite /etc/init.d/

## Install and run etherpad-lite



ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true 

USER etherpad

RUN cd /opt/etherpad \
	&& git clone git://github.com/ether/etherpad-lite.git 

WORKDIR /opt/etherpad/etherpad-lite

ENTRYPOINT ["bin/run.sh"]
