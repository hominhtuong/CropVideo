//
//  ViewController.swift
//  Example
//
//  Created by Mitu Ultra on 14/3/25.
//

import MiTuKit
import CropVideo

class ViewController: UIViewController {

    //Variables
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
    }

}

extension ViewController {
    func setupView() {
        view.backgroundColor = .random
        
        var editorConfigs = CropVideoConfigs()
        editorConfigs.strings.title = "Video Editor"
        editorConfigs.fonts.titleFont = .boldSystemFont(ofSize: 20)
        editorConfigs.transition = .push(animated: true)
        //editorConfigs.transition = .present(animated: true)
        
        var sizeConfigs = editorConfigs.sizeConfigs
        sizeConfigs.dotSize = 16
        sizeConfigs.cropViewDefaultWidth = maxWidth * 0.5
        sizeConfigs.cropViewDefaultHeight = maxWidth * 0.5
        editorConfigs.sizeConfigs = sizeConfigs
        
        var colors = editorConfigs.colors
        colors.bgHeaderColor = .random
        colors.bgBottomColor = .red
        editorConfigs.colors = colors
        
        var paddings = editorConfigs.paddings
        paddings.trimmerViewLeftPadding = 16
        paddings.trimmerViewRightPadding = 16
        editorConfigs.paddings = paddings
        
        
        //...
        
        button >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(maxWidth * 0.5)
                $0.height.equalTo(45)
            }
            $0.layer.cornerRadius = 8
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
                //self.present(editorVC, animated: true)
                
            }
        }
    }
}

extension ViewController: CropVideoDelegate {
    func didTapDone(editedUrl: URL) {
        printDebug("video editor did tap done, edited url: \(editedUrl)")
        //Handle edited video here
    }
    
    func didCropVideo(cropUrl: URL, originalUrl: URL) {
        printDebug("crop: originalUrl: \(originalUrl), croped url: \(cropUrl)")
    }
    
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {
        printDebug("trim: originalUrl: \(originalUrl), trimed url: \(trimUrl)")
    }
    
    func didRevertVideo() {
        printDebug("video editor did tap revert")
    }
    
    func didTapBack() {
        printDebug("video editor did tap back")
    }
    
    
}


/**
Example of custom CropVideoConfigs
 
public var viConfigs: CropVideoConfigs {
    var configs = CropVideoConfigs()
    configs.strings = CropVideoConfigs.Strings(
        cancel: "Hủy",
        done: "Xong",
        revert: "Khôi phục",
        title: "Chỉnh sửa",
        saved: "Đã lưu",
        cropVideoSuccess: "Cắt video thành công!",
        cropVideoFailed: "Cắt video thất bại!",
        trimVideoSuccess: "Cắt đoạn video thành công!",
        trimVideoFailed: "Cắt đoạn video thất bại!",
        failed: "Thất bại!",
        ok: "OK"
    )
    return configs
}

public let customConfigs = CropVideoConfigs(
    strings: CropVideoConfigs.Strings(
        cancel: "Hủy",
        done: "Xong",
        revert: "Khôi phục",
        title: "Chỉnh sửa",
        saved: "Đã lưu",
        cropVideoSuccess: "Cắt video thành công!",
        cropVideoFailed: "Cắt video thất bại!",
        trimVideoSuccess: "Cắt đoạn video thành công!",
        trimVideoFailed: "Cắt đoạn video thất bại!",
        failed: "Thất bại!",
        ok: "OK"
    ),
    colors: CropVideoConfigs.Colors(
        bgBottomColor: .blue,
        primaryColor: .red,
        handleColor: .white,
        mainColor: .yellow
    ),
    images: CropVideoConfigs.Images(
        backButton: UIImage(named: "custom_back_icon"),
        cropIcon: UIImage(systemName: "custom_crop_icon"),
        trimmerIcon: UIImage(systemName: "custom_trimmer_icon"),
        playIcon: UIImage(systemName: "custom_play_icon"),
        pauseIcon: UIImage(systemName: "custom_pause_icon"),
        previousIcon: UIImage(systemName: "custom_previous_icon"),
        nextIcon: UIImage(systemName: "custom_next_icon")
    )
)
 */
