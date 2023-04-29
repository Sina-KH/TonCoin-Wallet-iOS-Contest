rm -rf build
mkdir build

cd build
mkdir openssl
cd openssl
sh ../../scripts/openssl.sh
cd ../../

sh ./scripts/build-ton.sh

cp -r ./build/openssl/iOS-fat/lib ../SubModules/TonBinding/TonBinding/openssl
cp -r ./build/ton_universal/lib ../SubModules/TonBinding/TonBinding/ton
