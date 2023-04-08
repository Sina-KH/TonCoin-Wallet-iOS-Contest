#/bin/sh

set -x
set -e

OUT_DIR="$1"
SOURCE_DIR="$2"
openssl_base_path="$3"
arch="$4"
target="$5"

if [ -z "$openssl_base_path" ]; then
  echo "Usage: sh build-ton.sh path/to/openssl"
  exit 1
fi

if [ ! -d "$openssl_base_path" ]; then
  echo "$openssl_base_path not found"
  exit 1
fi

ARCHIVE_PATH="$SOURCE_DIR/tonlib.zip"
td_path="$SOURCE_DIR/ton"
TOOLCHAIN="$SOURCE_DIR/ton-iOS.cmake"

mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/build"
cd "$OUT_DIR/build"

git_executable_path="/usr/bin/git"
openssl_path="$openssl_base_path"
echo "OpenSSL path = ${openssl_path}"
openssl_crypto_library="${openssl_path}/lib/libcrypto.a"
openssl_ssl_library="${openssl_path}/lib/libssl.a"
options="$options -DOPENSSL_FOUND=1"
options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
options="$options -DOPENSSL_INCLUDE_DIR=${openssl_path}/include"
options="$options -DOPENSSL_LIBRARIES=${openssl_crypto_library}"
options="$options -DCMAKE_BUILD_TYPE=Release"
options="$options -DGIT_EXECUTABLE=${git_executable_path}"

build="build-${arch}"
install="install-${arch}"

if [ "$arch" == "armv7" ]; then
  ios_platform="OSV7"
elif [ "$arch" == "arm64" ]; then
  ios_platform="OS64"
elif [ "$arch" == "x86_64" ]; then
  ios_platform="SIMULATOR"
else
  echo "Unsupported architecture $arch"
  exit 1
fi

rm -rf $build
mkdir -p $build
mkdir -p $install
cd $build
cmake $td_path $options -DTON_ONLY_TONLIB=ON -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" -DIOS_PLATFORM=${ios_platform} -DTON_ARCH= -DCMAKE_INSTALL_PREFIX=../${install} -DIOS_DEPLOYMENT_TARGET=${target}
CORE_COUNT=`sysctl -n hw.logicalcpu`
make -j$CORE_COUNT install || exit
cd ..

mkdir -p "out"
cp -r "$install/include" "out/"
mkdir -p "out/lib"

for f in $install/lib/*.a; do
  lib_name=$(basename "$f")
  cp "$install/lib/$lib_name" "out/lib/$lib_name"
done
