#!/usr/bin/env bash

# This script build Chapter 5 of LFS
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/introduction.html


# ensure the LFS variable is present
LFS="/mnt/lfs"
LFS_TGT="XXXXXX"

cd "$LFS/sources" || {
    echo "No $LFS/sources directory"
    exit 1
}


# binutils
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/binutils-pass1.html
tar xvf binutils-2.35.tar.xz
pushd binutils-2.35

mkdir -v build && pushd build
../configure --prefix="$LFS/tools" \
             --with-sysroot="$LFS" \
             --target="$LFS_TGT"   \
             --disable-nls         \
             --disable-werror

make -j "$(nproc)"
make install
popd
popd


# gcc (with mpfr, gmp, mpc)
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/gcc-pass1.html
tar xvf gcc-10.2.0.tar.xz
pushd gcc-10.2.0

tar xvf ../mpfr-4.1.0.tar.xz
mv mpfr-4.1.0 mpfr
tar xvf ../gmp-6.2.0.tar.xz
mv gmp-6.2.0/ gmp
tar xvf ../mpc-1.1.0.tar.gz
mv mpc-1.1.0/ mpc

# set the default directory name for 64-bit libraries to “lib”
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

mkdir -v build && pushd build

# note that on Arch glibc = 2.32
../configure                  \
    --target="$LFS_TGT"       \
    --prefix="$LFS/tools"     \
    --with-glibc-version=2.32 \
    --with-sysroot="$LFS"     \
    --with-newlib             \
    --without-headers         \
    --enable-initfini-array   \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-decimal-float   \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

make -j "$(nproc)"
make install
popd
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/install-tools/include/limits.h
popd


# linux 5.8.3 API header
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/linux-headers.html
tar xvf linux-5.8.3.tar.xz
pushd linux-5.8.3

make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include/ "$LFS/usr"
popd


# glibc-2.32
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/glibc.html
tar xvf glibc-2.32.tar.xz
pushd glibc-2.32

ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64"
ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64/ld-lsb-x86-64.so.3"
patch -Np1 -i ../glibc-2.32-fhs-1.patch
mkdir build && pushd build
../configure                           \
    --prefix=/usr                      \
    --host="$LFS_TGT"                  \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2                \
    --with-headers="$LFS/usr/include"  \
    libc_cv_slibdir=/lib

make -j1
make DESTDIR="$LFS" install
"$LFS/tools/libexec/gcc/$LFS_TGT"/10.2.0/install-tools/mkheaders
popd
popd


# libstdc++ (inside gcc)
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter05/gcc-libstdc++-pass1.html
pushd gcc-10.2.0
pushd build
../libstdc++-v3/configure      \
    --host="$LFS_TGT"          \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir="/tools/$LFS_TGT/include/c++/10.2.0"

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd
popd
