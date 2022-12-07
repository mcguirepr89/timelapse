FROM alpine:3.17
WORKDIR /
ARG user
ARG tz
RUN apk add --no-cache bash ffmpeg busybox-openrc libcap tzdata \
  && ln -sf $tz /etc/localtime \
  && addgroup $user \
  && adduser -DG $user $user \
  && setcap cap_setgid=ep /bin/busybox
ENTRYPOINT ["crond", "-f"]
