# Docker Image for osm2pgsql
Docker Image for [osm2pgsql](https://osm2pgsql.org/) and supporting tools like Osmosis.

Credits: https://github.com/Overv/openstreetmap-tile-server/
Modified the generic Docker image to explicitly and only build osm2pgsql as
to have a very recent version.
 
The GitHub repo is at: 
https://github.com/justb4/docker-osm2pgsql

## Download/Pull

This image is built via [GitHub Workflows](.github/workflows/main.yml) 
and published on DockerHub from where you can pull the Image:

https://hub.docker.com/repository/docker/justb4/osm2pgsql

## Design

The Docker image is built using staged build: osm2pgsql is compiled 
and built as a Debian Package. That package is then later copied and installed
into the final image.

## Version

the Image uses the osm2pgsql version built with build date: 
`<osm2pgsql version>-<build-github-date>-<buildnr>`
like 
`1.6.0-220708-2`, but to see it in full do:

```
docker run --rm justb4/osm2pgsql:latest osm2pgsql --version
2022-07-08 16:51:22  osm2pgsql version 1.6.0
Build: RelWithDebInfo
Compiled using the following library versions:
Libosmium 2.17.3
Proj [API 6] 8.2.1
Lua 5.3.6

```
## Using

The Docker image has a generic entry.sh script that you can overrule with specific
Bash scripts, e.g. to download OSM data, preprocess with Osmosis and call osm2pgsql.

Basically you should Docker Volume mount your directory with scripts and
possibly other dirs with data into the working dir `/osm2pgsql` and run
the container with your own Bash script.
