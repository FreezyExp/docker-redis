#!/bin/bash
set -e

REDIS_PASSWORD=${REDIS_PASSWORD:-}

## Taken from sameersbn/docker-gitlab
USERMAP_ORIG_UID=$(id -u redis)
USERMAP_ORIG_GID=$(id -g redis)
USERMAP_GID=${USERMAP_GID:-${USERMAP_UID:-$USERMAP_ORIG_GID}}
USERMAP_UID=${USERMAP_UID:-$USERMAP_ORIG_UID}
if [ "${USERMAP_UID}" != "${USERMAP_ORIG_UID}" ] || [ "${USERMAP_GID}" != "${USERMAP_ORIG_GID}" ]; then
  echo "Adapting uid and gid for redis:redis to $USERMAP_UID:$USERMAP_GID"
  groupmod -g "${USERMAP_GID}" redis
  sed -i -e "s/:${USERMAP_ORIG_UID}:${USERMAP_GID}:/:${USERMAP_UID}:${USERMAP_GID}:/" /etc/passwd
fi

mkdir -p -m 0755 /run/redis
chown -R redis:redis /run/redis

mkdir -p -m 0755 /var/lib/redis
chown -R redis:redis /var/lib/redis

exec start-stop-daemon --start --chuid redis:redis --exec /usr/bin/redis-server -- \
  /etc/redis/redis.conf ${REDIS_PASSWORD:+--requirepass $REDIS_PASSWORD}
