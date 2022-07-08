FROM ubuntu:22.04 AS compiler-osm2pgsql
ENV DEBIAN_FRONTEND=noninteractive
# Based on and credits: https://github.com/Overv/openstreetmap-tile-server/blob/master/Dockerfile
# Slimmed down by @justb4 to only build osm2pgsql.

# Install build deps
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
	git-core \
	checkinstall \
	g++ \
	gnupg2 \
	make \
	tar \
	wget \
	ca-certificates \
	cmake \
	libboost-dev \
	libboost-system-dev \
	libboost-filesystem-dev \
	libexpat1-dev \
	zlib1g-dev \
	libbz2-dev \
	libpq-dev \
	libproj-dev \
	lua5.3 \
	liblua5.3-dev \
	pandoc \
&& apt-get update

# Build osm3pgsql and make a Debian package
RUN cd ~ \
&& git clone -b master --single-branch https://github.com/openstreetmap/osm2pgsql.git --depth 1 \
&& cd osm2pgsql \
&& mkdir build \
&& cd build \
&& cmake .. \
&& make -j $(nproc) \
&& checkinstall --pkgversion="1" --install=no --default make install


FROM ubuntu:22.04 AS final

LABEL maintainer="Just van den Broecke <justb4@gmail.com>"

ARG TIMEZONE="Europe/Amsterdam"
ARG LOCALE="en_US.UTF-8"

ENV TZ=${TIMEZONE} \
    DEBIAN_FRONTEND="noninteractive" \
	PYTHON_PIP_PACKAGES="" \
    BUILD_DEPS="python3-pip" \
    PACKAGES="tzdata locales curl postgresql-client osmosis \
    liblua5.3-dev lua5.3 \
    libboost-filesystem-dev libboost-dev libboost-system-dev libboost-filesystem-dev \
    libexpat1-dev \
    zlib1g-dev libbz2-dev \
    libpq-dev \
    libproj-dev" \
    MY_HOME="/osm2pgsql" \
	LANG=${LOCALE} \
	LANGUAGE=${LOCALE} \
	LC_ALL=${LOCALE} \
	AUTOVACUUM=on

# Get the osm2pgsql build result (Debian Package)
COPY --from=compiler-osm2pgsql /root/osm2pgsql/build/build_1-1_amd64.deb .

# Install support packages and osm2pgsql package
RUN apt-get update \
	&& apt-get --no-install-recommends install -y ${PACKAGES} \
	&& locale-gen ${LOCALE} \
	&& echo ${TZ} > /etc/timezone && ln -fs /usr/share/zoneinfo/$(cat /etc/timezone) /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
	&& apt-get clean autoclean \
	&& apt-get autoremove --yes \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/ \
	&& dpkg -i build_1-1_amd64.deb && rm build_1-1_amd64.deb

WORKDIR ${MY_HOME}
ADD entry.sh ${MY_HOME}/

ENTRYPOINT ["/osm2pgsql/entry.sh"]
