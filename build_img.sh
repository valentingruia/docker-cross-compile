#!/bin/bash

# shell option to exit the script immediately
set -e

# parameters:
# @1 - path to the working directory
# @2 - croos-compile platform: Arm coretex, MSC51
# @3 - dokerfile name

# path of the dockerfile and the image/container name
WORK_DIR=${1:-$(dirname "$PWD")}
HOST_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
BUILD_ARCH=${2:-cortex}
DOCKER_FILE=${3:-Dockerfile}

case "$BUILD_ARCH" in
   "mcs51")
    arch_tools="install_mcs51.sh"
   ;;
   "cortex")
    arch_tools="install_cortex.sh"
   ;;
   "empty")
    arch_tools="install_empty.sh"
   ;;
esac

# echo "working dir: $PWD"
# echo "parent dir: ${WORK_DIR}, host ${HOST_ARCH}"
# exit 1

# I need to add the current user to docker group:
# $ sudo usermod -aG docker $USER

# Get user, uid and gid to input to Docker
user=$(whoami)
uid=$(id -u $user)
gid=$(id -g $user)

# Get ssh and gitconfig settings to input to Docker
mkdir -p user_files
cp -a /home/$user/.gitconfig      user_files/
cp -a ./TargetTools/${arch_tools} user_files/arch_specific.sh
echo "Backup directory backup done"

# container has the date sufix, the image gas the working dir
TIME_STEMP=$(date '+%m%d%H')
DOCKER_IMG_NAME=dev-${BUILD_ARCH}-${TIME_STEMP}
DOCKER_CNT_NAME=dev-${BUILD_ARCH}-$(basename ${WORK_DIR})

# arguments for the the 'docker build' command
build_args="--build-arg build_usr=$user --build-arg uid=$uid "
build_args+="--build-arg build_grp=$user --build-arg gid=$gid "
build_args+="-f $DOCKER_FILE "

# enable logs printed in Dockerfile
build_args+="--progress=plain --no-cache "

# -t the resulting image with the name amd64-
# the current directory (.) as the context.
build_args+="-t ${DOCKER_IMG_NAME} ."

cmd="docker build $build_args"

echo "Building docker image..."
echo $cmd; eval $cmd

# echo "DEBUG: aborting execution"
# exit 1

# ****************************************************************
work_dir="/work"

# Set run arguments/inputs for Docker container
#   -p 2222-2229:22
#   -d - run in detach mode, in background
#   -P - Publish all exposed ports from the container to random host ports.
run_args="-it -d -p 2222-2229:22 --privileged "
# run_args+="--network host "
run_args+="--hostname $BUILD_ARCH "
run_args+="--name $DOCKER_CNT_NAME "

# add shared working directory
run_args+="-v ${WORK_DIR}:${work_dir} "

# share .ssh secrets to Docker container
run_args+="-v /home/$user/.ssh:/home/$user/.ssh:ro"


# Create and run container
cmd="docker run $run_args ${DOCKER_IMG_NAME} /bin/bash"
echo
echo "Staring container..."
echo $cmd; eval $cmd

# the ssh lisening port, in case of multiple containers
ssh_port=$(docker port ${DOCKER_CNT_NAME} | cut -d: -f2)

echo
echo "To enter container: "
echo "docker exec -it -u ${user} ${DOCKER_CNT_NAME} /bin/bash"
echo
echo "To ssh to container: "
echo "ssh -p ${ssh_port} ${user}@localhost"
echo
echo "In case of configured .ssh/config"
echo "ssh ${BUILD_ARCH}"
echo
echo "To configure vscode DevContainer"
echo "build_vscode_cfg.sh ${DOCKER_CNT_NAME} ${user}"

# remove the old record from known_hosts list
echo
echo "Remove record from known_host file"
ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "[localhost]:${ssh_port}"

# cleanup
rm -rf user_files