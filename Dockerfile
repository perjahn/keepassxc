FROM ubuntu AS build

WORKDIR /app

RUN apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
      build-essential \
      p7zip-full \
      git \
      lsb-release \
      cmake \
      g++ \
      qt6-5compat-dev \
      qt6-base-dev \
      qt6-base-dev-tools \
      qt6-base-private-dev \
      qt6-svg-dev \
      qt6-tools-dev \
      libqt6network6 \
      zlib1g-dev \
      asciidoctor \
      libargon2-dev \
      libbotan-3-dev \
      libgcrypt20-dev \
      libkeyutils-dev \
      libminizip-dev \
      libpcsclite-dev \
      libqrencode-dev \
      libquazip5-dev \
      libreadline-dev \
      libsodium-dev \
      libusb-1.0.0-dev \
      libxi-dev \
      libxkbcommon-dev \
      libxtst-dev \
      libykpers-1-dev \
      libyubikey-dev \
      autoconf \
      automake \
      libtool \
      pkg-config

RUN lsb_release -a && \
    uname -a

RUN git clone https://github.com/keepassxreboot/keepassxc

RUN cd keepassxc && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=OFF -DWITH_XC_ALL=ON -DKPXC_DEV_BOTAN3=ON .. && \
    make

RUN mkdir static && \
    cp keepassxc/build/src/keepassxc static && \
    cd static && \
    ldd keepassxc | awk '{print $3}' | xargs -I__ cp __ . && \
    ls -la && \
    7z a -mx9 ../keepassxc_static_runtime.7z && \
    cd .. && \
    ls -la


FROM ubuntu AS runtime

WORKDIR /app

COPY --from=build /app/keepassxc_static_runtime.7z /app
COPY --from=build /app/static /app

RUN ls -la

ENV LD_LIBRARY_PATH=/app

ENTRYPOINT ["/app/keepassxc"]
