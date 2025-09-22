FROM oraclelinux:9
LABEL authors="Zhanwei Wang"

COPY --chmod=0755 start-systemd.sh /usr/bin/start-systemd.sh

RUN yum install -y                        \
        gcc-toolset-14                    \
        gcc-toolset-14-gcc                \
        gcc-toolset-14-gcc-c++            \
        gcc-toolset-14-libasan-devel      \
        gcc-toolset-14-libatomic-devel    \
        gcc-toolset-14-liblsan-devel      \
        gcc-toolset-14-libstdc++-devel    \
        gcc-toolset-14-libtsan-devel      \
        gcc-toolset-14-libubsan-devel     \
        gdb                               \
        gdb-gdbserver                     \
    && yum install -y                     \
        clang-19.1.7                      \
        clang-devel-19.1.7                \
        clang-tools-extra-19.1.7          \
        llvm-devel-19.1.7                 \
        llvm-toolset-19.1.7               \
    && yum install -y autoconf automake bison flex git graphviz libtool make perl rpm-build rpm-sign rsync sudo tmux which \
    && yum install -y python3.12 python3.12-pip python-unversioned-command                                \
    && yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo  \
    && yum install -y docker-ce-cli                                                         \
    && yum-config-manager --set-disabled docker-ce-stable                                   \
    && yum clean all                                                                        \
    && ln -s /opt/rh/gcc-toolset-14/enable /etc/profile.d/gcc-toolset.sh                    \
    && /usr/bin/rm -f /etc/profile.d/which2.sh                                              \
    && /usr/bin/rm -f /etc/profile.d/which2.csh

RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
RUN alternatives --install /usr/bin/pip3 pip3.12 /usr/bin/pip-3.12 1
RUN pip3 install --no-cache-dir gcovr breathe

RUN curl -sSfL -o cmake-3.31.8-linux.sh \
      https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-$(uname -m).sh \
    && bash cmake-3.31.8-linux.sh -- --prefix=/usr --skip-license \
    && /usr/bin/rm -f cmake-3.31.8-linux.sh

RUN <<EOF cat >>/opt/devel-gcc-14-toolchain.cmake
set(DEVELOP_COMPILER_ROOT /opt/rh/gcc-toolset-14/root)

set(CMAKE_C_COMPILER /opt/rh/gcc-toolset-14/root/usr/bin/gcc)
set(CMAKE_C_COMPILER_AR /opt/rh/gcc-toolset-14/root/usr/bin/ar)
set(CMAKE_C_COMPILER_RANLIB /opt/rh/gcc-toolset-14/root/usr/bin/ranlib)

set(CMAKE_CXX_COMPILER /opt/rh/gcc-toolset-14/root/usr/bin/g++)
set(CMAKE_CXX_COMPILER_AR /opt/rh/gcc-toolset-14/root/usr/bin/ar)
set(CMAKE_CXX_COMPILER_RANLIB /opt/rh/gcc-toolset-14/root/usr/bin/ranlib)

set(CMAKE_AR /opt/rh/gcc-toolset-14/root/usr/bin/ar)
set(CMAKE_RANLIB /opt/rh/gcc-toolset-14/root/usr/bin/ranlib)
set(CMAKE_LINKER /opt/rh/gcc-toolset-14/root/usr/bin/ld)

set(CMAKE_NM /opt/rh/gcc-toolset-14/root/usr/bin/nm)
set(CMAKE_OBJCOPY /opt/rh/gcc-toolset-14/root/usr/bin/objcopy)
set(CMAKE_OBJDUMP /opt/rh/gcc-toolset-14/root/usr/bin/objdump)
set(CMAKE_ADDR2LINE /opt/rh/gcc-toolset-14/root/usr/bin/addr2line)
set(CMAKE_READELF /opt/rh/gcc-toolset-14/root/usr/bin/readelf)
set(CMAKE_STRIP /opt/rh/gcc-toolset-14/root/usr/bin/strip)

set(GCOV_PATH /opt/rh/gcc-toolset-14/root/usr/bin/gcov)
set(CPPFILT_PATH /opt/rh/gcc-toolset-14/root/usr/bin/c++filt)
EOF
