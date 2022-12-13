FROM alpine:3.17
WORKDIR /
ARG user
RUN apk add --no-cache bash ffmpeg busybox-openrc libcap \
  && addgroup $user \
  && adduser -DG $user $user \
  && setcap cap_setgid=ep /bin/busybox
USER $user
ENTRYPOINT ["crond", "-f"]
