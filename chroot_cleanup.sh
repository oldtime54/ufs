#!/bin/bash

sudo chroot chroot umount /proc
sudo chroot chroot umount /sys
sudo chroot chroot umount /dev/pts
sudo umount chroot/dev
sudo umount chroot/run


