#
#  Be sure to run `pod spec lint TCPAssistant.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "TCPAssistant"
  spec.version      = "1.06"
  spec.summary      = "TCP Assistant"

  spec.homepage     = "https://github.com/NapoleonYoung/TCPAssistant"
  spec.license      = { :type => "MIT" }

  spec.author             = { "NapoleonYoung" => "qq906469826@163.com" }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/NapoleonYoung/TCPAssistant.git", :tag => "#{spec.version}" }

  spec.source_files  = "TCPAssistant/TCPAssistant/Model/*.{h,m}"
  spec.public_header_files = "TCPAssistant/TCPAssistant/Model/NetWork.h"

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
