# Docker container for cross-compile

The docker image is build form [create_dk_client.sh](create_dk_client.sh) file. It is collecting data from the host machine (Ubuntu) and is using it to configure the new container.
Data used by the container:
* the current user is recreated in the container
* .gitconfig is copied and used by the container
* .ssh directory is copied and used by the container

# How to use it

Create the container

`./create_dk_client.sh`

The container is build and run in  run in detach mode. To open a console into the container:

`docker exec -it -u $(whoami) arch64-dev-cnt /bin/bash`

Or to ssh into the container:

`ssh -p 2222 -o PreferredAuthentications=none -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $(whoami)@localhost`

# Usefull commands

|command|description|
|:----------|:----------------------|
|`docker logs arch64-dev-cnt`|Print logs from container|
|`docker inspect arch64-dev-cnt`|Provides detailed information on image|
|`docker ps -a`|List all docker containers|
|`docker stop arch64-dev-cnt`|Stop the container|
|`docker rm arch64-dev-cnt`|Remove container|
|`sudo docker images`|List docker images in your local repository|
|`docker rmi <IMAGE ID>`|Remove docker image|
