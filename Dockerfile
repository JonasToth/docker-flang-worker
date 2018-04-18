FROM buildbot/buildbot-worker:master

USER root

RUN apt-get update
RUN apt-get install -y build-essential cmake

# ----------------------- Compilation of dependencies -------------------------

### 1. Flang LLVM
WORKDIR /build-llvm
RUN git clone --progress https://github.com/flang-compiler/llvm.git

WORKDIR /build-llvm/llvm
RUN git checkout release_60

WORKDIR /build-llvm/llvm/build/
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)
RUN make install

WORKDIR /
RUN rm -rf /build-llvm


### 2. flang driver
WORKDIR /build-flang
RUN git clone --progress https://github.com/flang-compiler/flang-driver.git

WORKDIR /build-flang/flang-driver
RUN git checkout release_60

WORKDIR /build-flang/flang-driver/build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)
RUN make install

WORKDIR /
RUN rm -rf /build-flang


### 3. OpenMP runtime library
WORKDIR /build-openmp
RUN git clone https://github.com/llvm-mirror/openmp.git

WORKDIR /build-openmp/openmp/runtime
RUN git checkout release_60

WORKDIR /build-openmp/openmp/runtime/build
RUN cmake ../.. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)
RUN make install

WORKDIR /
RUN rm -rf /build-openmp


### 4. flang
WORKDIR /build-flang
RUN git clone --progress https://github.com/flang-compiler/flang.git

WORKDIR /build-flang/flang

WORKDIR /build-flang/flang/build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/ \
    -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_Fortran_COMPILER=flang
RUN make -j$(nproc)
RUN make install

WORKDIR /
RUN rm -rf /build-flang


# ------------------------- Clean up ------------------------------

### Remove initial build packages
RUN apt-get autoremove -y build-essential cmake
