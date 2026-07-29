# xecd-abc-docker

Multi-arch Docker image for the eCash (XEC) node (Bitcoin ABC `bitcoind`) built **without jemalloc** to avoid crashes on systems using non-4K memory page sizes (common on some ARM64 kernels).

The Bitcoin ABC source tag and commit are pinned in the Dockerfile. Both
architectures are compiled with `-DUSE_JEMALLOC=OFF`.

Published to GHCR as:

- `ghcr.io/willitmod/xecd-abc:<tag>`
