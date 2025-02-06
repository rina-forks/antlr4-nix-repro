#!/bin/bash

set -e -o pipefail

export CXXFLAGS
export CFLAGS
cd "$(dirname "$0")"

# exhibits bug
ref=5b2753b0356d1c951d7a3ef1d086ba5a71fff43c

# just before https://github.com/NixOS/nixpkgs/pull/354371
ref=71ab6ba171686f41d8f058d3f8a73dd226f803d9

mkdir -p build && cd build
if ! [[ -f antlr-jar ]]; then
  nix build "nixpkgs/$ref#antlr.src" -o antlr-jar
fi
if ! [[ -d antlr-dev ]]; then
  nix build "nixpkgs/$ref#antlr.runtime.cpp^dev" -o antlr
fi

cd ..

  # -DCMAKE_BUILD_TYPE=Release \
cmake -B build \
  -DCMAKE_PREFIX_PATH="$(realpath build/antlr-dev)" \
  -DANTLR4_JAR_LOCATION="$(realpath build/antlr-jar)" \
  "$@"
  # -DLLVM_DIR=~/progs/llvm-regehr/build/lib/cmake/llvm/ \
  # -DFETCHCONTENT_SOURCE_DIR_ASLP-CPP=~/progs/aslp \
  # -DCMAKE_VERBOSE_MAKEFILE=TRUE \
cmake --build build
