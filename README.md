OpenSSLFrameworkForIOS
=======
OpenSSL CocoaPod which vends pre-built frameworks for iOS and OSX.

### Notice

This is merely a wrapper which builds off of work done by others. The original comes from 
[https://github.com/krzyzanowskim/OpenSSL](https://github.com/krzyzanowskim/OpenSSL) and 
includes work done by [@jcavar](https://github.com/jcavar/OpenSSL) to build proper
frameworks. Additional work by Levi Groker (https://github.com/levigroker/GRKOpenSSLFramework).

Additional work done by Wyllys Ingersoll (https://github.com/wyllys66/OpenSSLFrameworkForIOS) to
build from the 1.1.1 OpenSSL branches and to cleanup the number of files under git control.
Also added ability to clone directly from a specific OpenSSL github repo branch.

Please see the Reference section below for more details.

### Installing

1. Clone the repo.
2. Follow the build instructions below.
3. add `OpenSSLFrameworkForIOS` to your podfile:
```
pod 'OpenSSLFrameworkForIOS, :path => "/PATH/TO/YOUR/CLONE/OpenSSLFrameworkForIOS"
```
4. Rebuild your project.

### Building
The repo does NOT contain pre-built binaries, you should re-build them. 
Set the OPENSSL_VERSION string in the 'master_build.sh' script.

#### Clone the desired repo/branch
1. Clone, using the  `./master_build.sh clone OpenSSL_1_1_1-pre6`
- If branch arg is omitted, it builds from "master"

#### Build the libraries for all of the required architectures

1. Clean, using the `./master_build.sh clean` command.
2. Build, using the `./master_build.sh build` command.

Next, build the frameworks so that your project can just include
the pod and get access to the headers and LIPO archives created above.

#### Build iOS framework
1. Open in Xcode: OpenSSL/OpenSSL-iOS/OpenSSL-iOS.xcodeproj
2. Clean Build Folder (Option-Shift-Command-K)
3. Ensure "Generic iOS Device" is the selected build target.
4. Build
5. Use the `./master_build.sh valid ios` command to validate the built framework.
6. Result is located: OpenSSL/OpenSSL-iOS/bin/openssl.framework

#### Build macOS framework 
1. Open in Xcode: OpenSSL/OpenSSL-macOS/OpenSSL-macOS.xcodeproj
2. Clean Build Folder (Option-Shift-Command-K)
3. Build
4. Build again. This is needed to ensure the modulemap file is available.
5. Use the `./master_build.sh valid macos` command to validate the built framework.
6. Result is located: OpenSSL/OpenSSL-macOS/bin/openssl.framework

### Reference
[https://github.com/krzyzanowskim/OpenSSL/issues/9](https://github.com/krzyzanowskim/OpenSSL/issues/9)  
[https://github.com/krzyzanowskim/OpenSSL/pull/27](https://github.com/krzyzanowskim/OpenSSL/pull/27)  
[https://github.com/jcavar/OpenSSL](https://github.com/jcavar/OpenSSL)  
[https://github.com/levigroker/GRKOpenSSLFramework](https://github.com/levigroker/GRKOpenSSLFramework)
[https://pewpewthespells.com/blog/convert_static_to_dynamic.html](https://pewpewthespells.com/blog/convert_static_to_dynamic.html)  

### Licence
This work is licensed under the OpenSSL (OpenSSL/SSLeay) License.

### About
Twitter [@wyllysinva](https://twitter.com/wyllysinva)  
Email [wyllys@gmail.com](mailto:wyllys@gmail.com)  

Your constructive comments and feedback are always welcome.
