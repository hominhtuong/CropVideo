//
//  ViewController.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import UIKit
import MiTuKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        
        UIButton() >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(100)
            }
            $0.backgroundColor = .random
            $0.handle {
                guard let url = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4") else {return}
                let editorVC = CropVideoViewController(url: url)
                editorVC.delegate = self
                
                editorVC.configs.strings.title = "Video Editor"
                self.navigationController?.pushViewController(editorVC, animated: true)
            }
        }
    }
}

extension ViewController: CropVideoDelegate {
    func didCropVideo(cropUrl: URL, originalUrl: URL) {
        printDebug("crop originalUrl: \(originalUrl)")
        printDebug("croped url: \(cropUrl)")
    }
    
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {
        printDebug("trim originalUrl: \(originalUrl)")
        printDebug("trimed url: \(trimUrl)")
    }
}
