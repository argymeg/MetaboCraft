#!/bin/bash
set -e

if [ "$(id -u)" = '0' ]; then
	#DOCKER_SOCKET_GROUP_ID=$(gosu pampas stat -c %g /var/run/docker.sock)
    #DOCKER_SOCKET_GROUP_NAME=$(getent group ${DOCKER_SOCKET_GROUP_ID} | cut -d ':' -f 1)

    #if [ -z "${DOCKER_SOCKET_GROUP_NAME}" ]; then
    #    groupadd -g ${DOCKER_SOCKET_GROUP_ID} dockersocketgroup
    #    usermod -aG dockersocketgroup pampas
    #else
    #    usermod -aG ${DOCKER_SOCKET_GROUP_NAME} pampas
    #fi

    BIND_GROUP_ID=$(gosu pampas stat -c %g /home/pampas/media)
    BIND_GROUP_NAME=$(getent group ${BIND_GROUP_ID} | cut -d ':' -f 1)

    if [ -z "${BIND_GROUP_NAME}" ]; then
        groupadd -g ${BIND_GROUP_ID} bindgroup
        usermod -aG bindgroup pampas
    else
        usermod -aG ${BIND_GROUP_NAME} pampas
    fi

	exec gosu pampas "$@"
fi

exec "$@"






