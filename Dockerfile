FROM ubuntu:noble

LABEL maintainer="Just van den Broecke <justb4@gmail.com>"

ARG TIMEZONE="Europe/Amsterdam"
ARG LOCALE="en_US.UTF-8"

ENV TZ=${TIMEZONE} \
    DEBIAN_FRONTEND="noninteractive" \
    BUILD_DEPS="tzdata" \
    PACKAGES="locales wget curl unzip zip postgresql-client osm2pgsql osmosis"  \
    MY_HOME="/osm2pgsql" \
	LANG=${LOCALE} \
	LANGUAGE=${LOCALE} \
	LC_ALL=${LOCALE} \
	AUTOVACUUM=on

RUN \
	apt-get update && apt-get --no-install-recommends install  -y ${BUILD_DEPS} ${PACKAGES} \
	&& dpkg-reconfigure tzdata \
    && locale-gen ${LOCALE} \
    && update-locale LANG=${LOCALE} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${MY_HOME}
ADD entry.sh ${MY_HOME}/

ENTRYPOINT ["/osm2pgsql/entry.sh"]
