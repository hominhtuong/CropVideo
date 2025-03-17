# CropVideo
[![Version](https://img.shields.io/cocoapods/v/CropVideo.svg?style=flat)](https://cocoapods.org/pods/CropVideo)
[![License](https://img.shields.io/cocoapods/l/CropVideo.svg?style=flat)](https://cocoapods.org/pods/CropVideo)
[![Platform](https://img.shields.io/cocoapods/p/CropVideo.svg?style=flat)](https://cocoapods.org/pods/CropVideo)

## About  
HI,  
CropVideo is a lightweight iOS library for cropping and trimming videos. It offers a flexible design, allowing full customization of buttons, images, and text to fit your app’s style.  
Designed for iOS, this library provides a highly customizable UI, enabling developers to modify buttons, images, and text effortlessly to match their application's look and feel. 🚀  

🔹 Key Features:  
✅ Crop Video – Resize and crop videos to the desired frame.  
✅ Trim Video – Cut and trim videos by selecting a specific time range.  

## Editing Demo 🎬

<p align="center">
    <img src="Resources/crop.gif" width="39%" style="margin-right: 16px;">
    <img src="Resources/trim.gif" width="39%" style="margin-left: 16px;">
</p>

## Installation with CocoaPods
To integrate CropVideo into your Xcode project using CocoaPods, specify it in your `Podfile`

```ruby
target 'MyApp' do
  pod 'CropVideo'
end
```

## Swift Package Manager
Once you have your Swift package set up, adding CropVideo as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/hominhtuong/CropVideo.git", .upToNextMajor(from: "1.0.1"))
]
```

## Example code:
##### The code would look like this:

```swift
import CropVideo

extension ViewController {
    func setupView() {
        view.backgroundColor = .random
        
        var editorConfigs = CropVideoConfigs()
        editorConfigs.strings.title = "Video Editor"
        editorConfigs.fonts.titleFont = .boldSystemFont(ofSize: 20)
        editorConfigs.transition = .push(animated: true)
        //...
        
        UIButton() >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(maxWidth * 0.5)
                $0.height.equalTo(45)
            }
            $0.setTitle("Open Editor", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .red
            $0.handle {
                guard let url = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4")
                else { return }
                let editorVC = CropVideoViewController(url: url)
                editorVC.delegate = self
                editorVC.configs = editorConfigs
                self.navigationController?.pushViewController(editorVC, animated: true)
            }
        }
    }
}

extension ViewController: CropVideoDelegate {
    func didTapDone(editedUrl: URL) {
        printDebug("video editor did tap done, edited url: \(editedUrl)")
        //Handle edited video here
    }
    
    func didTapBack() {
        printDebug("video editor did tap back")
    }
    
    func didRevertVideo() {
        printDebug("video editor did tap revert")
    }
    
    func didCropVideo(cropUrl: URL, originalUrl: URL) {
        printDebug("crop: originalUrl: \(originalUrl), croped url: \(cropUrl)")
    }
    
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {
        printDebug("trim: originalUrl: \(originalUrl), trimed url: \(trimUrl)")
    }
}

    
```


## License

CropVideo is released under the MIT license. See [LICENSE](https://github.com/hominhtuong/CropVideo/blob/main/LICENSE) for more details.  
<br>
My website: [Visit](https://mituultra.com/)
