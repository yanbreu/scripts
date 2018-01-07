#!/bin/bash
# System Update
# ---------------------------
# Snapshot - Rollback - Btrfs
# ---------------------------
 
MV=/usr/bin/mv
BTRFS=/usr/bin/btrfs
SED=/usr/bin/sed
PACMAN=/usr/bin/pacman
PACAUR=/usr/bin/pacaur
CP=/usr/bin/cp
REFLECTOR=/usr/bin/reflector
SUDO=/usr/bin/sudo
 
# ---------------------------
#      Snapshot System
# ---------------------------
 
# -------- OLDSTABLE --------
 
$SUDO $BTRFS subvolume delete /.snapshots/STABLE
$SUDO $BTRFS subvolume snapshot / /.snapshots/STABLE
$SUDO $SED -i 's/\@[[:space:]]/\@snapshots\/STABLE /g' /.snapshots/STABLE/etc/fstab
$SUDO $CP /boot/vmlinuz-linux /boot/vmlinuz-linux-stable
$SUDO $CP /boot/initramfs-linux.img /boot/initramfs-linux-stable.img
 
# ---------------------------
#      Update System
# ---------------------------
 
$SUDO $REFLECTOR --verbose -l 10 -p https --sort rate --save /etc/pacman.d/mirrorlist
$SUDO $PACMAN -Syu
$PACAUR -Syu
 
# ---------------------------
#    Balance Filesystem
# --------------------------
 
$SUDO $BTRFS balance start -dusage=5 /btrfs
