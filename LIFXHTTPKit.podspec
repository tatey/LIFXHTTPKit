#
#  Be sure to run `pod spec lint LIFXHTTPKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LIFXHTTPKit"
  s.version      = "3.0.0"
  s.summary      = "A framework for interacting with the LIFX HTTP API that has no external dependencies. Suitable for use inside extensions."

  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.homepage	 = "https://github.com/tatey/LIFXHTTPKit"
  s.author       = { "Alex Stonehouse" => "alexander@lifx.co" }
  s.source       = { :git => "https://github.com/LIFX/LIFXHTTPKit.git", :tag => "#{s.version}" }

  # Version
  s.platform = :ios
  s.swift_version = "4.0"
  s.ios.deployment_target = "8.2"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source_files  = "Source/**/*"

end
