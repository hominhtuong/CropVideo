//
//  TrimmerView.swift
//  CropVideo
//
//  Created by Admin on 16/3/25.
//

import AVFoundation
import MiTuKit

public protocol TrimmerViewDelegate: AnyObject {
    func didChangePositionBar(_ playerTime: CMTime)
    func positionBarStoppedMoving(_ playerTime: CMTime)
}

/// A view to select a specific time range of a video. It consists of an asset preview with thumbnails inside a scroll view, two
/// handles on the side to select the beginning and the end of the range, and a position bar to synchronize the control with a
/// video preview, typically with an `AVPlayer`.
/// Load the video by setting the `asset` property. Access the `startTime` and `endTime` of the view to get the selected time
// range
@IBDesignable public class TrimmerView: AVAssetTimeSelector {

    // MARK: - Properties

    // MARK: Color Customization

    /// The color of the main border of the view
    @IBInspectable public var mainColor: UIColor = UIColor.orange {
        didSet {
            updateMainColor()
        }
    }

    /// The color of the handles on the side of the view
    @IBInspectable public var handleColor: UIColor = UIColor.gray {
        didSet {
           updateHandleColor()
        }
    }

    /// The color of the position indicator
    @IBInspectable public var positionBarColor: UIColor = UIColor.white {
        didSet {
            positionBar.backgroundColor = positionBarColor
        }
    }

    /// The color used to mask unselected parts of the video
    @IBInspectable public var maskColor: UIColor = UIColor.white {
        didSet {
            leftMaskView.backgroundColor = maskColor
            rightMaskView.backgroundColor = maskColor
        }
    }

    // MARK: Interface

    public weak var delegate: TrimmerViewDelegate?

    // MARK: Subviews

    private let trimView = UIView()
    private let leftHandleView = HandlerView()
    private let rightHandleView = HandlerView()
    private let positionBar = UIView()
    private let leftHandleKnob = UIImageView()
    private let rightHandleKnob = UIImageView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()

    // MARK: Constraints

    private var currentLeftConstraint: CGFloat = 0
    private var currentRightConstraint: CGFloat = 0
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var positionConstraint: NSLayoutConstraint?

    private let handleWidth: CGFloat = 15

    /// The minimum duration allowed for the trimming. The handles won't pan further if the minimum duration is attained.
    public var minDuration: Double = 3

    // MARK: - View & constraints configurations

    override func setupSubviews() {
        super.setupSubviews()
        layer.cornerRadius = 2
        layer.masksToBounds = true
        backgroundColor = UIColor.clear
        layer.zPosition = 1
        setupTrimmerView()
        setupHandleView()
        setupMaskView()
        setupPositionBar()
        setupGestures()
        updateMainColor()
        updateHandleColor()
    }

