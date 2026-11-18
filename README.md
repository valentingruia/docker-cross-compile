# Docker container for cross-compile

The docker image is build form [build_image.sh](build_image.sh) file. It is collecting data from the host machine (Ubuntu) and is using it to configure the new container.
Data used by the container:
* the current user is recreated in the container
* .gitconfig is copied and used by the container
* .ssh directory is copied and used by the container

# How to use it

Create the container

`./build_image.sh [WORK_DIR] [TARGET]`

[WORK_DIR] is optional:
 - path to the working dir
[TARGET] desired platform, is optional:
 - mcs51 - for SDCC-4.5.00 compiler for STM8, MCS-51, DS390, HC08, S08, Z80, Z180, R800, Rabbit, SM83, eZ80 in Z80 mode
 - cortex - ARM cortex targets - DEFAULT value
 - aarch64 - to add support

## The container is build and run in detach mode. To open a console into the container:

`docker exec -it -u $(whoami) dev-arch64-111617 /bin/bash`

## To ssh into the container:
### Local machine config:
Configure the remote host with no security key check. In file `~/.ssh/config` add the docker:
```
Host cortex
    HostName localhost
    Port 2222
    User valentin
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```
### Connect to the Docker image:
On the target allow ssh connections with empty password. In file `/etc/ssh/sshd_config` set `PermitEmptyPasswords yes`.
Connect with the command:

`ssh cortex`<br>
OR<br>
`ssh -v -p 2222 valentin@localhost`

Before connecting over ssh to a new container clear old key from known_hosts:<br>
`ssh-keygen -f '/home/valentin/.ssh/known_hosts' -R '[localhost]:2222'`

### To configure the vscode connetion to the running container
The [config file is described here](vscode_cfg.md).

# Usefull commands

|command|description|
|:----------|:----------------------|
|`docker logs dev-arch64-111617`|Print logs from container|
|`docker inspect dev-arch64-111617`|Provides detailed information on image|
|`docker ps -a`|List all docker containers|
|`docker stop dev-arch64-111617`|Stop the container|
|`docker rm dev-arch64-111617`|Remove container|
|`sudo docker images`|List docker images in your local repository|
|`docker rmi <IMAGE ID>`|Remove docker image|
