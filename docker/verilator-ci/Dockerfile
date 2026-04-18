    # CI 镜像：预编译 Verilator（固定版本），避免每次跑测试都从零编译。
# 构建与推送：见 .github/workflows/verilator-ci-image.yml
#
# 运行时仍需 g++/make：Verilator 会把设计译成 C++ 再在镜像内编译仿真。

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    help2man \
    perl \
    python3 \
    make \
    autoconf \
    g++ \
    flex \
    bison \
    libfl2 \
    libfl-dev \
    zlib1g \
    zlib1g-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ARG VERILATOR_REF=v5.046
RUN git clone --depth 1 --branch "${VERILATOR_REF}" \
        https://github.com/verilator/verilator.git /tmp/verilator-src \
    && cd /tmp/verilator-src \
    && autoconf \
    && ./configure --prefix=/usr/local \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/verilator-src

# 删除仅用于编译 Verilator 本身的依赖，减小体积；保留 git 供 actions/checkout
RUN apt-get update && apt-get purge -y --auto-remove \
    autoconf flex bison libfl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN verilator --version
