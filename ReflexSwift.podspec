Pod::Spec.new do |s|
  s.name             = "ReflexSwift"
  s.version          = "0.0.2"
  s.summary          = "Unidirectional data flow architecture for RxSwift"
  s.homepage         = "https://github.com/glwithu06/ReflexSwift.git"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Nate Kim" => "glwithu06@gmail.com" }
  s.source           = { :git => "https://github.com/glwithu06/ReflexSwift.git",
                         :tag => s.version.to_s }
  s.source_files = "Sources/*.{swift,h,m}"
  s.frameworks   = "Foundation"
  s.dependency "RxSwift", ">= 4.0.0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
end