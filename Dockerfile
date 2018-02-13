FROM buildbot/buildbot-worker:master

USER root

RUN apt-get update
RUN apt-get install -y build-essential cmake wget

# ----------------------- Compilation of dependencies -------------------------

### LLVM
WORKDIR /build-llvm

RUN wget --show-progress http://releases.llvm.org/5.0.1/llvm-5.0.1.src.tar.xz
RUN tar xf llvm-5.0.1.src.tar.xz
WORKDIR /build-llvm/llvm-5.0.1.src

WORKDIR /build-llvm/llvm-5.0.1.src/build/
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

# USER root
RUN make install
WORKDIR /
RUN rm -rf /build-llvm

### flang driver
WORKDIR /build-flang

RUN git clone --progress https://github.com/flang-compiler/clang.git
WORKDIR /build-flang/clang
RUN git checkout flang_release_50

WORKDIR /build-flang/clang/build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

# USER root
RUN make install
WORKDIR /
RUN rm -rf /build-flang


### OpenMP libraries
WORKDIR /build-openmp

RUN wget http://releases.llvm.org/5.0.1/openmp-5.0.1.src.tar.xz
RUN tar xf openmp-5.0.1.src.tar.xz
WORKDIR /build-openmp/openmp-5.0.1.src/runtime

WORKDIR /build-openmp/openmp-5.0.1.src/runtime/build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

RUN make install
WORKDIR /
RUN rm -rf /build-openmp

### flang components
WORKDIR /build-flang

RUN git clone --progress https://github.com/flang-compiler/flang.git
WORKDIR /build-flang/flang

WORKDIR /build-flang/flang/build

RUN cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_Fortran_COMPILER=flang ..
RUN make -j$(nproc)

RUN make install
WORKDIR /
RUN rm -rf /build-flang


# ------------------------- Clean up ------------------------------

### Remove initial build packages
RUN apt-get autoremove build-essential cmake wget
