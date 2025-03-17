//
//  AVAssetTimeSelector.swift
//  CropVideo
//
//  Created by Admin on 16/3/25.
//

import MiTuKit
import AVFoundation

/// A generic class to display an asset into a scroll view with thumbnail images, and make the equivalence between a time in
// the asset and a position in the scroll view
public class AVAssetTimeSelector: UIView, UIScrollViewDelegate {

    let assetPreview = AssetVideoScrollView()

    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    public var maxDuration: Double = 15 {
        didSet {
            assetPreview.maxDuration = maxDuration
        }
    }

    /// The asset to be displayed in the underlying scroll view. Setting a new asset will automatically refresh the thumbnails.
    public var asset: AVAsset? {
        didSet {
            assetDidChange(newAsset: asset)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews() {
        setupAssetPreview()
        constrainAssetPreview()
    }

    public func regenerateThumbnails() {
        if let asset = asset {
            Task {
                await assetPreview.regenerateThumbnails(for: asset)
            }
        }
    }

    // MARK: - Asset Preview

    func setupAssetPreview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        assetPreview.translatesAutoresizingMaskIntoConstraints = false
        assetPreview.delegate = self
        addSubview(assetPreview)
    }

    func constrainAssetPreview() {
        assetPreview.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        assetPreview.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func assetDidChange(newAsset: AVAsset?) {
        if let asset = newAsset {
            Task {
                await assetPreview.regenerateThumbnails(for: asset)
            }
        }
    }

    // MARK: - Time & Position Equivalence

    var durationSize: CGFloat {
        return assetPreview.contentSize.width
    }

    func getTime(from position: CGFloat) async -> CMTime? {
        guard let asset = asset else {
            return nil
        }
        let duration = (try? await asset.load(.duration)) ?? .zero
        let normalizedRatio = max(min(1, position / durationSize), 0)
        let positionTimeValue = Double(normalizedRatio) * Double(duration.value)
        return CMTime(value: Int64(positionTimeValue), timescale: duration.timescale)
    }

    func getPosition(from time: CMTime) async -> CGFloat? {
        guard let asset = asset else {
            return nil
        }
        let duration = (try? await asset.load(.duration)) ?? .zero
        let timeRatio = CGFloat(time.value) * CGFloat(duration.timescale) /
            (CGFloat(time.timescale) * CGFloat(duration.value))
        return timeRatio * durationSize
    }
}
