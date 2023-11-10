FROM ubuntu as build

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
      qtbase5-dev \
      qtbase5-private-dev \
      qttools5-dev \
      qttools5-dev-tools \
      zlib1g-dev \
      asciidoctor \
      libargon2-dev \
      libbotan-2-dev \
      libgcrypt20-dev \
      libkeyutils-dev \
      libminizip-dev \
      libpcsclite-dev \
      libqrencode-dev \
      libqt5svg5-dev \
      libqt5x11extras5-dev \
      libquazip5-dev \
      libreadline-dev \
      libsodium-dev \
      libusb-1.0.0-dev \
      libxi-dev \
      libxtst-dev \
      libykpers-1-dev \
      libyubikey-dev

RUN lsb_release -a && \
    uname -a

RUN git clone https://github.com/keepassxreboot/keepassxc

RUN cd keepassxc && \
    mkdir build && \
    cd build && \
    cmake -DWITH_XC_ALL=ON .. && \
    make

RUN mkdir slim && \
    cp keepassxc/build/src/keepassxc slim && \
    cd slim && \
    cp /usr/lib/*-linux-gnu/libbotan-2.so.19 . && \
    cp /usr/lib/*-linux-gnu/libtspi.so.1 . && \
    7z a -mx9 ../keepassxc_slim_runtime.7z && \
    cd .. && \
    ls -la

RUN mkdir full && \
    cp keepassxc/build/src/keepassxc full && \
    cd full && \
    ldd keepassxc | awk '{print $3}' | xargs -I__ cp __ . && \
    ls -la && \
    7z a -mx9 ../keepassxc_full_runtime.7z && \
    cd .. && \
    ls -la


FROM ubuntu as runtime

WORKDIR /app

COPY --from=build /app/keepassxc_slim_runtime.7z /app
COPY --from=build /app/keepassxc_full_runtime.7z /app
COPY --from=build /app/full /app

RUN ls -la

ENV LD_LIBRARY_PATH=/app

ENTRYPOINT ["/app/keepassxc"]
