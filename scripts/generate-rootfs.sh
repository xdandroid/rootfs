#!/bin/bash

# output complete rootfs.img to following directory
DESTDIR=~/rootfs-output

# temporary directory to use for building rootfs
TMPDIR=~/.tmp

# source git repository to clone
REPO="git://gitorious.org/xdandroid-eclair/eclair-rootfs.git"

# optional, branch to switch to after cloning
#BRANCH="fuze-navipad-remap"

[ ! -d "${DESTDIR}" ] && mkdir -p "${DESTDIR}"
[ ! -d "${TMPDIR}" ] && mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

REPODIR=${REPO##*/}
REPODIR=${REPODIR%.*}
git clone "${REPO}" "${REPODIR}"
cd "${TMPDIR}"/"${REPODIR}"
[ -z ${BRANCH} ] || git checkout "${BRANCH}"

GITDESCRIBE="$(git rev-parse --verify --short HEAD)"
DATE=$(date +%Y%m%d)

cd "${TMPDIR}"
mkdir rootfs

cd "${TMPDIR}"/"${REPODIR}"
./scripts/gitclean.sh
cp -a . "${TMPDIR}"/rootfs
chmod u+s "${TMPDIR}"/rootfs/bin/pppd "${TMPDIR}"/rootfs/bin/su

genext2fs --root "${TMPDIR}"/rootfs -U -N 1024 -m 1 -b 15360 "${DESTDIR}"/rootfs-"${DATE}"-"${GITDESCRIBE}".img
ln -sf "${DESTDIR}"/rootfs-"${DATE}"-"${GITDESCRIBE}".img "${DESTDIR}"/rootfs.img

cd "${TMPDIR}"
rm -Rf rootfs "${REPODIR}"
