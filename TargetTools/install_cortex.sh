#!/bin/bash -x

sudo apt install gcc-arm-none-eabi gdb-multiarch -y
echo "ARM toolchain $(arm-none-eabi-gcc --version)"

# Install from official website https://learn.arm.com/install-guides/gcc/arm-gnu/
# curl -LO https://gitlab.arm.com/api/v4/projects/10698/packages/generic/gnu-toolchain/15.3.rel1/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
# tar xJf arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz -C $HOME
# echo 'export PATH="$PATH:$HOME/arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi/bin"' >> ~/.bashrc
# source ~/.bashrc

