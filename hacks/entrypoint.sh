#!/bin/env bash

set -euxo pipefail

ARGS="--input ${6}"
if [ "${1}" = "yes" ]; then
    ARGS="--nodatetime $ARGS"
fi

if [ "${2}" = "yes" ]; then
    ARGS="--nodate $ARGS"
fi

if [ "${3}" = "yes" ]; then
    ARGS="--nooneof $ARGS"
fi

if [ "${4}" = "yes" ]; then
    ARGS="--noproperties-array $ARGS"
fi

if [ ! "${5}patch" = "patch" ]; then
    ARGS="--patch ${5} $ARGS"
fi

exec /usr/src/app/patch.rb $ARGS > "${7}"
