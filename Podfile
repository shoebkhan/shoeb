# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'TuDime' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  #Chat_Call
  
  
  pod 'QuickBlox', '~> 2.17.10'
  pod 'Quickblox-WebRTC', '~> 2.7.6'
  pod 'SwiftyGif'
  #Toast-Swift
  pod 'iRecordView'
  pod 'SwiftQRScanner', :git => ‘https://github.com/vinodiOS/SwiftQRScanner’
  
  
  #Pod_for_loading
  pod 'SVProgressHUD'
  
  #Api_Call
  pod 'Just'
  
  #DropDown
  pod 'iOSDropDown'
  
  #Pager-enabled
  pod 'XLPagerTabStrip'
  
  #CalendarView
  pod 'KDCalendar', '~> 1.8.9'
  
  #object mapper https://github.com/Hearst-DD/ObjectMapper
  pod 'ObjectMapper'
  pod 'SemiModalViewController'
  pod "SwiftSignatureView"
  
  pod 'ChromaColorPicker'
  
  pod 'Firebase/Analytics'
  
  pod 'Floaty'
  pod 'Firebase/Database'
  
  pod 'NewPopMenu'
  
  pod 'JFContactsPicker', '~> 2.0'
  
  pod 'GoogleMLKit/Translate', '3.2.0'
  
  pod "KWVerificationCodeView"
  
  # Pods for Doodle - V10.0
  pod 'iOSPhotoEditor'
  pod 'Alamofire'
  pod 'AlamofireNetworkActivityIndicator'
  pod 'TTTAttributedLabel'
  pod "SwiftyXMLParser"
  pod 'HPRecorder'
  
  pod 'SDWebImage'
  
  pod 'SDWebImageWebPCoder'
  pod "Popover"
  pod "YRPayment"
  pod 'Toaster'
  pod "Colorful", "~> 3.0"
  pod 'Sketch'
  pod 'SinchRTC'
  pod 'QCropper'
  pod 'ImageViewer.swift', '~> 3.0'
  pod 'ImageViewer.swift/Fetcher', '~> 3.0'
  pod 'SwiftyBase64'
  pod 'AssetsPickerViewController'
  pod 'HSAttachmentPicker'
  pod 'Toast-Swift'
  pod 'KNContactsPicker'
  pod 'TrailerPlayer', '~> 1.4.8'
  pod 'GoogleMaps'
 pod 'GooglePlaces'
 pod 'Refreshable'
  post_install do |installer_representation|
    bitcode_strip_path = `xcrun --find bitcode_strip`.chop!

    def strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
    framework_path = File.join(Dir.pwd, framework_relative_path)
    command = "#{bitcode_strip_path} #{framework_path} -r -o #{framework_path}"
    puts "Stripping bitcode: #{command}"
    system(command)
  end

  framework_paths = [
  "Pods/QuickBlox/Framework/Quickblox.xcframework/ios-arm64/Quickblox.framework/Quickblox",
  "Pods/Quickblox-WebRTC/Framework/QuickbloxWebRTC.xcframework/ios-arm64/QuickbloxWebRTC.framework/QuickbloxWebRTC",
  ]
  framework_paths.each do |framework_relative_path|
    strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
  end
    installer_representation.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        
      end
    end
  end

end

target 'TuDimeShareExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Kingfisher', '~> 7.9.1'
  pod 'SwiftLinkPreview', '~> 3.4.0'
end
