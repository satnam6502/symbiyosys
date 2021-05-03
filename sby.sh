#!/bin/bash
docker run --rm -v $(pwd):$(pwd) -u $(id -u) --workdir=$(pwd) satnam6502/symbiyosys $@
