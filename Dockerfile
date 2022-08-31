FROM debian:stretch-slim

RUN apt update && apt install -y \
    device-tree-compiler \
    git \
    make \
    python \
    wget

RUN if ![ -x python ]; then ln -s /usr/bin/python2.7 /usr/bin/python ;fi


# 发布构建镜像
# docker buildx build --platform linux/amd64 -t kuaifan/gl_imagebuilder:0.0.2 ./gl_imagebuilder --push