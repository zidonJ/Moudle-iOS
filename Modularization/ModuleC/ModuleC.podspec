#
#  Be sure to run `pod spec lint ModuleC.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "ModuleC"
  spec.version      = "0.0.1"
  spec.summary      = "模块C"

  spec.description  = <<-DESC
                模块CC
                   DESC

  spec.homepage     = "http://www.baidu.com"

  spec.license      = "MIT"

  spec.author             = { "jiangzedong" => "jiangzedong@langlib.com" }
  spec.platform     = :ios
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "http://www.baidu.com", :tag => "#{spec.version}" }

  spec.default_subspec =  'Classes'

  spec.subspec "Classes" do |ss|
    ss.source_files  = "Classes", "Classes/**/*.{h,m}"
    ss.public_header_files = "Classes/**/*.h"
    ss.dependency 'YTKNetwork'
    ss.dependency 'BeeHive'
  end

end
