#!/bin/bash

# uses jq and docker

if ! command -v jq &> /dev/null; then
	echo "jq not found: install jq"
	exit 1
fi

if ! command -v docker &> /dev/null; then
	echo "docker not found: install docker"
	exit 1
fi

cmd=$0
container=$1

if [[ ! $container ]]; then
	echo "you should pass container to command"	
	echo "example:"
	echo "\$ $cmd <container-name|container-id> "
	exit 1
fi

if [ ! "$(docker ps -a | grep -w "$container$")" ] && [ ! "$(docker ps -a -q -f "id=$container")" ]; then
	echo "Container not found"
	exit 1
fi

entrypoint=$(docker container inspect --format='{{json .Config.Entrypoint}}' $container | jq '.')
cmd=$(docker container inspect --format='{{json .Config.Cmd}}' $container | jq '.')

if [[ $entrypoint = "null" ]]; then
	entrypoint=""
else
	entrypoint=$( echo "$entrypoint" | jq '.[]' )
fi

if [[ $cmd != "null" ]]; then
	cmd=$(echo "$cmd" | jq '.[]')
else
	cmd=""
fi

output=""

for entry in $entrypoint; do
	e=$(echo "$entry" | sed 's/"//g')
	output="$output $e"
done

for arg in $cmd; do
	a=$(echo "$arg" | sed 's/"//g')
	output="$output $a"
done

echo "$output"
