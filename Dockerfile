FROM alpine:3.17
WORKDIR /
ENV TZ=/usr/share/zoneinfo/America/New_York
COPY crontab.example /
RUN apk add --no-cache bash ffmpeg busybox-openrc tzdata \
  && crontab /crontab.example \
  && ln -sf $TZ /etc/localtime
ENTRYPOINT ["crond", "-f"]
