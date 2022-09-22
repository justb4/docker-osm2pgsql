FROM debian:bookworm-slim

LABEL maintainer="Just van den Broecke <justb4@gmail.com>"

ARG TIMEZONE="Europe/Amsterdam"
ARG LOCALE="en_US.UTF-8"

ENV TZ=${TIMEZONE} \
    DEBIAN_FRONTEND="noninteractive" \
    BUILD_DEPS="tzdata" \
    PACKAGES="locales wget curl unzip zip postgresql-client openssh-client osm2pgsql osmosis"  \
    MY_HOME="/osm2pgsql" \
	LANG=${LOCALE} \
	LANGUAGE=${LOCALE} \
	LC_ALL=${LOCALE} \
	AUTOVACUUM=on

RUN \
	apt-get update && apt-get --no-install-recommends install  -y ${BUILD_DEPS} ${PACKAGES} \
	&& cp /usr/share/zoneinfo/${TZ} /etc/localtime\
	&& dpkg-reconfigure tzdata \
	# Locale
	&& sed -i -e "s/# ${LOCALE} UTF-8/${LOCALE} UTF-8/" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=${LOCALE} \
	&& apt-get remove --purge ${BUILD_DEPS} -y \
    && apt autoremove -y  \
    && rm -rf /var/lib/apt/lists/*


WORKDIR ${MY_HOME}
ADD entry.sh ${MY_HOME}/

ENTRYPOINT ["/osm2pgsql/entry.sh"]
