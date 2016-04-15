#!/bin/sh
docker rm -f pistahx_app
docker rm -f pistahx_redis
docker run --name pistahx_redis -d redis:alpine
docker build -t pistahx_app .
docker run -e ENV=docker -d -p 3000 --link pistahx_redis --name pistahx_app pistahx_app
echo "App is running at this ip and port :"
boot2docker ip && docker inspect pistahx_app | grep HostPort | head -1 | tr -d " \t"