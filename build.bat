mkdir build
cd build
mkdir x86_64-windows
mkdir x86_64-linux
mkdir aarch64-linux
mkdir x86_64-macos

cd x86_64-windows
zig build-lib ../../src/xxhash-ffi.zig -dynamic -OReleaseFast -target x86_64-windows

cd ../x86_64-linux
zig build-lib ../../src/xxhash-ffi.zig -dynamic -OReleaseFast -target x86_64-linux

cd ../aarch64-linux
zig build-lib ../../src/xxhash-ffi.zig -dynamic -OReleaseFast -target aarch64-linux

cd ../x86_64-macos
zig build-lib ../../src/xxhash-ffi.zig -dynamic -OReleaseFast -target x86_64-macos

cd ../..