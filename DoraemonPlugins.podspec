Pod::Spec.new do |s|

  s.name          = "DoraemonPlugins"
  s.version       = "1.0"
  s.summary       = "DoraemonKit插件"
  s.homepage      = "https://github.com/moliya/DoraemonPlugins"
  s.license       = "MIT"
  s.author        = {'Carefree' => '946715806@qq.com'}
  s.source        = { :git => "https://github.com/moliya/DoraemonPlugins.git", :tag => s.version}
  s.requires_arc  = true
  s.platform      = :ios, '9.0'

  s.dependency 'DoraemonKit/Core'

  s.source_files  = "Sources/*"
  
end