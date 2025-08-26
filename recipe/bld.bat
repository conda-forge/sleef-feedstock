mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DSLEEF_BUILD_TESTS=OFF ^
    -DSLEEF_BUILD_SHARED_LIBS=ON ^
    -DSLEEF_BUILD_SCALAR_LIB=ON ^
    -DSLEEF_BUILD_QUAD=ON ^
    -DSLEEF_BUILD_GNUABI_LIBS=ON ^
    -DSLEEF_ENABLE_TLFLOAT=OFF ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    ..

if errorlevel 1 exit 1

cmake --build . --target install

if errorlevel 1 exit 1
