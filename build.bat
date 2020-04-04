if not exist "build/meta/x64-windows" (mkdir build\meta\x64-windows)
cd build\meta\x64-windows
cmake -G "Visual Studio 15 2017 Win64" ..\..\..\
cmake --build . --config Release
ctest -C Release --verbose
