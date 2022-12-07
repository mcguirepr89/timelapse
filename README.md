# timelapse
A little tool to make timelapse videos from RTSP streams

---

## How to build the Docker container (recommended)

1. Ensure docker is installed
1. Clone this repo: `git clone https://github.com/mcguirepr89/timelapse.git`
1. Edit `app/timelapse.conf` (as a regular user)
1. Edit `crontab.example` if you want to customize the schedule (edit as root user)
1. Edit `docker-compose.yml` if you want to change the ports `caddy` uses (default 80 & 443)
1. Export your shell's environment for the build:
   (Copy and paste the following into your shell):
   ```
   export TZ=$(readlink -f /etc/localtime)
   export uid=$(id $(whoami) | sed "s/ /\n/g;s/($(whoami))//g" | grep uid)
   export gid=$(id $(whoami) | sed "s/ /\n/g;s/($(whoami))//g" | grep gid)
   ```
1. Bring up and build your new docker service:
   `docker compose up -d`

---

## Install as a `.deb` package . . .
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

See [`deb_docs`](https://github.com/mcguirepr89/timelapse/blob/main/deb_docs) for more information.
   

