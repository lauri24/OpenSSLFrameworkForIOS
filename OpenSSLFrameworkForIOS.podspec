Pod::Spec.new do |s|
  s.name         = "OpenSSLFrameworkForIOS"
  s.module_name  = "openssl"
  s.version      = "1.1.0.#{("a".."z").to_a.index 'h'}"
  s.summary      = "OpenSSL for iOS and OS X"
  s.description  = "OpenSSL Framework binaries."
  s.homepage     = "https://github.com/wyllys66/OpenSSLFrameworkForIOS/"
  s.license	     = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE.txt' }
  s.source       = { :git => "https://github.com/wyllys66/OpenSSLFrameworkForIOS.git", :tag => "#{s.version}" }
  s.authors       =  {'Wyllys Ingersoll' => 'wyllys@gmail.com'}
  
  s.ios.pod_target_xcconfig = {'ENABLE_BITCODE' => 'YES' }
  s.osx.pod_target_xcconfig = {'ENABLE_BITCODE' => 'NO' }

  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'OpenSSL-iOS/bin/openssl.framework'

  s.osx.deployment_target = '10.13'
  s.osx.vendored_frameworks = 'OpenSSL-macOS/bin/openssl.framework'
end
