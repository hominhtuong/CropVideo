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
                guard let url = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4") else {return}
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
    
    func didCropVideo(cropUrl: URL, originalUrl: URL) {
        printDebug("crop originalUrl: \(originalUrl), croped url: \(cropUrl)")
    }
    
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {
        printDebug("trim originalUrl: \(originalUrl), trimed url: \(trimUrl)")
    }
}

