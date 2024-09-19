[Omni3d](https://github.com/facebookresearch/omni3d)用Docker

## Build docker image with nvidia-runtime

1. install nvidia-container-runtime

```bash
sudo apt install nvidia-container-runtime
```

2. Edit your `/etc/docker/daemon.json` as follows

```json
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
         }
    },
    "default-runtime": "nvidia"
}
```

3. restart docker

```bash
sudo systemctl restart docker
```

## How to build

```bash
cd omni3d_docker
docker build -t omni3d:noetic .
```

## Export Singularity (if you needed)

```bash
singularity build --sandbox --fakeroot sandbox_omni3d docker-daemon://omni3d:noetic
```
