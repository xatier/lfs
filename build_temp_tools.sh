#!/usr/bin/env bash

# This script build Chapter 6 of LFS
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/introduction.html


# ensure the LFS variable is present
LFS="/mnt/lfs"
LFS_TGT="XXXXXX"

cd "$LFS/sources" || {
    echo "No $LFS/sources directory"
    exit 1
}

# m4
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/m4.html
tar xvf m4-1.4.18.tar.xz
pushd m4-1.4.18

sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >>lib/stdio-impl.h

./configure --prefix=/usr --host="$LFS_TGT" --build=$(build-aux/config.guess)
make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# ncurses
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/ncurses.html
tar xvf ncurses-6.2.tar.gz
pushd ncurses-6.2

sed -i s/mawk// configure
mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd

./configure --prefix=/usr                \
            --host="$LFS_TGT"            \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec

make -j "$(nproc)"
make DESTDIR="$LFS" TIC_PATH="$PWD"/build/progs/tic install
echo "INPUT(-lncursesw)" > "$LFS"/usr/lib/libncurses.so
mv -v "$LFS"/usr/lib/libncursesw.so.6* "$LFS"/lib
ln -sfv ../../lib/"$(readlink "$LFS"/usr/lib/libncursesw.so)" "$LFS"/usr/lib/libncursesw.so
popd


# bash
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/bash.html
tar xvf bash-5.0.tar.gz
pushd bash-5.0

./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host="$LFS_TGT"               \
            --without-bash-malloc

make -j "$(nproc)"
make DESTDIR="$LFS" install
mv "$LFS"/usr/bin/bash "$LFS"/bin/bash
ln -sv bash "$LFS"/bin/sh
popd


# coreutils
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/coreutils.html
tar xvf coreutils-8.32.tar.xz
pushd coreutils-8.32

./configure --prefix=/usr                     \
            --host="$LFS_TGT"                 \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make -j "$(nproc)"
make DESTDIR="$LFS" install

mv -v "$LFS"/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} "$LFS"/bin
mv -v "$LFS"/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        "$LFS"/bin
mv -v "$LFS"/usr/bin/{rmdir,stty,sync,true,uname}               "$LFS"/bin
mv -v "$LFS"/usr/bin/{head,nice,sleep,touch}                    "$LFS"/bin
mv -v "$LFS"/usr/bin/chroot                                     "$LFS"/usr/sbin
mkdir -pv "$LFS"/usr/share/man/man8
mv -v "$LFS"/usr/share/man/man1/chroot.1                        "$LFS"/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                                           "$LFS"/usr/share/man/man8/chroot.8
popd


# diffutils
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/diffutils.html
tar xvf diffutils-3.7.tar.xz
pushd diffutils-3.7

./configure --prefix=/usr --host="$LFS_TGT"

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# file
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/file.html
tar xvf file-5.39.tar.gz
pushd file-5.39

./configure --prefix=/usr --host="$LFS_TGT"

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd

# findutils
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/findutils.html
tar xvf findutils-4.7.0.tar.xz
pushd findutils-4.7.0

./configure --prefix=/usr --host="$LFS_TGT" --build=$(build-aux/config.guess)

make -j "$(nproc)"
make DESTDIR="$LFS" install
mv -v "$LFS"/usr/bin/find "$LFS"/bin
sed -i 's|find:=${BINDIR}|find:=/bin|' "$LFS"/usr/bin/updatedb
popd


# gawk
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/gawk.html
tar xvf gawk-5.1.0.tar.xz
pushd gawk-5.1.0

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host="$LFS_TGT" --build=$(build-aux/config.guess)

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# grep
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/grep.html
tar xvf grep-3.4.tar.xz
pushd grep-3.4

./configure --prefix=/usr --host="$LFS_TGT" --bindir=/bin

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# gzip
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/gzip.html
tar xvf gzip-1.10.tar.xz
pushd gzip-1.10

./configure --prefix=/usr --host="$LFS_TGT"

make -j "$(nproc)"
make DESTDIR="$LFS" install
mv -v "$LFS"/usr/bin/gzip "$LFS"/bin
popd

# make
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/make.html
tar xvf make-4.3.tar.gz
pushd make-4.3

./configure --prefix=/usr     \
            --without-guile   \
            --host="$LFS_TGT" \
            --build=$(build-aux/config.guess)

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# patch
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/patch.html
tar xvf patch-2.7.6.tar.xz
pushd patch-2.7.6

./configure --prefix=/usr     \
            --host="$LFS_TGT" \
            --build=$(build-aux/config.guess)

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# sed
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/sed.html
tar xvf sed-4.8.tar.xz
pushd sed-4.8

./configure --prefix=/usr     \
            --host="$LFS_TGT" \
            --bindir=/bin

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# tar
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/tar.html
tar xvf tar-1.32.tar.xz
pushd tar-1.32

./configure --prefix=/usr                     \
            --host="$LFS_TGT"                 \
            --build=$(build-aux/config.guess) \
            --bindir=/bin

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# xz
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/xz.html
tar xvf xz-5.2.5.tar.xz
pushd xz-5.2.5

./configure --prefix=/usr                     \
            --host="$LFS_TGT"                 \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5

make -j "$(nproc)"
make DESTDIR="$LFS" install

mv -v "$LFS"/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} "$LFS"/bin
mv -v "$LFS"/usr/lib/liblzma.so.*                      "$LFS"/lib
ln -svf ../../lib/"$(readlink "$LFS"/usr/lib/liblzma.so)" "$LFS"/usr/lib/liblzma.so
popd


# binutils
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/binutils-pass2.html
pushd binutils-2.35
cd build
rm -rf *

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host="$LFS_TGT"          \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd

make -j "$(nproc)"
make DESTDIR="$LFS" install
popd


# gcc
# http://www.linuxfromscratch.org/lfs/view/10.0/chapter06/gcc-pass2.html
pushd gcc-10.2.0
cd build
rm -rf *
mkdir -pv "$LFS_TGT"/libgcc
ln -s ../../../libgcc/gthr-posix.h "$LFS_TGT"/libgcc/gthr-default.h

../configure                                       \
    --build=$(../config.guess)                     \
    --host="$LFS_TGT"                              \
    --prefix=/usr                                  \
    CC_FOR_TARGET="$LFS_TGT"-gcc                   \
    --with-build-sysroot="$LFS"                    \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make -j "$(nproc)"
make DESTDIR="$LFS" install
ln -sv gcc "$LFS"/usr/bin/cc
popd
