
Pod::Spec.new do |spec|

  spec.name         = "ModuleA"
  spec.version      = "0.0.1"
  spec.summary      = "模块A"

  spec.description  = <<-DESC
  							模块AA
                   DESC

  spec.homepage     = "http://www.baidu.com"

  spec.license      = "MIT"

  spec.author             = { "jiangzedong" => "jiangzedong@langlib.com" }
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "http://www.baidu.com", :tag => "#{spec.version}" }
  spec.default_subspec =  'Classes'

  spec.subspec "Classes" do |ss|
    ss.source_files  = "Classes", "Classes/**/*.{h,m}"
    ss.public_header_files = "Classes/**/*.h"
    ss.dependency 'YTKNetwork'
    ss.dependency 'BeeHive'
    ss.pod_target_xcconfig = {'OBJC_OLD_DISPATCH_PROTOTYPES' => false}
  end
  

end
