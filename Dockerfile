FROM ubuntu:24.04
#RUN userdel -r ubuntu
# && gpasswd -d ubuntu ubuntu
# RUN groupdel -r ubuntu

# doker images for ubuntu:24.04 had 'ubuntu'user with uid/gid = 1000/1000
# 24.04, 25.04, 25.10

#RUN echo "Usr:" ${uid} "group" ${gid}
#RUN echo "Existing groups:" && getent group && exit 1

LABEL Author="Valentin Gruia"

# arguments default value
ARG build_usr="bld_usr"
ARG build_grp="bld_grp"
ARG uid=1000
ARG gid=1000


# Enable apt proxy and install basic tools
#RUN echo "Acquire::http::proxy \"${proxy_http}\";" > /etc/apt/apt.conf &&\
#    echo "Acquire::https::proxy \"${proxy_https}\";" >> /etc/apt/apt.conf
RUN apt-get update && apt-get install -y \
    apt-utils \
    sudo

# adapt sources.list
# RUN echo "deb http://aptly.conti.de xenial main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    coreutils \
    gosu \
    curl \
    wget \
    unzip


# Additional environment modifications (locales/language configure and sh causes some syntax errors in some build scripts)
# Having proper locales configured and installed will mitigate Compiler Warnings from opensource/systemd packages
RUN apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV DEBIAN_FRONTEND=noninteractiv\
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8


#updates the root password to 'root'
RUN echo "root:root" | chpasswd

# replace ubuntu:ubuntu with ${build_usr}:${build_grp}
RUN set -eux; \
    test -n "$build_usr"; \
    test -n "$build_grp"; \
    groupmod --new-name "${build_grp}" ubuntu; \
    usermod --login "${build_usr}" \
            --home "/home/${build_usr}" \
            --move-home ubuntu; \
    passwd -d ${build_usr}
    # Configure passwordless sudo
RUN rm -f /etc/sudoers.d/ubuntu; \
    mkdir -p /etc/sudoers.d/; \
    echo "${build_usr} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${build_usr}"; \
    chmod 0440 "/etc/sudoers.d/${build_usr}"; \
    visudo -cf "/etc/sudoers.d/${build_usr}"


# DEBUG: list user with login shell
# RUN grep -vE '(nologin|false)$' /etc/passwd


# load .bshrc file while connection on ssh
RUN echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> /etc/profile

# install ssh server
RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd
# configure ssh server to accept empty password
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

# Remove logs
RUN rm -rf /val/log/lastlog
RUN rm -rf /val/log/faillog


USER ${build_usr}
WORKDIR /home/${build_usr}
# restore users .ssh
# COPY user_files/.ssh ./.ssh
# restore users .gitconfig
COPY user_files/.gitconfig .
# copy platform specific tooling
COPY user_files/arch_specific.sh ./arch_specific.sh
# create the .bashrc file
RUN echo export LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 >> ./.bashrc

# switch back to root
USER root
# change users .ssh, .gitconfig
#RUN chown $build_usr:$build_grp -R ./.ssh
RUN chown $build_usr:$build_grp ./.gitconfig

# install platform specific tools
RUN chown $build_usr:$build_grp ./arch_specific.sh
RUN chmod +x ./arch_specific.sh && ./arch_specific.sh

# SCM (Source Code Management) tolls
RUN apt-get install --fix-missing -y \
    vim \
    nano \
    git \
    git-lfs

# libffi-dev - allows code written in one language (like C) to call functions written in another language:
#   Python use libffi to interface with native libraries.
#   Used by CPython's ctypes module to call C functions at runtime.
RUN apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    libffi-dev

# make python3 the default python
RUN ln -s /usr/bin/python3 /usr/local/bin/python

# build tools
RUN apt-get install -y \
    make  cmake \
    meson ninja-build \
    gcc g++ build-essential \
    libglib2.0-0


# Copy needed files to image
COPY entrypoint.sh /usr/local/bin

# Overwrite dash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Entrypoint
EXPOSE 22
ENTRYPOINT ["entrypoint.sh"]
# CMD ["/bin/bash"]
CMD ["/usr/sbin/sshd", "-D"]