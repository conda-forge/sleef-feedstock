#!/usr/bin/env bash

set -ex

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p native-build
    pushd native-build

    export CC=$CC_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS

    cmake \
      -GNinja \
      -DSLEEF_BUILD_TESTS=OFF \
      -DSLEEF_BUILD_SHARED_LIBS=ON \
      -DSLEEF_BUILD_SCALAR_LIB=ON \
      -DSLEEF_BUILD_DFT=ON \
      -DSLEEF_BUILD_QUAD=ON \
      -DSLEEF_BUILD_GNUABI_LIBS=ON \
      -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..
    ninja -j${CPU_COUNT}
    popd
  )
  CMAKE_ARGS="${CMAKE_ARGS} -DNATIVE_BUILD_DIR=$PWD/native-build"
fi

mkdir build
cd build

if [[ "$target_platform" == "osx-arm64" ]]; then
    # Set up cross-compilation for arm64
    export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_OSX_ARCHITECTURES=arm64"
    export CONDA_BUILD_SYSROOT="${CONDA_BUILD_SYSROOT:-/opt/MacOSX11.0.sdk}"
    export CC=/usr/bin/clang
    export CXX=$CLANGXX
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT -I$PREFIX/include"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
elif [[ "$target_platform" == "osx-64" ]]; then
    # Set up for x86_64 macOS build
    export CC=/usr/bin/clang
    export CXX=$CLANGXX
    export CFLAGS="$CFLAGS -I$PREFIX/include"
    export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
elif [[ "$target_platform" == linux-* ]]; then
    export LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DSLEEF_BUILD_TESTS=OFF \
    -DSLEEF_BUILD_SHARED_LIBS=ON \
    -DSLEEF_BUILD_SCALAR_LIB=ON \
    -DSLEEF_BUILD_DFT=ON \
    -DSLEEF_BUILD_QUAD=ON \
    -DSLEEF_BUILD_GNUABI_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

cmake --build . --target install