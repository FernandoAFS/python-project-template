#!/bin/sh

set -e

USER=${USER:-"$UID:$GID"}


if [ "$1" = "backend" ]
then
    shift
    exec gosu "$USER" tini -- python -m ${APP_PATH}
fi

if [ "$1" = "lab" ]
then
    shift

    chown -R "$USER" "$LAB_DATA"
    chown -R "$USER" "$LAB_NOTEBOOKS"
    chown -R "$USER" "/project/"

    exec gosu "$USER" tini -- jupyter lab --ip 0.0.0.0
fi

exec "$@"

