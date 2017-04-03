
#if [ "$(uname)" == "Darwin" ]; then
#
#fi

if [ "$(uname)" == "Linux" ]; then

    # Note: all but the configure line are specifically for the psinet
    #  setup. For generic recipe, the configure line only will suffice.

    # load Intel compilers and mkl
    set +x
    source /theoryfs2/common/software/intel2016/bin/compilervars.sh intel64
    set -x
    CXX=icpc

    # link against older libc for generic linux
    TLIBC=/theoryfs2/ds/cdsgroup/psi4-compile/nightly/glibc2.12
    LIBC_INTERJECT="${TLIBC}/lib64/libc.so.6"

    # configure
    CFLAGS='-fPIC' CPPFLAGS='-fPIC' ./configure --with-cxx-optflags='-O1' --prefix=${PREFIX} --enable-shared=yes --enable-static=no --with-cxx=${CXX}

    # forcibly add static link options, suppress libstdc++ linking, and link against older libc
    sed -i 's;\-lstdc++;;g' libtool
    sed -i 's;shared \\$libobjs ;shared -Wl,--as-needed -static-libstdc++ -static-libgcc -static-intel -wd10237 \\$libobjs /theoryfs2/ds/cdsgroup/psi4-compile/nightly/glibc2.12/lib64/libc.so.6 ;g' libtool

fi

# build
make -j${CPU_COUNT}

# install
make install

# test
make check
