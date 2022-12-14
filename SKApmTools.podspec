#
# Be sure to run `pod lib lint SKApmTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SKApmTools'
  s.version          = '0.1.1'
  s.summary          = 'APM性能优化相关（swift版本 ）：ANR卡顿监测、网络优化、内存监控、启动优化、常见crash防护、crash监控上报'
  s.description      = <<-DESC
  APM性能优化相关（swift版本 ）：ANR卡顿监测、网络优化、内存监控、启动优化、常见crash防护、crash监控上报
                       DESC

  s.homepage         = 'https://github.com/Xcoder1011/SKApmTools'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xcoder1011' => 'shangkunwu@msn.com' }
  s.source           = { :git => 'https://github.com/Xcoder1011/SKApmTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES"
  }
  
  s.subspec 'BackTrace' do |ss|
     ss.source_files = 'SKApmTools/Classes/BackTrace/*'
  end
  
  s.subspec 'ANR' do |ss|
     ss.source_files = 'SKApmTools/Classes/ANR/*'
     ss.dependency 'SKApmTools/BackTrace'
  end
  
  s.subspec 'ImageTool' do |ss|
     ss.source_files = 'SKApmTools/Classes/ImageTool/*'
     ss.dependency 'Kingfisher'
  end
end
