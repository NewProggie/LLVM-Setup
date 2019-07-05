# LLVM-Setup
This repo contains a build script which downloads a specific LLVM release version and adds additional tools such as include-what-you-use so that it does not complain about wrong/missing headers

On new releases of macos one may has to execute

```
Remove existing CLT (Command Line Tool) using: rm -rf /Library/Developer/CommandLineTools
Install CLT: xcode-select –install
Goto: /Library/Developer/CommandLineTools/Packages and double click to install macOS_SDK_headers_for_macOS_10.14.sdk
```

in order to get rid of missing system headers when trying to compile something with clang
