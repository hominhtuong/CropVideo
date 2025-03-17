//
//  Untitled.swift
//  CropVideo
//
//  Created by Admin on 16/3/25.
//

public enum PanDirectionType {
    case left
    case right
    case top
    case bottom
}

public extension PanDirectionType {
    var isHorizontal: Bool {
        switch self {
        case .left, .right:
            return true
        case .top, .bottom:
            return false
        }
    }

    var isVertical: Bool {
        return !isHorizontal
    }
}
