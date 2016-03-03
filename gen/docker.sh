#!/bin/sh
docker rm -f orms_app
docker rm -f orms_redis
docker run --name orms_redis -d redis:alpine
docker build -t orms_app .
docker run -e ENV=docker -d -p 3000 --link orms_redis --name orms_app orms_app
echo "App is running at this ip and port :"
boot2docker ip && docker inspect orms_app | grep HostPort | head -1 | tr -d " \t"