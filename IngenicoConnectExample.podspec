Pod::Spec.new do |s|

  s.name          = "IngenicoConnectExample"
  s.version       = "2.0.0"
  s.summary       = "Ingenico Connect Swift SDK Example App"
  s.description   = <<-DESC
                    This is the example app for the native iOS SDK facilitates handling payments in your apps
                    using the GlobalCollect platform of Ingenico ePayments.
                    DESC

  s.homepage      = "https://github.com/Ingenico-ePayments/connect-sdk-client-swift-example"
  s.license       = { :type => "MIT", :file => "LICENSE.txt" }
  s.author        = "Ingenico"
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/Ingenico-ePayments/connect-sdk-client-swift-example.git", :tag => s.version }
  s.source_files  = "IngenicoConnectExample/*/**/*.swift"
  s.resource      = "IngenicoConnectExample/*.lproj"

  s.dependency 'SVProgressHUD'
  s.dependency 'IngenicoConnectKit'
end