MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(realpath $(dir $(MAKEFILE_PATH)))

include ../Makefile.am

# Distro Params
distro?=debian
DISTRO_DIR=${MAKEFILE_DIR}/distros/${distro}
# FS parameters
FS_FILE_NAME=netkit-fs-${NETKIT_BUILD_RELEASE}
FS_RELEASE=bullseye
FS_SIZE=4G
DEBIAN_MIRROR=http://ftp.uk.debian.org/debian

# Build parameters
BUILD_DIR=${MAKEFILE_DIR}/build
NETKIT_DIR=${BUILD_DIR}/netkit-jh
FS_DIR=${NETKIT_DIR}/fs
MOUNT_DIRECTORY=${BUILD_DIR}/mount-point

# Path to the build kernel modules
MODULES_PATH=../kernel/build/kernel_modules/

.DEFAULT_GOAL := ${FS_DIR}/${FS_FILE_NAME}

.PHONY: clean
clean:
	umount ${MOUNT_DIRECTORY} || /bin/true
	rm -rf ${BUILD_DIR}
	rm -rf ${FS_DIR}
	rm -rf ${MOUNT_DIRECTORY}

.PHONY: mrproper
mrproper: clean
	rm -rf ../${FS_ARCHIVE_FILE}

.PHONY: archive
archive: ../${FS_ARCHIVE_FILE}

${MODULES_PATH}:
	$(error "No kernel modules found, please build the kernel before building the filesystem!")
	
${BUILD_DIR}/bootstrap-fs:
	mkdir -p ${BUILD_DIR}
	mkdir -p ${FS_DIR}
	mkdir -p ${MOUNT_DIRECTORY}
	
	# Check directory isn't already mounted
	umount ${MOUNT_DIRECTORY} || /bin/true
	
	# Create an empty file FS_FILE_NAME and mount it to MOUNT_DIRECTORY
	dd if=/dev/zero of=${BUILD_DIR}/bootstrap-fs bs=1 count=0 seek=${FS_SIZE}
	mke2fs -F ${BUILD_DIR}/bootstrap-fs
	mount ${BUILD_DIR}/bootstrap-fs ${MOUNT_DIRECTORY}
	
	# Then bootstrap, installing to MOUNT_DIRECTORY
	${DISTRO_DIR}/bootstrap.sh ${MOUNT_DIRECTORY} ${DISTRO_DIR}

${FS_DIR}/${FS_FILE_NAME}: ${MODULES_PATH} ${BUILD_DIR}/bootstrap-fs
	# Run the install script, which will install packages, kernel modules and setup services
	echo "Netkit-JH filesystem version ${NETKIT_FS_RELEASE} (${NETKIT_BUILD_RELEASE})" > ${FS_DIR}/netkit-filesystem-version
	
	# Run distro-specific pre-install script
	${DISTRO_DIR}/pre-install-netkit-fs.sh ${MAKEFILE_DIR} ${FS_DIR} ${MOUNT_DIRECTORY} ${MODULES_PATH} ${DISTRO_DIR}
	# Run the install script which will install packages, kernel modules and setup services
	${MAKEFILE_DIR}/install-netkit-fs.sh ${MAKEFILE_DIR} ${FS_DIR} ${MOUNT_DIRECTORY} ${MODULES_PATH} ${DISTRO_DIR}
	# Run distro-specific post-install script
	${DISTRO_DIR}/post-install-netkit-fs.sh ${MAKEFILE_DIR} ${FS_DIR} ${MOUNT_DIRECTORY} ${MODULES_PATH} ${DISTRO_DIR}
	
	# Unmount the directory
	umount ${MOUNT_DIRECTORY}
	
	# Now create the sparse filesystem and create symlink
	cp --sparse=always ${BUILD_DIR}/bootstrap-fs ${FS_DIR}/${FS_FILE_NAME}
	cd ${FS_DIR} ; ln -sf ${FS_FILE_NAME} netkit-fs
	
	# Update version
	echo "Netkit-JH filesystem version ${NETKIT_FS_RELEASE} (${NETKIT_BUILD_RELEASE})" > ${FS_DIR}/netkit-filesystem-version

../${FS_ARCHIVE_FILE}: ${FS_DIR}/${FS_FILE_NAME}
	cd ${BUILD_DIR}/ ; tar -cvSjf ../../${FS_ARCHIVE_FILE} netkit-jh/
