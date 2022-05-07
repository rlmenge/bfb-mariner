#  docker build -t bfb_runtime_mariner -f Dockerfile .
FROM --platform=linux/arm64 cblmariner2preview.azurecr.io/base/core:2.0
ADD qemu-aarch64-static /usr/bin/

WORKDIR /root/workspace
ADD install.sh .
ADD create_bfb .
ADD update.cap .
ADD mlx_drop.repo /etc/yum.repos.d/

ENV kernel=5.15.26.1-2.cm2
ENV RUN_FW_UPDATER=no
RUN yum install -y dnf

RUN dnf install -y util-linux dnf-utils netplan openssh-server iproute which git selinux-policy-devel diffutils file procps-ng patch rpm-build kernel-$kernel kernel-devel-$kernel kernel-headers-$kernel python3-devel python3-test python3-Cython efibootmgr efivar grub2 grub2-efi grub2-efi-unsigned shim-unsigned-aarch64 device-mapper-persistent-data lvm2 acpid popt-devel bc flex bison edac-utils lm_sensors re2c ninja-build meson cryptsetup rasdaemon pciutils-devel watchdog python3-sphinx python3-six kexec-tools jq dbus libgomp iana-etc libgomp-devel libgcc-devel libgcc-atomic libmpc binutils libsepol-devel iptables glibc-devel gcc tcl-devel automake libmnl autoconf tcl libnl3-devel openssl-devel libstdc++-devel binutils-devel libselinux-devel libnl3 libdb-devel make libmnl-devel iptables-devel lsof desktop-file-utils doxygen cmake cmake3 libcap-ng-devel systemd-devel ncurses-devel kmod
RUN depmod -a $kernel
# RUN yum-config-manager --dump docas

RUN dnf install -y gpio-mlxbf gpio-mlxbf2 ibacm infiniband-diags infiniband-diags-compat ipmb-dev-int kernel-mft knem knem-modules libibumad libibverbs libibverbs-utils librdmacm librdmacm-utils mlnx-dpdk mlnx-dpdk-devel mlnx-tools mlx-bootctl mlx-trio mlxbf-bootctl mlxbf-bootimages mlxbf-livefish mlxbf-pmc mstflint ofed-scripts opensm opensm-devel opensm-libs opensm-static rdma-core rdma-core-devel srp_daemon tmfifo ucx ucx-cma ucx-devel ucx-ib ucx-rdmacm 

RUN depmod -a $kernel
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-devel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-modules)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-source)
RUN rpm -iv --nodeps mlnx-ofa_kernel*rpm

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location openvswitch)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location openvswitch-devel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location python3-openvswitch)
RUN rpm -Uv --nodeps *openvswitch*rpm

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlxbf-bfscripts)
RUN rpm -iv --nodeps mlxbf-bfscripts*rpm

# RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location bf-release)
# RUN rpm -iv --nodeps bf-release*rpm

RUN /bin/rm -f *rpm

CMD ["/root/workspace/create_bfb", "-k", "$kernel"]
