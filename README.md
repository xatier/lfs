# Building LFS with Archlinux ISO

This is my note for building Linux [From Scratch 10.0](http://www.linuxfromscratch.org/lfs/view/10.0/) on a VirtualBox VM with [Archlinux ISO](https://www.archlinux.org/download/) image.

## vbox setup

- New VM
  - 8 cores CPU
  - 16G ram
  - 40G hdd
  - arch iso

- NAT port forwarding (host 22222 -> guest 22)

## live environment setup

Boot up the guest VM into Arch live environment.

- grow the root fs so that we have enough space to install the toolings with `pacman` later.

```bash
mount -o remount,size=2G /run/archiso/cowspace
```

- enable `sshd` so that we don't need to type on the VM console.

```bash
dhcpcd
passwd
systemctl start sshd
```

- ssh into the VM (from host)

```bash
ssh root@127.0.0.1 -p 22222
```

## host system requirements

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/hostreqs.html

Install the packages of for the Host System Requirements.

Ignore the `linux` package otherwise `mount` may not be work properly.

```bash
pacman -Sy base base-devel --ignore linux
```

Run the [version check script](http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/hostreqs.html).

```bash
bash version-check.sh
```

Note that Arch may have **newer** versions.

## disk partitions

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/creatingpartition.html

Use `cfdisk` with `MBR`.

Mine is slightly different from the LFS recommendations.

```bash
cfdisk
```

```text
/dev/sda1    /boot    200M (bootable)
/dev/sda2    swap     1G
/dev/sda3    /        rest of the space
```

- `lsblk`

```bash
sda      8:0    0    40G  0 disk 
├─sda1   8:1    0   200M  0 part 
├─sda2   8:2    0     1G  0 part 
└─sda3   8:3    0  38.8G  0 part 
```

Filesystem setup.

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/creatingfilesystem.html
```bash
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon -v /dev/sda2
```

Set the `LFS` environment variable.

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/aboutlfs.html

- this is **VERY** important for LFS.

```bash
export LFS=/mnt/lfs
```

Create and mount rootfs directories.

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter02/mounting.html

```bash
mkdir -pv $LFS
mount -v -t ext4 /dev/sda3 $LFS
mkdir -pv $LFS/boot
mount -v -t ext4 /dev/sda1 $LFS/boot
mkdir -pv $LFS/home
```

## prepare the sources directory for tarballs

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter03/introduction.html

mkdir

```bash
mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources
```

Install wget.

```bash
pacman -S wget
```

Download source tarballs.

```bash
wget 'http://www.linuxfromscratch.org/lfs/view/10.0/wget-list'
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
ls $LFS/sources
```

Integrity check.

```bash
pushd $LFS/sources
wget http://www.linuxfromscratch.org/lfs/view/10.0/md5sums
md5sum -c md5sums
popd
```

## root directories layout

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter04/creatingminlayout.html

Note: I'm running x86_64.

```bash
echo $LFS
mkdir -pv $LFS/{bin,etc,lib,lib64,sbin,tools,usr,var}
```

## setup the `lfs` user

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter04/addinguser.html

The `lfs` user and group are added to the host environment (Arch live CD).

```bash
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
```

Let `lfs` own the root directories.

```bash
chown -v lfs $LFS/{usr,lib,var,etc,bin,sbin,tools,lib64,sources}
```

Drop into the `lfs` user.

```bash
su - lfs
```

Basic BASH settings.

Ref: http://www.linuxfromscratch.org/lfs/view/10.0/chapter04/settingenvironment.html

```bash
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
```

```bash
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
export LFS LC_ALL LFS_TGT PATH
EOF
```

Source the settings and final check.

```bash
source ~/.bash_profile
echo $LFS
```

## start building

See scripts

- build_cross_toolchain.sh
- build_temp_tools.sh
