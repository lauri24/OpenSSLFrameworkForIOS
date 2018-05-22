OpenSSLFrameworkForIOS
=======
OpenSSL CocoaPod which vends pre-built frameworks for iOS and OSX.

### Notice

This is merely a wrapper which builds off of work done by others. The original comes from 
[https://github.com/krzyzanowskim/OpenSSL](https://github.com/krzyzanowskim/OpenSSL) and 
includes work done by [@jcavar](https://github.com/jcavar/OpenSSL) to build proper
frameworks. Additional work by Levi Groker (https://github.com/levigroker/GRKOpenSSLFramework).

Additional work done by me to build from the 1.1.1 OpenSSL branches and to cleanup the number
of files under git control.  Also automated the download of the openssl tree

Please see the Reference section below for more details.

### Installing

Simply add `OpenSSLFrameworkForIOS` to your podfile:

	pod 'OpenSSLFrameworkForIOS'

### Building

While the repository does contain the pre-built frameworks, if you want to re-build them:

#### iOS
1. Open in Xcode: OpenSSL/OpenSSL-iOS/OpenSSL-iOS.xcodeproj
2. Clean Build Folder (Option-Shift-Command-K)
3. Ensure "Generic iOS Device" is the selected build target.
4. Build
5. Use the `./_master_build.sh valid ios` command to validate the built framework.
6. Result is located: OpenSSL/OpenSSL-iOS/bin/openssl.framework

#### macOS
1. Open in Xcode: OpenSSL/OpenSSL-macOS/OpenSSL-macOS.xcodeproj
2. Clean Build Folder (Option-Shift-Command-K)
3. Build
4. Build again. This is needed to ensure the modulemap file is available.
5. Use the `./_master_build.sh valid macos` command to validate the built framework.
6. Result is located: OpenSSL/OpenSSL-macOS/bin/openssl.framework

### Updating OpenSSL Version

The build scripts and projects are all tailored for the 1.1.0 series of OpenSSL, so if you're attempting to use a different series you might run into some issues.

1. Download the source tarball from [https://www.openssl.org/source/](https://www.openssl.org/source/)
2. Download the PGP sig as well, and validate the tarball's signature.
3. Place the downloaded file in this directory.
4. Update the `OPENSSL_VERSION` value in the `_master_build.sh`
5. Clean, using the `./_master_build.sh clean` command.
6. Build, using the `./_master_build.sh build` command.
7. Follow the steps outlined in "Building" (above).

### Reference
[https://github.com/krzyzanowskim/OpenSSL/issues/9](https://github.com/krzyzanowskim/OpenSSL/issues/9)  
[https://github.com/krzyzanowskim/OpenSSL/pull/27](https://github.com/krzyzanowskim/OpenSSL/pull/27)  
[https://github.com/jcavar/OpenSSL](https://github.com/jcavar/OpenSSL)  
[https://github.com/levigroker/GRKOpenSSLFramework](https://github.com/levigroker/GRKOpenSSLFramework)
[https://pewpewthespells.com/blog/convert_static_to_dynamic.html](https://pewpewthespells.com/blog/convert_static_to_dynamic.html)  

### Licence
This work is licensed under the OpenSSL (OpenSSL/SSLeay) License.

### About
A professional iOS engineer by day, my name is Wyllys Ingersoll. Authoring a blog

Twitter [@wyllysinva](https://twitter.com/wyllysinva)  
Email [wyllys@gmail.com](mailto:wyllys@gmail.com)  

Your constructive comments and feedback are always welcome.
