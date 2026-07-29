FROM debian:bookworm-slim AS builder

ARG BITCOINABC_VERSION=0.33.4
ARG BITCOINABC_COMMIT=17ab9b0c050239c4014d3264f893e580f5f2237b
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    cmake \
    ninja-build \
    build-essential \
    pkg-config \
    python3 \
    libevent-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libboost-chrono-dev \
    libboost-test-dev \
    libboost-system-dev \
    libssl-dev \
    libzmq3-dev \
    libsqlite3-dev \
  ; \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  git clone --depth 1 --branch "v${BITCOINABC_VERSION}" https://github.com/Bitcoin-ABC/bitcoin-abc.git /src; \
  test "$(git -C /src rev-parse HEAD)" = "${BITCOINABC_COMMIT}"

RUN set -eux; \
  cmake -S /src -B /build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_QT=OFF \
    -DBUILD_WALLET=OFF \
    -DBUILD_SEEDER=OFF \
    -DBUILD_LIBBITCOINCONSENSUS=OFF \
    -DBUILD_IGUANA=OFF \
    -DBUILD_CHRONIK=OFF \
    -DBUILD_CHRONIK_PLUGINS=OFF \
    -DENABLE_TRACING=OFF \
    -DUSE_JEMALLOC=OFF \
  ; \
  ninja -C /build bitcoind bitcoin-cli bitcoin-tx

RUN strip /build/src/bitcoind /build/src/bitcoin-cli /build/src/bitcoin-tx


FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    libboost-filesystem1.74.0 \
    libboost-thread1.74.0 \
    libboost-chrono1.74.0 \
    libboost-system1.74.0 \
    libssl3 \
    libzmq5 \
    libsqlite3-0 \
  ; \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/src/bitcoind /usr/local/bin/bitcoind
COPY --from=builder /build/src/bitcoin-cli /usr/local/bin/bitcoin-cli
COPY --from=builder /build/src/bitcoin-tx /usr/local/bin/bitcoin-tx

EXPOSE 28337 28338 28339

CMD ["bitcoind", "-datadir=/data", "-conf=/data/bitcoin.conf", "-printtoconsole"]
