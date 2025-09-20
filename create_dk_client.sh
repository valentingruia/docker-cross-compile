#!/bin/bash

# enables a shell option that makes the script exit immediately
set -e

# path of the dockerfile and the image/container name
DOCKER_FILE=${1:-Dockerfile}
DOCKER_PREFIX=${2:-aarch64}
BUILD_ARCH=${1:-MCS51}

case "$BUILD_ARCH" in
   "MCS51")
    arch_script="install_mcs51.sh"
   ;;
   "ARM_CORTEX")
    arch_script="install_cortex.sh"
   ;;
esac

# echo "working dir: $PWD"
# $SUDO_USER"

# I need to add the current user to docker group:
# $ sudo usermod -aG docker $USER

# Get user, uid and gid to input to Docker
user=$(whoami)
uid=$(id -u $user)
gid=$(id -g $user)

# Get ssh and gitconfig settings to input to Docker
mkdir -p user_files
echo "file created, bk: /home/$user/.ssh"
cp -a /home/$user/.ssh          user_files/
cp -a /home/$user/.gitconfig    user_files/

DOCKER_IMG_NAME=${DOCKER_PREFIX}-dev-img
DOCKER_CNT_NAME=${DOCKER_PREFIX}-dev-cnt

# arguments for the the 'docker build' command
build_args="--build-arg build_usr=$user --build-arg uid=$uid "
build_args+="--build-arg build_grp=$user --build-arg gid=$gid "
build_args+="--build-arg build_arch=$arch_script "
build_args+="-f $DOCKER_FILE "

# enable logs printed in Dockerfile
# build_args+="--progress=plain --no-cache "

# -t the resulting image with the name xxx-docker-img
# the current directory (.) as the context.
build_args+="-t ${DOCKER_IMG_NAME} ."

cmd="docker build $build_args"

echo "Building docker image..."
echo $cmd; eval $cmd


host_addr=$(hostname -s)
dev_dir="/home/$user/dev_rpi"

# Set run arguments/inputs for Docker container
# old -p 2222-2229:22
# old -d - run in detach mode, in background
# old -P - Publish all exposed ports from the container to random host ports.
run_args="-it -d -p 2222:22 --privileged "
# run_args+="--network host "
run_args+="--hostname $host_addr "
run_args+="--name $DOCKER_CNT_NAME "

# add shared 'dev_dir'
if [ -d $dev_dir ]; then
 run_args+="-v $dev_dir:$dev_dir "
fi

# Create and run container
cmd="docker run $run_args ${DOCKER_IMG_NAME} /bin/bash"
echo
echo "Staring container..."
echo $cmd; eval $cmd

# Print info for running container
ssh_port=$(docker port ${DOCKER_CNT_NAME} | cut -d: -f2)
echo
echo "To enter container: "
echo "docker exec -it -u $user ${DOCKER_CNT_NAME} /bin/bash"
echo
echo "To ssh to container: "
echo "ssh -p 2222 -o PreferredAuthentications=none -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@localhost"
echo

rm -rf user_files