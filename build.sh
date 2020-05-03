#!/bin/sh

docker run -it --rm --name jolie-build -v "$(pwd)/../jolie":/usr/src/mymaven -w /usr/src/mymaven maven:3-jdk-8 mvn -T 1C clean install
docker run -it --rm --name jolie-installer-build -v "$(pwd)/jolie_installer":/usr/src/mymaven -w /usr/src/mymaven maven:3-jdk-8 mvn -T 1C clean install