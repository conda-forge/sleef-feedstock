#!/usr/bin/env bash

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p native-build
    pushd native-build

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS

    cmake \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DSLEEF_BUILD_TESTS=OFF \
      -DSLEEF_BUILD_SHARED_LIBS=ON \
      -DSLEEF_BUILD_SCALAR_LIB=ON \
      -DSLEEF_BUILD_QUAD=ON \
      -DSLEEF_BUILD_GNUABI_LIBS=ON \
      -DSLEEF_ENABLE_TLFLOAT=OFF \
      -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..
    ninja -j${CPU_COUNT}
  )
  CMAKE_ARGS="${CMAKE_ARGS} -DNATIVE_BUILD_DIR=$PWD/native-build"
fi

mkdir build
cd build

if [[ "$target_platform" == linux-* ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DSLEEF_BUILD_TESTS=OFF \
    -DSLEEF_BUILD_SHARED_LIBS=ON \
    -DSLEEF_BUILD_SCALAR_LIB=ON \
    -DSLEEF_BUILD_QUAD=ON \
    -DSLEEF_BUILD_GNUABI_LIBS=ON \
    -DSLEEF_ENABLE_TLFLOAT=OFF \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

ninja -j${CPU_COUNT} install
