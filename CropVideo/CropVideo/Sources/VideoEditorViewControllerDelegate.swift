//
//  VideoEditorViewControllerDelegate.swift
//  CropVideo
//
//  Created by Admin on 16/3/25.
//

import MiTuKit

public protocol VideoEditorViewControllerDelegate {
    func didCropVideo(cropUrl: URL, originalUrl: URL)
    func didTrimVideo(trimUrl: URL, originalUrl: URL)
}

public extension VideoEditorViewControllerDelegate {
    func didCropVideo(cropUrl: URL, originalUrl: URL) {}
    func didTrimVideo(trimUrl: URL, originalUrl: URL) {}
}