    override func constrainAssetPreview() {
        assetPreview.leftAnchor.constraint(equalTo: leftAnchor, constant: handleWidth).isActive = true
        assetPreview.rightAnchor.constraint(equalTo: rightAnchor, constant: -handleWidth).isActive = true
        assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupTrimmerView() {
        trimView.layer.borderWidth = 2.0
        trimView.layer.cornerRadius = 2.0
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.isUserInteractionEnabled = false
        addSubview(trimView)

        trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor)
        rightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor)
        leftConstraint?.isActive = true
        rightConstraint?.isActive = true
    }

    private func setupHandleView() {
        leftHandleView >>> self >>> {
            $0.snp.makeConstraints {
                $0.height.equalToSuperview()
                $0.width.equalTo(handleWidth)
                $0.leading.equalTo(trimView)
                $0.centerY.equalToSuperview()
            }
            $0.layer.cornerRadius = 2
            $0.isUserInteractionEnabled = true
        }
        
        leftHandleKnob >>> leftHandleView >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.bottom.equalToSuperview().offset(-8)
                $0.leading.trailing.equalToSuperview()
            }
            $0.image = UIImage(systemName: "chevron.compact.left")?.withTintColor(handleColor, renderingMode: .alwaysOriginal)
        }
        
        rightHandleView >>> self >>> {
            $0.snp.makeConstraints {
                $0.height.equalToSuperview()
                $0.width.equalTo(handleWidth)
                $0.trailing.equalTo(trimView)
                $0.centerY.equalToSuperview()
            }
            $0.layer.cornerRadius = 2
            $0.isUserInteractionEnabled = true
        }
        
        rightHandleKnob >>> rightHandleView >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.bottom.equalToSuperview().offset(-8)
                $0.leading.trailing.equalToSuperview()
            }
            $0.image = UIImage(systemName: "chevron.compact.right")?.withTintColor(handleColor, renderingMode: .alwaysOriginal)
        }
    }

    private func setupMaskView() {

        leftMaskView.isUserInteractionEnabled = false
        leftMaskView.backgroundColor = .white
        leftMaskView.alpha = 0.7
        leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftMaskView, belowSubview: leftHandleView)

        leftMaskView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true

        rightMaskView.isUserInteractionEnabled = false
        rightMaskView.backgroundColor = .white
        rightMaskView.alpha = 0.7
        rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightMaskView, belowSubview: rightHandleView)

        rightMaskView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
    }

    private func setupPositionBar() {

        positionBar.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)
        positionBar.backgroundColor = positionBarColor
        positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
        positionBar.layer.cornerRadius = 1
        positionBar.translatesAutoresizingMaskIntoConstraints = false
        positionBar.isUserInteractionEnabled = false
        addSubview(positionBar)

        positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        positionBar.widthAnchor.constraint(equalToConstant: 3).isActive = true
        positionBar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        positionConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
        positionConstraint?.isActive = true
    }

    private func setupGestures() {

        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
    }

    private func updateMainColor() {
        trimView.layer.borderColor = mainColor.cgColor
        leftHandleView.backgroundColor = mainColor
        rightHandleView.backgroundColor = mainColor
    }

    private func updateHandleColor() {
        leftHandleKnob.image = leftHandleKnob.image?.withTintColor(handleColor, renderingMode: .alwaysOriginal)
        rightHandleKnob.image = rightHandleKnob.image?.withTintColor(handleColor, renderingMode: .alwaysOriginal)
    }

    // MARK: - Trim Gestures

    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
        let isLeftGesture = view == leftHandleView
        switch gestureRecognizer.state {

        case .began:
            if isLeftGesture {
                currentLeftConstraint = leftConstraint!.constant
            } else {
                currentRightConstraint = rightConstraint!.constant
            }
            updateSelectedTime(stoppedMoving: false)
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if isLeftGesture {
                updateLeftConstraint(with: translation)
            } else {
                updateRightConstraint(with: translation)
            }
            layoutIfNeeded()
            Task {
                if let startTime = await getStartTime(), isLeftGesture {
                    seek(to: startTime)
                } else if let endTime = await getEndTime() {
                    seek(to: endTime)
                }
                updateSelectedTime(stoppedMoving: false)
            }

        case .cancelled, .ended, .failed:
            updateSelectedTime(stoppedMoving: true)
        default: break
        }
    }

    private func updateLeftConstraint(with translation: CGPoint) {
        Task {
            let miniDiff = await minimumDistanceBetweenHandle()
            let maxConstraint = max(rightHandleView.frame.origin.x - handleWidth - miniDiff, 0)
            let newConstraint = min(max(0, currentLeftConstraint + translation.x), maxConstraint)
            leftConstraint?.constant = newConstraint
        }
    }

    private func updateRightConstraint(with translation: CGPoint) {
        Task {
            let miniDiff = await minimumDistanceBetweenHandle()
            let maxConstraint = min(2 * handleWidth - frame.width + leftHandleView.frame.origin.x + miniDiff, 0)
            let newConstraint = max(min(0, currentRightConstraint + translation.x), maxConstraint)
            rightConstraint?.constant = newConstraint
        }
    }

    // MARK: - Asset loading

    override func assetDidChange(newAsset: AVAsset?) {
        super.assetDidChange(newAsset: newAsset)
        resetHandleViewPosition()
    }

    private func resetHandleViewPosition() {
        leftConstraint?.constant = 0
        rightConstraint?.constant = 0
        layoutIfNeeded()
    }

    // MARK: - Time Equivalence

    /// Move the position bar to the given time.
    public func seek(to time: CMTime) {
        Task {
            if let newPosition = await getPosition(from: time) {

                let offsetPosition = newPosition - assetPreview.contentOffset.x - leftHandleView.frame.origin.x
                let maxPosition = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handleWidth)
                                  - positionBar.frame.width
                let normalizedPosition = min(max(0, offsetPosition), maxPosition)
                positionConstraint?.constant = normalizedPosition
                layoutIfNeeded()
            }
        }
    }

    /// The selected start time for the current asset.
    public func getStartTime() async -> CMTime? {
        let startPosition = leftHandleView.frame.origin.x + assetPreview.contentOffset.x
        return await getTime(from: startPosition)
    }

    /// The selected end time for the current asset.
    public func getEndTime() async -> CMTime? {
        let endPosition = rightHandleView.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        return await getTime(from: endPosition)
    }

    private func updateSelectedTime(stoppedMoving: Bool) {
        Task {
            guard let playerTime = await getPositionBarTime() else {
                return
            }
            if stoppedMoving {
                delegate?.positionBarStoppedMoving(playerTime)
            } else {
                delegate?.didChangePositionBar(playerTime)
            }
        }
    }

    private func getPositionBarTime() async -> CMTime? {
        let barPosition = positionBar.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        return await getTime(from: barPosition)
    }

    private func minimumDistanceBetweenHandle() async -> CGFloat {
        guard let asset = asset else { return 0 }
        let duration = (try? await asset.load(.duration)) ?? .zero
        return CGFloat(minDuration) * assetPreview.contentView.frame.width / CGFloat(duration.seconds)
    }

    // MARK: - Scroll View Delegate

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedTime(stoppedMoving: true)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedTime(stoppedMoving: true)
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedTime(stoppedMoving: false)
    }
}
