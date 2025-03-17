//
//  Extensions.swift
//  CropVideo
//
//  Created by Admin on 16/3/25.
//

import AVFoundation
import MiTuKit

public extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
