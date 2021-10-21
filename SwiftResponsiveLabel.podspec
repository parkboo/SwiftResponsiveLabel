Pod:: Spec.new do |spec|
  spec.platform     = 'ios', '8.0'
  spec.name         = 'SwiftResponsiveLabel'
  spec.version      = '2.5'
  spec.summary      = 'A UILabel subclass which responds to touch on specified patterns and allows to set custom truncation token'
  spec.author = {
    'Susmita Horrow' => 'susmita.horrow@gmail.com'
  }
  spec.license          = 'MIT'
  spec.homepage         = 'https://github.com/parkboo/SwiftResponsiveLabel'
  spec.source = {
    :git => 'https://github.com/parkboo/SwiftResponsiveLabel.git',
    :tag => '2.5'
  }
  spec.ios.deployment_target = '8.0'
  spec.swift_version = '5.0'  
  spec.source_files = 'SwiftResponsiveLabel/Source/*'
  spec.requires_arc = true
end
