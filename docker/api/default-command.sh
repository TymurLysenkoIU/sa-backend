#!/bin/sh

# ##############################################################################
# Description:
# The script to launch a django project in production mode, applying
# migrations.
#
# Arguments:
# 1-st positional argument: name of django ASGI application to launch
# Forwards the rest arguments passed to the server command.
# ##############################################################################

# Apply migrations
python -m manage migrate

# Collect static files (not needed for dev environment)
python -m manage collectstatic --noinput

APP_NAME=$1
shift

# Start the production server
daphne "$@" "$APP_NAME.asgi:application"
