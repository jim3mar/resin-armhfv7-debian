#!/bin/bash

set -o errexit

SUITES='sid wheezy jessie'
MIRROR='ftp://ftp.debian.org/debian/'
REPO='resin/armv7hf-debian'
LATEST='jessie'

for suite in $SUITES; do
	dir=$(mktemp --tmpdir=/var/tmp -d)
	date=$(date +'%F')
	
	mkdir -p $dir/rootfs/usr/bin
	cp qemu-arm-static $dir/rootfs/usr/bin
	chmod +x $dir/rootfs/usr/bin/qemu-arm-static
	
	./mkimage.sh -t $REPO:$suite --dir=$dir debootstrap --variant=minbase --arch=armhf --include=sudo $suite $MIRROR
	rm -rf $dir
	
	docker tag -f $REPO:$suite $REPO:$suite-$date
	if [ $LATEST == $suite ]; then
		docker tag -f $REPO:$suite $REPO:latest
	fi
done