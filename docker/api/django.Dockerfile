FROM python:3.8.6

WORKDIR /srv/api

# Install the necessary packages
RUN apt-get update && \
    apt-get install -y \
      locales apt-utils

# Generate locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Set envs that won't change much
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# Set application specific envs
ENV POSTGRES_USER=api
ENV POSTGRES_PASSWORD=api-password
ENV POSTGRES_DB=postgres
ENV DB_HOST=database
ENV DB_PORT=5432

ENV DJANGO_DEBUG=False
ENV APP_SECRET=change-me
ENV API_ALLOWED_HOSTS="*"

ENV MEDIA_ROOT=/var/www/api/media
VOLUME /var/www/api/media

ENV API_STATIC_FILES=/var/www/api/static
VOLUME /var/www/api/static

EXPOSE 80

# Copy default command & wait for it script and make them executable
COPY docker/api/default-command.sh default-command.sh
RUN chmod +x default-command.sh
COPY docker/wait-for-it/wait-for-it.sh wait-for-it.sh
RUN chmod +x wait-for-it.sh

# Upgrade pip to the latest version
RUN python -m pip install -U --force-reinstall pip

# Install the necessary system dependencies
RUN apt-get update && \
    apt-get install -y \
      libpq-dev gcc musl-dev zlib1g-dev libjpeg-dev libfreetype6-dev liblcms2-dev \
      libopenjp2-7-dev libtiff-dev tk-dev tcl-dev g++ python3-dev

# Define paths for django project
ARG DJANGO_PROJECT_LOCAL_PATH
ARG PYTHON_REQUIREMENTS_LOCAL_PATH=$DJANGO_PROJECT_LOCAL_PATH/requirements.txt

# Install python dependencies for the project
COPY $PYTHON_REQUIREMENTS_LOCAL_PATH /requirements.txt
RUN pip3 install -r /requirements.txt

COPY $DJANGO_PROJECT_LOCAL_PATH .

# Name of django ASGI application to run
ARG APP_NAME
ENV APP_NAME=$APP_NAME

ENTRYPOINT /srv/api/wait-for-it.sh ${DB_HOST}:${DB_PORT} -- /srv/api/default-command.sh $APP_NAME -b 0.0.0.0 -p 80
