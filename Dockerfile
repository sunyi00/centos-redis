FROM centos:7.1.1503

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

RUN mkdir -p /redis
VOLUME /redis
WORKDIR /redis

EXPOSE 6379
CMD [ "redis-server" ]
