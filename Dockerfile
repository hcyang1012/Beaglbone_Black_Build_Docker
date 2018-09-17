FROM ubuntu:latest
MAINTAINER Heecheol Yang <heecheol.yang@outlook.com>

# Update required packages
RUN apt-get update
RUN apt-get -qq -y install git curl build-essential vim wget bash ssh bc lsb-release lzma lzop man-db gettext bison flex pkg-config libncurses5-dev libssl-dev:amd64

#Make working dorectory
RUN mkdir -p /root/work/tools

#Download toolchain for uboot
RUN cd /root/work/tools && wget -c https://releases.linaro.org/components/toolchain/binaries/6.4-2018.05/arm-linux-gnueabihf/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz --no-check-certificate
RUN cd /root/work/tools && tar xf gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz
ENV CC=/root/work/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

# Download toolchain for Linux kernel
RUN cd /root/work/ && git clone https://github.com/RobertCNelson/bb-kernel
RUN cd /root/work/bb-kernel && git checkout origin/am33x-v4.9 -b tmp
RUN cd /root/work/bb-kernel && git clone https://github.com/hcyang1012/Beaglbone_Black_Build_Docker.git
RUN cd /root/work/bb-kernel && patch -p0 < Beaglbone_Black_Build_Docker/BBB_TOOLCHAIN_DOWNLOAD_PATCH

#Build uboot
RUN cd /root/work/ && git clone https://github.com/u-boot/u-boot
RUN cd /root/work/u-boot && git checkout v2018.09-rc2 -b tmp
RUN cd /root/work/u-boot && wget -c https://rcn-ee.com/repos/git/u-boot-patches/v2018.09-rc2/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
RUN cd /root/work/u-boot && wget -c https://rcn-ee.com/repos/git/u-boot-patches/v2018.09-rc2/0002-U-Boot-BeagleBone-Cape-Manager.patch 
RUN cd /root/work/u-boot && patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch 
RUN cd /root/work/u-boot && patch -p1 < 0002-U-Boot-BeagleBone-Cape-Manager.patch 
RUN cd /root/work/u-boot && make ARCH=arm CROSS_COMPILE=${CC} distclean
RUN cd /root/work/u-boot && make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_defconfig
RUN cd /root/work/u-boot && make ARCH=arm CROSS_COMPILE=${CC}

# Build Linux Kernel
ENV AUTO_BUILD=1
RUN cd /root/work/bb-kernel && ./build_kernel.sh


#Run bash shell
CMD ["/bin/bash"]
