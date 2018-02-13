FROM buildbot/buildbot-worker:master

USER root

RUN apt-get update
RUN apt-get install -y build-essential cmake git

# ----------------------- Compilation of dependencies -------------------------

### LLVM
# USER buildbot
WORKDIR ~/build-llvm

RUN git clone https://github.com/llvm-mirror/llvm.git
RUN cd llvm

# Modify this line to get another LLVM release
RUN git checkout release_50

RUN mkdir build && cd build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

# USER root
RUN make install
RUN rm -rf ~/build-llvm

### flang driver
# USER buildbot
WORKDIR ~/build-flang

RUN git clone https://github.com/flang-compiler/clang.git
RUN cd clang
RUN git checkout flang_release_50

RUN mkdir build && cd build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

# USER root
RUN make install
RUN rm -rf ~/build-flang


### OpenMP libraries
# USER buildbot
WORKDIR ~/build-openmp

RUN git clone https://github.com/llvm-mirror/openmp.git
RUN cd cd openmp/runtime
RUN git checkout release_50

RUN mkdir build && cd build
RUN cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=/usr/local/
RUN make -j$(nproc)

# USER root
RUN make install
RUN rm -rf ~/build-openmp

### flang components
# USER buildbot
WORKDIR ~/build-flang

RUN git clone https://github.com/flang-compiler/flang.git
RUN cd flang

RUN mkdir build && cd build

RUN cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_Fortran_COMPILER=flang ..
RUN make -j$(nproc)

# USER root
RUN make install
RUN rm -rf ~/build-flang


# ------------------------- Clean up ------------------------------

### Remove initial build packages
RUN apt-get autoremove build-essential cmake
