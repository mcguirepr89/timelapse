# timelapse
A little tool to make timelapse videos from RTSP streams

## Install as a `.deb` package
1. Import the public PGP key as GPG key
   ```
   wget -O- https://apt.pmcgui.xyz/mcguirepr89@gmail.com.gpg.key \
     | gpg --dearmor \
     | sudo tee /usr/share/keyrings/timelapse.gpg >/dev/null
   ```
1. Add the repo to your APT sources list
   ```
   echo "deb [signed-by=/usr/share/keyrings/timelapse.gpg] https://apt.pmcgui.xyz/ any-version main" \
     | sudo tee /etc/apt/sources.list.d/timelapse.list
   ```
1. Update your system (to fetch the new repo) and install `timelapse`
   ```
   sudo apt update && sudo apt -y install timelapse
   ```

## . . . then start systemd timers (which will trigger the services)
1. ```
   sudo systemctl enable --now timelapse_stills.timer
   ```
1. ```
   sudo systemctl enable --now timelapse.timer
   ```
1. ```
   sudo systemctl enable --now timelapse_fast.timer
   ```
   
---

## How to build the Docker container

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
