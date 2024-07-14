mkdir build
cd build

cmake ^
    -DSLEEF_BUILD_TESTS=no ^
    -DSLEEF_BUILD_SHARED_LIBS=yes ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..

cmake --build . --target install --config Release
