#!/bin/bash

container_name="secret-santa"

if docker ps --format '{{.Names}}' | grep -q "^$container_name$" ; then
echo "Stopping docker container $container_name..."
docker stop $container_name
sleep 1
echo "Removing docker container $container_name..."
docker rm -f $container_name
sleep 1
else
echo "Docker container $container_name does not exist. Please check again."
fi
