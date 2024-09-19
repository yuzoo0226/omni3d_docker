FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# 必要なパッケージのインストール
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y lsb-release wget curl git nano gnupg build-essential software-properties-common && \
    mkdir -p /run/user/1000 && \
    mkdir -p /var/lib/dbus

RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata keyboard-configuration && \
    DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository universe

RUN apt update && \
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-desktop-full && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-rqt-* && \
    DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-gazebo-* && \
    DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-diagnostic-updater && \
    # DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-rosidl-* && \
    # DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-tf-transformations && \
    # DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-pcl-ros && \
    # DEBIAN_FRONTEND=noninteractive apt install -y ros-noetic-realsense2-camera && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | tee /etc/apt/sources.list.d/librealsense.list

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    DEBIAN_FRONTEND=noninteractive apt install -y python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir nvidia-cudnn-cu11 && \
    pip3 install --no-cache-dir torch==2.1.0+cu118 torchvision==0.16.0+cu118 torchaudio==2.1.0+cu118 -f https://download.pytorch.org/whl/torch_stable.html && \
    pip3 install --no-cache-dir --extra-index-url https://miropsota.github.io/torch_packages_builder pytorch3d==0.7.7+pt2.1.0cu118

RUN pip3 install --no-cache-dir 'git+https://github.com/facebookresearch/detectron2.git'

RUN pip3 install --no-cache-dir datasetutils && \
    pip3 install --no-cache-dir transforms3d && \
    pip3 install --no-cache-dir open3d==0.16.0 && \
    pip3 install --no-cache-dir numpy==1.24.1

RUN curl -LO https://github.com/NVIDIA/cub/archive/1.10.0.tar.gz && \
    tar xzf 1.10.0.tar.gz && \
    export CUB_HOME=$PWD/cub-1.10.0 && \
    pip3 install ninja && \
    pip3 cache purge

RUN pip3 install 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' && \
    pip3 cache purge

# COPY ./cubercnn.tar.gz /root/cubercnn.tar.gz

# RUN tar -zxvf cubercnn.tar.gz && \
#     pip install --no-cache-dir cubercnn/.


# エントリーポイントの設定
COPY ./entrypoint.sh /

# # メタデータのラベル付け
# LABEL Author="Yuga Yano"
# LABEL Version="v0.0.1"
