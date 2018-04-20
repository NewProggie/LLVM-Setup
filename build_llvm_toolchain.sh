#!/bin/bash

REPO=http://llvm.org/svn/llvm-project
IWYU_REPO=https://github.com/include-what-you-use
VERSION=tags/RELEASE_600/final
VER_NUM=6.0.0

INSTALL_PREFIX=/usr/local/Cellar/llvm/${VER_NUM}

# Main LLVM repo
svn co ${REPO}/llvm/${VERSION} llvm

pushd llvm
svn co ${REPO}/cfe/${VERSION}                   tools/clang             # Clang
svn co ${REPO}/clang-tools-extra/${VERSION}     tools/clang/tools/extra # Extra Clang Tools

git clone ${IWYU_REPO}/include-what-you-use.git tools/clang/tools       # IWYU
echo "add_subdirectory(include-what-you-use)" >> tools/clang/tools/CMakeLists.txt
sed -i '' "s#/Library/Developer/CommandLineTools/usr/#${INSTALL_PREFIX}/#" iwyu_driver.cc
sed -i '' '/Applications\/Xcode.app\/Contents\/Developer\/Toolchains\//d' iwyu_driver.cc
sed -i '' "s#XcodeDefault.xctoolchain/usr/include/c++/v1#${INSTALL_PREFIX}/lib/clang/${VER_NUM}/include/#" iwyu_driver.cc

svn co ${REPO}/lld/${VERSION}                   tools/lld               # LLD Linker
svn co ${REPO}/polly/${VERSION}                 tools/polly             # Polly Loop Optimizer
svn co ${REPO}/compiler-rt/${VERSION}           projects/compiler-rt    # Compiler-Rt (Sanitizers)
svn co ${REPO}/openmp/${VERSION}                projects/openmp         # OpenMP
svn co ${REPO}/libcxx/${VERSION}                projects/libcxx         # LibCXX
svn co ${REPO}/libcxxabi/${VERSION}             projects/libcxxabi      # LibCXX ABI
popd

mkdir -p llvm/build && pushd llvm/build
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DLLVM_ENABLE_PROJECTS=all \
  -DLLVM_ENABLE_DOXYGEN=NO \
  -DLLVM_ENABLE_SPHINX=NO ..
#cmake --build . --target install
