#!/bin/bash

cmd=$0

usage() {
	echo "############# USAGE ###########"
	echo "$cmd [-q] <container.{id|name}>"
	echo "-q          - option sets command into quiet mode"
	echo "              if container arg is not specified then read prompt will not appear"
	echo "<container> - two options for container id or name, either full name or part of id"
}

if ! command -v docker &> /dev/null; then
	echo "docker not found: install docker"
	exit 1
fi

shift $((OPTIND-1))

quiet="0"
container=""
container_or_option=$1
if [[ $container_or_option = "-q" ]]; then
	quiet="1"
	if [[ ! $2 ]]; then
		echo "error: container argument is not passed in quiet mode"
		usage	
		exit 1
	fi
	container=$2
else
	container=$1
fi

if [[ ! $container ]] && [[ $quiet = "0" ]]; then
	read -p "Container name or id: " container
fi

if [[ ! $container ]]; then
	echo "error: fill container argument"
	usage	
	exit 1
fi

if [ ! "$(docker ps -a | grep -w "$container$")" ] && [ ! "$(docker ps -a -q -f "id=$container")" ]; then
	if [[ $quiet = "0" ]]; then
		echo "Container $container not found"
	fi
	exit 1
fi

if [[ $quiet = "0" ]]; then
	echo "Container $container found"
fi
exit 0
