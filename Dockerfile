FROM alpine:3.17
WORKDIR /
COPY timelapse.sh timelapse.conf crontab.example /
RUN apk add --no-cache bash ffmpeg busybox-openrc \
  && crontab crontab.example
ENTRYPOINT ["crond", "-f"]
