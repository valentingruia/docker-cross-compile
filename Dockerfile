FROM ubuntu:24.04
RUN userdel -r ubuntu
# && gpasswd -d ubuntu ubuntu
# RUN groupdel -r ubuntu

# doker images for ubuntu:24.04 had 'ubuntu'user with uid/gid = 1000/1000
# 24.04, 25.04, 25.10

#RUN echo "Usr:" ${uid} "group" ${gid}
#RUN echo "Existing groups:" && getent group && exit 1



LABEL Author="Valentin Gruia"

ARG build_usr="bld_usr"
ARG build_grp="bld_grp"
ARG uid=1001
ARG gid=1001

ARG build_arch

# Enable apt proxy and install basic tools
#RUN echo "Acquire::http::proxy \"${proxy_http}\";" > /etc/apt/apt.conf &&\
#    echo "Acquire::https::proxy \"${proxy_https}\";" >> /etc/apt/apt.conf
# RUN apt-get update && apt-get install -y apt-utils vim  sudo

# adapt sources.list
# RUN echo "deb http://aptly.conti.de xenial main" >> /etc/apt/sources.list
RUN apt-get update


RUN apt-get install -y \
    coreutils\
    gosu \
    curl \
    wget \
    unzip
# RUN curl -s ${repo_source} > /usr/local/bin/repo && chmod a+x /usr/local/bin/repo


# Additional environment modifications (locales/language configure and sh causes some syntax errors in some build scripts)
# Having proper locales configured and installed, will mitigate Compiler Warnings from opensource/systemd packages
RUN apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV DEBIAN_FRONTEND=noninteractiv\
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8


# ssh server
RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd

#updates the root password to 'root'
RUN echo "root:root" | chpasswd

# Add the same user/group in the docker
RUN groupadd -g ${gid} ${build_grp}
# RUN useradd -lms /bin/bash -u ${uid} -g ${build_grp} ${build_usr}
RUN useradd -u ${uid} -g ${build_grp} -M -r ${build_usr} -s /bin/bash
# Add sudo rights to user
RUN echo "${build_usr} ALL=NOPASSWD:ALL" >> /etc/sudoers && \
    passwd -d ${build_usr}


RUN mkdir -p /home/${build_usr} && \
    chown ${build_usr}:${build_grp} /home/${build_usr}

# Configure SSH for passwordless login
# RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
RUN echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "AuthenticationMethods none" >> /etc/ssh/sshd_config
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# load .bshrc file while connection on ssh
RUN echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> /etc/profile

# Remove logs
RUN rm -rf /val/log/lastlog
RUN rm -rf /val/log/faillog


USER $build_usr
WORKDIR /home/$build_usr
# restore users .ssh
COPY user_files/.ssh ./.ssh
# restore users .gitconfig
COPY user_files/.gitconfig .
# create the .bashrc file
RUN echo export LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 >> ./.bashrc

USER root
# change users .ssh, .gitconfig
RUN chown $build_usr:$build_grp -R ./.ssh
RUN chown $build_usr:$build_grp ./.gitconfig


# SCM (SOurce Code Management) tolls
RUN apt-get install --fix-missing -y \
    vim \
    git \
    git-lfs

# libffi-dev - allows code written in one language (like C) to call functions written in another language:
#   Python, Ruby, LuaJIT, and JavaScript engines (like Node.js) use libffi to interface with native libraries.
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
    make \
    cmake \
    gcc g++ build-essential \
    libglib2.0-0


# include the platform specific tools
COPY ${build_arch} /usr/local/bin/${build_arch}
RUN chmod +x /usr/local/bin/${build_arch}
RUN ./${build_arch}


# Copy needed files to image
COPY entrypoint.sh /usr/local/bin

# Overwrite dash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Entrypoint
EXPOSE 22
ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]