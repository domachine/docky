#!/bin/bash

# Really simple script to rebuild a running container using a new image version.
# We guess that the project has a bash script called `docker_run.sh` within the
# project that spawns the necessary containers.

rebuild() {
  container_count=0
  export name=$(awk -F'(": "|  "|",)' '$2=="name"{print $3}' package.json)
  export version=$(awk -F'(": "|  "|",)' '$2=="version"{print $3}' package.json)
  export port=0
  export initial=false

  containers=( $(docker ps|awk '$2~/^'$name:'/ {print $1}') )
  docker build -t $name:$version .
  [[ $? != 0 ]] && exit $?
  for container in $containers; do
    port=$(docker inspect $container \
      | awk -F'( +"|":|",?)' '$2=="HostPort"{print $4}' \
  	  | tail -n1)
    docker stop $container
    $SHELL $(pwd)/docker_run.sh
    (( ++container_count ))
  done

  # Build at least one container.
  if [[ $container_count == 0 ]]; then
    initial=true
    $SHELL $(pwd)/docker_run.sh
  fi
}

if [[ $1 == rebuild ]]; then
  rebuild
else
  echo "Unknow command: $1" >&2
fi
