FROM ubuntu:xenial-20170802
MAINTAINER Rónán Daly <Ronan.Daly@glasgow.ac.uk>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV R_KEEP_PKG_SOURCE yes

RUN apt-get update && \
    apt-get install -y apt-utils locales && \
    update-locale LC_ALL=C.UTF-8 && \
    apt-get install -y \
        software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y \
	    curl \
	    vim \
        less \
        screen \
        git \
        libssl-dev \
        libcurl4-openssl-dev \
        oracle-java8-installer \
        build-essential && \
    apt-get install -y oracle-java8-set-default && \
    apt-get install -y r-base && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" && \
    chmod +x /usr/local/bin/gosu

COPY docker-entrypoint.sh /usr/local/bin/
RUN groupadd pimpcraft && useradd -g pimpcraft -m pimpcraft
#RUN mkdir -m o-w -p /home/pimpcraft/static /home/pimpcraft/media
RUN chown -R pimpcraft:pimpcraft /home/pimpcraft
