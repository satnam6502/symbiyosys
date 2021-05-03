FROM ubuntu:18.04
LABEL maintainer="satnam6502 <satnam6502@gmail.com>"
LABEL description="SymbiYosys hardware verification container"
LABEL version="1.0"

VOLUME /workdir
WORKDIR /workdir

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -qq -y \
                     build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev gperf \
		     libboost-program-options-dev autoconf libgmp-dev \
		     cmake wget curl libpython2.7

# Yosys
RUN git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && make -j$(nproc) && make install

# SimiYosys
RUN git clone https://github.com/YosysHQ/SymbiYosys.git SymbiYosys && \
    cd SymbiYosys && make install

# Yices 2
RUN git clone https://github.com/SRI-CSL/yices2.git yices2 && \
    cd yices2 && autoconf && ./configure && make -j$(nproc) && make install

# Z3
RUN git clone https://github.com/Z3Prover/z3.git z3 && \
    cd z3 && python scripts/mk_make.py && cd build && make -j$(nproc) && make install

# super_prove
RUN ln -s /lib/x86_64-linux-gnu/libreadline.so.7 /lib/x86_64-linux-gnu/libreadline.so.6
RUN wget https://github.com/sterin/super-prove-build/releases/download/hwmcc20-2/super_prove-hwmcc20-2-Ubuntu_18.04-Release.tar.gz
RUN echo '#!/bin/bash' > /usr/local/bin/suprove ; \
    echo 'tool=super_prove; if [ "$1" != "${1#+}" ]; then tool="${1#+}"; shift; fi' >> /usr/local/bin/suprove ; \
    echo 'exec /usr/local/super_prove/bin/${tool}.sh "$@"' >> /usr/local/bin/suprove ; \
    chmod +x /usr/local/bin/suprove

# Avy
RUN git clone https://bitbucket.org/arieg/extavy.git && \
    cd extavy && git submodule update --init && mkdir build; cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc) && \
    cp ./avy/src/avy /usr/local/bin && \
    cp ./avy/src/avybmc /usr/local/bin

# Boolector
RUN git clone https://github.com/boolector/boolector && \
    cd boolector && ./contrib/setup-btor2tools.sh && \
    ./contrib/setup-lingeling.sh && ./configure.sh && \
    make -C build -j$(nproc) && \
    cp build/bin/boolector /usr/local/bin && \
    cp build/bin/btor* /usr/local/bin && \
    cp deps/btor2tools/bin/btorsim /usr/local/bin/

# Btor2Tools
RUN git clone https://github.com/Boolector/btor2tools && \
    ./configure.sh && cd build && make && \
    mv bin/btorsim /usr/local/bin/btorsim

ENTRYPOINT ["/usr/local/bin/sby"]

