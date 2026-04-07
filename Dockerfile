FROM alpine:3

ARG BAIDUNETDISK_VER=4.17.8

RUN apk add --no-cache wget

RUN wget https://issuepcdn.baidupcs.com/issue/netdisk/LinuxGuanjia/${BAIDUNETDISK_VER}/baidunetdisk_${BAIDUNETDISK_VER}_amd64.deb -O baidunetdisk.deb

FROM jlesage/baseimage-gui:debian-11 AS builder

COPY --from=0 /baidunetdisk.deb /baidunetdisk.deb

COPY overlay/ /

RUN apt update \
 && apt upgrade -y --no-install-recommends \

 && apt install -y --no-install-recommends \
    libgtk-3-0 libnotify4 libnss3 libxss1 xdg-utils libatspi2.0-0 libsecret-1-0 \
    libgbm1 libasound2 ttf-wqy-zenhei \

 && dpkg -i /baidunetdisk.deb \
 && rm /baidunetdisk.deb \

 && apt clean autoclean \
 && apt autoremove -y --purge \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/

FROM scratch

COPY --from=builder / /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=3 \
    S6_SERVICE_DEPS=1 \
    USER_ID=1000 \
    GROUP_ID=1000 \
    APP_USER=app \
    XDG_DATA_HOME=/config/xdg/data \
    XDG_CONFIG_HOME=/config/xdg/config \
    XDG_CACHE_HOME=/config/xdg/cache \
    XDG_RUNTIME_DIR=/tmp/run/user/app \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=768 \
    APP_NAME="BaiduNetDisk" \
    NOVNC_LANGUAGE="en_US" \
    TZ=America/New_York

EXPOSE 5800

VOLUME ["/config/downloads", "/config/.config"]

WORKDIR /tmp

ENTRYPOINT ["/init"]
