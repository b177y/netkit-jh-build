#!/bin/bash

# First argument is the work directory, that contains the packages list, package selections, service lists
WORK_DIRECTORY="$1"
# Second argument is the build directory, that contains the filesystem version file
BUILD_DIRECTORY="$2"
# Third argument is the directory which the filesystem is mounted at
MOUNT_DIRECTORY="$3"
# Fourth argument is the kernel module directory which should be copied
KERNEL_MODULES="$4"
# Fifth argument is the distro directory, that contains the packages list, package selections, service lists
DISTRO_DIRECTORY="$5"

source $DISTRO_DIRECTORY/distro.env

# Empty caches
chroot $MOUNT_DIRECTORY apt clean
