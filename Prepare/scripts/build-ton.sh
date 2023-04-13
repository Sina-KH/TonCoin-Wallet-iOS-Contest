set -ex

export OPENSSL_ROOT_DIR=/usr/local/opt/openssl@3/
SOURCE_PATH="ton"



cd $SOURCE_PATH
rm -rf build
mkdir build
cd build
cmake ..
cmake --build . --target prepare_cross_compiling
cd ..
rm -rf build
cd ..



core_count="`sysctl -n hw.logicalcpu`"
BUILD_DIR="$(pwd)/build/ton"
BUILD_DIR_X86_64="$(pwd)/build/ton_x86_64"
BUILD_DIR_ARM64="$(pwd)/build/ton_arm64"
OPENSSL="$(pwd)/build/openssl/iOS-fat"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cp "scripts/build-ton-arch.sh" "$BUILD_DIR/"
cp "scripts/ton-iOS.cmake" "$BUILD_DIR/"

cp -R "$SOURCE_PATH" "$BUILD_DIR/"

sh $BUILD_DIR/build-ton-arch.sh "$BUILD_DIR_ARM64" "$BUILD_DIR" "$OPENSSL" arm64 12.0
sh $BUILD_DIR/build-ton-arch.sh "$BUILD_DIR_X86_64" "$BUILD_DIR" "$OPENSSL" x86_64 12.0

mkdir -p $(pwd)/build/ton_universal/lib
for entry in $(pwd)/build/ton_x86_64/build/out/lib/*.a;do; \
	entryFileName=`basename "$entry"`; \
	lipo $entry $(pwd)/build/ton_arm64/build/out/lib/$entryFileName -create -output $(pwd)/build/ton_universal/lib/$entryFileName ;\
done