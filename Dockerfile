# python is the name of the image
# 3.9 is the version of python
# apline3.13 is the version tag
FROM python:3.9-alpine3.13 
# this is who is maintining this docker image
LABEL maintainer="jeremiahhawks.com"
# this tells python to NOT buffer the output
# it will be printed directly to the console
ENV PYTHONUNBUFFERED 1

# These copy things from my working directory into the image
COPY ./requirements.txt /tmp/requirements.txt 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# the default directory from where commands will be run
WORKDIR /app
# exposes port 8000 from the container to our machine
EXPOSE 8000

ARG DEV=false
# runs a command
RUN python -m venv /py && \
#   upgrades pip
    /py/bin/pip install --upgrade pip && \
    # next 3 lines install the dependencies in order to compile from source the psycopg2 thing
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
#   installs requirements
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
#   removes temp directory
    rm -rf /tmp && \
    # removes dependencies necesary to build the psycopg2 thing
    apk del .tmp-build-deps && \
#   adds a user to the image without a password, without a home directory, called django-user
#   this is safer. its best practice to not use root user. its more secure
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# sets the path var so that we can run commands without typing the directory
ENV PATH="/py/bin:$PATH"

# until this line everything above has been done as root user, after, it'll be django-user
USER django-user