#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/nilos.kernel isodir/boot/nilos.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "nilos" {
	multiboot /boot/nilos.kernel
}
EOF
grub-mkrescue -o nilos.iso isodir
