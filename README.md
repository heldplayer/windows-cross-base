# windows-cross-base

Repository containing the base Docker image for cross-compiling Windows apps from Linux using LLVM.

## Building the Docker container

I generally use the following command to build in bash:
```bash
docker build --tag=cross --build-arg USER_ID=$(id -u) --build-arg USER_GROUP=$(id -g) .
```

## Using the Docker container

The general usage pattern I used is to build the container, then when running it just dropping myself into a bash shell:
```bash
docker run --rm -it -v $(pwd):/data cross bash
```
