#!/bin/bash
docker run --rm -v $(pwd):$(pwd) -u $(id -u) --workdir=$(pwd) -it --entrypoint=/bin/bash satnam6502/symbiyosys $@
