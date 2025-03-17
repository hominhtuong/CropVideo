//
//  CropVideoDelegate.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import MiTuKit

public protocol CropVideoDelegate {
    func didCropVideo(cropUrl: URL, originalUrl: URL)
    func didTrimVideo(trimUrl: URL, originalUrl: URL)
}

public extension CropVideoDelegate {
    func didCropVideo(cropUrl: URL, originalUrl: URL) {}
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {}
}
