FROM xuvin/s6overlay:debian-v1.22.1.0

ARG VERSION=0.3.8
ARG DOWN_LINK=https://github.com/sunsettrack4/easyepg/archive/v${VERSION}.zip
ARG BUILD_DIR=/tmp/build

ENV APPDIR=/app TZ="Europe/Berlin"
ENV PATH="${APPDIR}/bin:${PATH}"
ENV DEBIAN_FRONTEND="noninteractive"

RUN echo "**** upgrade system ****" && \
        apt-get update && apt-get -y upgrade  && \
    echo "**** install packages ****" && \
        apt-get -y install \
            cron \
            phantomjs \
            dialog \
            curl \
            wget \
            libxml2-utils \
            perl \
            perl-doc \
            jq \
            php \
            php-curl \
            git \
            xml-twig-tools \
            nano \
            iproute \
            make \
            gcc \
            unzip && \
    echo "**** CPAN and the required modules to parse JSON files ****" && \
            cpan install CPAN && \
            cpan App:cpanminus && \
            cpanm install inc::latest && \
            cpanm install JSON && \
            cpanm install XML::Rules && \
            cpanm install XML::DOM && \
            cpanm install Data::Dumper && \
            cpanm install Time::Piece && \
            cpanm install Time::Seconds && \
            cpanm install DateTime && \
            cpanm install DateTime DateTime::TimeZone && \
            cpanm install DateTime::Format::DateParse && \
            cpanm install utf8 

ADD ${DOWN_LINK} ${BUILD_DIR}/

RUN echo "**** install easyEPG ****" && \
        unzip ${BUILD_DIR}/v${VERSION}.zip -d ${BUILD_DIR}/ && \
        mkdir /app/easyepg && \
        cp -r /tmp/build/easyepg-${VERSION}/* /app/easyepg && \
        mkdir ${APPDIR}/defaults && \
        echo ${VERSION} > ${APPDIR}/defaults/ver && \
        rm -rf /app/easyepg/xml && \
    echo "**** clean up ****" && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get remove -y make \
            gcc \
            unzip && \
        apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /tmp/*

ADD rootfs /

WORKDIR /config

#VOLUME [ "/app/config" ]

ENTRYPOINT [ "/init" ]

