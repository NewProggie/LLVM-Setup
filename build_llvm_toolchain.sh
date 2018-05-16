#!/usr/bin/env bash

# User-configurable variables
REPO=http://llvm.org/svn/llvm-project
IWYU_REPO=https://github.com/include-what-you-use/include-what-you-use.git
VER_NUM=6.0.0

# Check prerequisites
for cmd in "svn" "git" "cmake" "ninja"; do
  hash ${cmd} 2> /dev/null || { echo >&2 "${cmd} is not installed."; exit 1; }
done
exit

if [[ -z "$1" ]]; then
  echo "No INSTALL_PREFIX argument provided"
  exit 1
else
  echo "Installing into ${INSTALL_PREFIX}"
fi

VERSION=tags/RELEASE_${VER_NUM//./}/final
INSTALL_PREFIX="$1"

# Main LLVM repo
svn co ${REPO}/llvm/${VERSION} llvm

pushd llvm
svn co ${REPO}/cfe/${VERSION}                tools/clang             # Clang
svn co ${REPO}/clang-tools-extra/${VERSION}  tools/clang/tools/extra # Extra Clang Tools

git clone ${IWYU_REPO}                       tools/clang/tools/include-what-you-use # IWYU
echo "add_subdirectory(include-what-you-use)" >> tools/clang/tools/CMakeLists.txt

svn co ${REPO}/lld/${VERSION}                tools/lld               # LLD Linker
svn co ${REPO}/polly/${VERSION}              tools/polly             # Polly Loop Optimizer
svn co ${REPO}/compiler-rt/${VERSION}        projects/compiler-rt    # Compiler-Rt (Sanitizers)
svn co ${REPO}/openmp/${VERSION}             projects/openmp         # OpenMP
svn co ${REPO}/libcxx/${VERSION}             projects/libcxx         # LibCXX
svn co ${REPO}/libcxxabi/${VERSION}          projects/libcxxabi      # LibCXX ABI

# Patch IWYU on macOS for not detecting system headers correctly
if [[ $OSTYPE == darwin* ]]; then
  sed -i '' "s#/Library/Developer/CommandLineTools/usr/#${INSTALL_PREFIX}/#" \
    tools/clang/tools/include-what-you-use/iwyu_driver.cc
  sed -i '' '/Applications\/Xcode.app\/Contents\/Developer\/Toolchains\//d'  \
    tools/clang/tools/include-what-you-use/iwyu_driver.cc
  sed -i '' "s#XcodeDefault.xctoolchain/usr/include/c++/v1#${INSTALL_PREFIX}/lib/clang/${VER_NUM}/include/#" \
    tools/clang/tools/include-what-you-use/iwyu_driver.cc
fi

popd

mkdir -p llvm/build && pushd llvm/build
cmake -Wno-dev -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DLLVM_ENABLE_DOXYGEN=NO \
  -DLLVM_ENABLE_OCAMLDOC=NO \
  -DLLVM_ENABLE_SPHINX=NO ..
cmake --build . --target install
