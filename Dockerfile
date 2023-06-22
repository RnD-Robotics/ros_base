ARG UBUNTU_VERSION=20230605
#https://github.com/moby/moby/issues/4032#issuecomment-192327844 

FROM ubuntu:jammy-${UBUNTU_VERSION}

SHELL ["/bin/bash", "-c"]

ENV ROS_DISTRO humble

# Upgrade OS
RUN DEBIAN_FRONTEND=noninteractive apt-get update -q && \
    apt-get upgrade -y && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# desktop or ros-base
ARG INSTALL_PACKAGE=desktop

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep python3-vcstool
   
RUN rosdep init && \
    rm -rf /var/lib/apt/lists/*

RUN rosdep update

# Install simulation package only on amd64
# Not ready for arm64 for now (July 28th, 2020)
# https://github.com/Tiryoh/docker-ros2-desktop-vnc/pull/56#issuecomment-1196359860
RUN apt-get update -q && \
    apt-get install -y \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-ros-ign && \
    rm -rf /var/lib/apt/lists/*; 
    
COPY ./entrypoint.sh /

ENTRYPOINT [ "/bin/bash", "-c", "/entrypoint.sh" ]

ENV USER ubuntu
ENV PASSWD ubuntu
