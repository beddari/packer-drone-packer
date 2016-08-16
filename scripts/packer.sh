#!/bin/sh -ex

if [ "x$(pwd)" = "x/" ]; then
    cwd="/root"
fi

dnf -y update
dnf -y install libvirt-client git make patch golang qemu-system-x86 qemu-img

mkdir -p ${cwd}/tmp/src/github.com/mitchellh/packer ${cwd}/bin
git clone --depth=1 https://github.com/mitchellh/packer.git ${cwd}/tmp/src/github.com/mitchellh/packer

export GOPATH=${cwd}/tmp GOBIN=${cwd}/bin PATH=${PATH}:${cwd}/bin GO15VENDOREXPERIMENT=1
pushd ${cwd}/tmp/src/github.com/mitchellh/packer
make deps
curl -Ls https://github.com/mitchellh/packer/pull/3473.patch | git apply -
curl -Ls https://github.com/mitchellh/packer/pull/3681.patch | git apply -
curl -Ls https://github.com/mitchellh/packer/pull/3790.patch | git apply -
popd
go build -x -tags netgo -v -o /usr/local/bin/packer github.com/mitchellh/packer
dnf -y remove git-core make patch golang
rm -rf ${cwd}/tmp
