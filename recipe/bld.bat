mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DSLEEF_BUILD_TESTS=OFF ^
    -DSLEEF_BUILD_SHARED_LIBS=ON ^
    -DSLEEF_BUILD_SCALAR_LIB=ON ^
    -DSLEEF_BUILD_QUAD=ON ^
    -DSLEEF_BUILD_GNUABI_LIBS=ON ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    ..

if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1