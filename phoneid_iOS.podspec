
Pod::Spec.new do |s|
  s.name             = "phoneid_iOS"
  s.version          = "0.1.6"
  s.summary          = "Phone.Id SDK library"
  s.description      = <<-DESC

iOS library that provides access to phone.id service.
Phone.id service allows App developers to use the phone number as a social login, without using nicknames or passwords at all.


                       DESC


  s.homepage         = "https://github.com/phoneid/phoneid_iOS"
  s.license          = 'Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)'
  s.author           = { "Federico Pomi" => "federico@pomi.net" }
  s.source           = { :git => "https://github.com/phoneid/phoneid_iOS.git", :tag => s.version.to_s }

  s.pod_target_xcconfig = { 'ENABLE_TESTABILITY' => 'YES' }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources =['Pod/Assets/Images.xcassets', 'Pod/Assets/strings/**' ]

  s.frameworks = 'UIKit', 'CoreTelephony'
  s.dependency 'libPhoneNumber-iOS', '~> 0.8'

end
