FROM centos:7.1.1503

RUN groupadd -r redis && useradd -r -g redis redis

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(uname -m)" \
    && chmod +x /usr/local/bin/gosu

ENV REDIS_VERSION 3.0.2
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.2.tar.gz
ENV REDIS_DOWNLOAD_SHA1 a38755fe9a669896f7c5d8cd3ebbf76d59712002

RUN buildDeps='gcc libc6-dev make tar'; \
    set -x \
    && yum install -y $buildDeps \
    && yum clean -y all && rm -rf /var/cache/yum/* \
    && mkdir -p /usr/src/redis \
    && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -r /usr/src/redis \
    && yum remove -y $buildDeps

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 6379
CMD [ "redis-server" ] ]
