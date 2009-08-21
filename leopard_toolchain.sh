svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm-svn -r 42498
pushd llvm-svn
./configure --enable-optimized
make ENABLE_OPTIMIZED=1
sudo make install
LLVMOBJDIR=`pwd`
popd

svn checkout http://iphone-dev.googlecode.com/svn/trunk/ iphone-dev
pushd iphone-dev

sudo mkdir /usr/local/arm-apple-darwin

mkdir -p build/odcctools
pushd build/odcctools
../../odcctools/configure --target=arm-apple-darwin --disable-ld64
export INCPRIVEXT="-isysroot /Developer/SDKs/MacOSX10.4u.sdk"
make
sudo make install
popd

HEAVENLY=/usr/local/share/iphone-filesystem

pushd include
./configure --with-macosx-sdk=/Developer/SDKs/MacOSX10.4u.sdk
sudo bash install-headers.sh
popd


mkdir -p build/csu
pushd build/csu
../../csu/configure --host=arm-apple-darwin
sudo make install
popd

mv llvm-gcc-4.0-iphone/configure llvm-gcc-4.0-iphone/configure.old	
sed 's/^FLAGS_FOR_TARGET=$/FLAGS_FOR_TARGET=${FLAGS_FOR_TARGET-}/g' llvm-gcc-4.0-iphone/configure.old > llvm-gcc-4.0-iphone/configure
mkdir -p build/llvm-gcc-4.0-iphone
pushd build/llvm-gcc-4.0-iphone
export FLAGS_FOR_TARGET="-mmacosx-version-min=10.1"
sudo ln -s /usr/local/arm-apple-darwin/lib/crt1.o /usr/local/arm-apple-darwin/lib/crt1.10.5.o
sudo ln -s /usr/local/arm-apple-darwin/lib/dylib1.o /usr/local/arm-apple-darwin/lib/dylib1.10.5.o
chmod 755 ../../llvm-gcc-4.0-iphone/configure
../../llvm-gcc-4.0-iphone/configure --enable-llvm=`llvm-config --obj-root` \
--enable-languages=c,c++,objc,obj-c++ --target=arm-apple-darwin --enable-sjlj-exceptions \
--with-heavenly=$HEAVENLY --with-as=/usr/local/bin/arm-apple-darwin-as \
--with-ld=/usr/local/bin/arm-apple-darwin-ld
make LLVM_VERSION_INFO=2.0-svn-iphone-dev-0.3-svn 
sudo make install
popd
popd