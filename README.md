# timelapse
A little tool to make timelapse videos from RTSP streams


## How to build the docker container

1. Ensure docker is installed
1. Clone this repo: `git clone https://github.com/mcguirepr89/timelapse.git`
1. Pre-configure your container (edit the `timelapse.conf` file)
1. Build the container: `docker build -t timelapse .`
1. Run the container:
   ```
   docker run -d \
     --name timelapser \
     --mount type=bind,source=$(pwd),target=/videos \
     --tmpfs /stills \
     timelapse:latest
   ```
