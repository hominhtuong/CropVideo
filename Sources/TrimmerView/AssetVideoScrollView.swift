//
//  AssetVideoScrollView.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import AVFoundation
import MiTuKit

public class AssetVideoScrollView: UIScrollView {

    let contentView = UIView()
    public var maxDuration: Double = 15
    private var generator: AVAssetImageGenerator?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews() {

        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        clipsToBounds = true

        contentView >>> self >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(1)
            }
            $0.tag = -1
            $0.backgroundColor = .clear
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentSize = contentView.bounds.size
    }

    internal func regenerateThumbnails(for asset: AVAsset) async {
        guard let thumbnailSize = await getThumbnailFrameSize(from: asset), thumbnailSize.width != 0 else {
            print("Could not calculate the thumbnail size.")
            return
        }

        generator?.cancelAllCGImageGeneration()
        removeFormerThumbnails()
        let newContentSize = await setContentSize(for: asset)
        let visibleThumbnailsCount = Int(ceil(frame.width / thumbnailSize.width))
        let thumbnailCount = Int(ceil(newContentSize.width / thumbnailSize.width))
        addThumbnailViews(thumbnailCount, size: thumbnailSize)
        let timesForThumbnail = await getThumbnailTimes(for: asset, numberOfThumbnails: thumbnailCount)
        generateImages(for: asset, at: timesForThumbnail, with: thumbnailSize, visibleThumbnails: visibleThumbnailsCount)
    }

    private func getThumbnailFrameSize(from asset: AVAsset) async -> CGSize? {
        guard let track = try? await asset.loadTracks(withMediaType: .video).first,
              let assetSize = try? await track.load(.naturalSize)
        else { return nil}

        let height: CGFloat = 50
        let ratio = assetSize.width / assetSize.height
        let width = height * ratio
        return CGSize(width: abs(width), height: abs(height))
    }

    private func removeFormerThumbnails() {
        contentView.subviews.forEach({ $0.removeFromSuperview() })
    }

    private func setContentSize(for asset: AVAsset) async -> CGSize {
        
        do {
            let duration = try await asset.load(.duration)
            let contentWidthFactor = CGFloat(max(1, duration.seconds / maxDuration))
            
            self.contentView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(contentWidthFactor)
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()

            return contentView.bounds.size
        } catch {
            print("Error loading asset duration: \(error.localizedDescription)")
            return .zero
        }
    }

    private func addThumbnailViews(_ count: Int, size: CGSize) {

        for index in 0..<count {

            let thumbnailView = UIImageView(frame: CGRect.zero)
            thumbnailView.clipsToBounds = true

            let viewEndX = CGFloat(index) * size.width + size.width

            if viewEndX > contentView.frame.width {
                thumbnailView.frame.size = CGSize(width: size.width + (contentView.frame.width - viewEndX), height: size.height)
                thumbnailView.contentMode = .scaleAspectFill
            } else {
                thumbnailView.frame.size = size
                thumbnailView.contentMode = .scaleAspectFit
            }

            thumbnailView.frame.origin = CGPoint(x: CGFloat(index) * size.width, y: 0)
            thumbnailView.tag = index
            contentView.addSubview(thumbnailView)
        }
    }

    private func getThumbnailTimes(for asset: AVAsset, numberOfThumbnails: Int) async -> [NSValue] {
        do {
            let duration: CMTime = try await asset.load(.duration)
            let timeIncrement = (duration.seconds * 1000) / Double(numberOfThumbnails)
            var timesForThumbnails = [NSValue]()
            for index in 0..<numberOfThumbnails {
                let cmTime = CMTime(value: Int64(timeIncrement * Float64(index)), timescale: 1000)
                let nsValue = NSValue(time: cmTime)
                timesForThumbnails.append(nsValue)
            }
            return timesForThumbnails
        }
        catch {
            return []
        }
    }

    private func generateImages(for asset: AVAsset, at times: [NSValue], with maximumSize: CGSize, visibleThumbnails: Int) {
        generator = AVAssetImageGenerator(asset: asset)
        generator?.appliesPreferredTrackTransform = true

        let scaledSize = CGSize(width: maximumSize.width * UIScreen.main.scale, height: maximumSize.height * UIScreen.main.scale)
        generator?.maximumSize = scaledSize
        var count = 0

        let handler: AVAssetImageGeneratorCompletionHandler = { [weak self] (_, cgimage, _, result, error) in
            if let cgimage = cgimage, error == nil && result == AVAssetImageGenerator.Result.succeeded {
                DispatchQueue.main.async(execute: { [weak self] () -> Void in

                    if count == 0 {
                        self?.displayFirstImage(cgimage, visibleThumbnails: visibleThumbnails)
                    }
                    self?.displayImage(cgimage, at: count)
                    count += 1
                })
            }
        }

        generator?.generateCGImagesAsynchronously(forTimes: times, completionHandler: handler)
    }

    private func displayFirstImage(_ cgImage: CGImage, visibleThumbnails: Int) {
        for i in 0...visibleThumbnails {
            displayImage(cgImage, at: i)
        }
    }

    private func displayImage(_ cgImage: CGImage, at index: Int) {
        if let imageView = contentView.viewWithTag(index) as? UIImageView {
            let uiimage = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.up)
            imageView.image = uiimage
        }
    }
}
