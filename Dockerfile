FROM buildbot/buildbot-worker:master

USER root

RUN apt update
RUN apt install -y build-essential cmake git

# Compilation of dependencies
USER buildbot
WORKDIR /build-llvm

RUN git clone https://github.com/llvm-mirror/llvm.git
RUN cd llvm

# Modify this line to get another LLVM release
RUN git checkout release_50

RUN mkdir build && cd build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel; make -j$(nproc)

USER root
RUN make install
