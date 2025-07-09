Pod::Spec.new do |spec|
    spec.name         = "CropVideo"
    spec.version      = "1.0.6"
    spec.summary      = "🚀 CropVideo is a lightweight iOS library for cropping and trimming videos"
    spec.swift_versions = ['5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9']
    spec.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Onone' }

    spec.static_framework = true

    spec.description  = <<-DESC
    CropVideo simplifies video editing with two core features:
    ✅ Crop Video – Resize and crop videos to the desired frame.
    ✅ Trim Video – Cut and trim videos by selecting a specific time range.

    Designed for iOS, this library provides a highly customizable UI, enabling developers to modify buttons, images, and text effortlessly to match their application's look and feel. 🚀
    DESC

    spec.homepage     = "https://cocoapods.org/pods/CropVideo"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author       = { "Mitu Ultra" => "support@mituultra.com" }
    spec.platform     = :ios, "15.0"
    spec.ios.deployment_target = '15.0'

    spec.source       = { :git => "https://github.com/hominhtuong/CropVideo.git", :tag => "#{spec.version}" }
    spec.source_files = 'Sources/**/*.swift'

    spec.dependency 'MiTuKit'
    spec.dependency 'MTMedia'
    

end
