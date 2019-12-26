#!/bin/bash
#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euxo pipefail

### Build release artifacts using Bazel.
rm -rf bazelisk bin
mkdir bin
ARCH=$(uname -m)

case ${ARCH:-} in
'aarch64')
    binary_arch='arm64'
    ;;
'x86_64')
    binary_arch='amd64'
    ;;
*)
    echo 'Cpu architecture is not supportted!'
    exit 1
    ;;
esac


go build
for platform in darwin linux windows; do
    ./bazelisk build \
        -c opt \
        --stamp \
        --workspace_status_command="$PWD/stamp.sh" \
        --platforms=@io_bazel_rules_go//go/toolchain:${platform}_${binary_arch} \
        //:bazelisk
    if [[ $platform == windows ]]; then
        cp bazel-bin/${platform}_*/bazelisk.exe bin/bazelisk-${platform}-${binary_arch}.exe
    else
        cp bazel-bin/${platform}_*/bazelisk bin/bazelisk-${platform}-${binary_arch}
    fi
done
rm -f bazelisk

### Build release artifacts using `go build`.
# GOOS=linux GOARCH=amd64 go build -o bin/bazelisk-linux-amd64
# GOOS=darwin GOARCH=amd64 go build -o bin/bazelisk-darwin-amd64
# GOOS=windows GOARCH=amd64 go build -o bin/bazelisk-windows-amd64.exe

### Print some information about the generated binaries.
ls -lh bin/*
file bin/*
