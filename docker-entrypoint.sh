#!/bin/bash


# wait for a given host:port to become available
#
# $1 host
# $2 port
function dockerwait {
    while ! exec 6<>/dev/tcp/$1/$2; do
        echo "$(date) - waiting to connect $1 $2"
        sleep 5
    done
    echo "$(date) - connected to $1 $2"

    exec 6>&-
    exec 6<&-
}


# wait for services to become available
# this prevents race conditions using docker-compose
function wait_for_services {
    if [[ "$WAIT_FOR_GRADLE" ]] ; then
        dockerwait $GRADLESERVER $GRADLEPORT
    fi
}


function defaults {
    : ${GRADLESERVER:="gradle"}
    : ${GRADLEPORT:="2375"}
    : ${DOCKER_ROUTE:=$(/sbin/ip route|awk '/default/ { print $3 }')}

    export GRADLESERVER GRADLEPORT DOCKER_ROUTE 
}


trap exit SIGHUP SIGINT SIGTERM
defaults
wait_for_services

exec gradle --no-daemon $@
