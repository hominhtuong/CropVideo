//
//  CropVideoController.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import AVFoundation
import MiTuKit
import Photos

//MARK: Init and Variables
public class CropVideoViewController: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.originalUrl = url
        self.originalAsset = AVURLAsset(url: url)

        self.avAsset = originalAsset
        self.url = originalUrl
        self.setupPlayer()
    }

    // Variables
    public var configs: CropVideoConfigs = CropVideoConfigs() {
        didSet {
            updateUI()
        }
    }
    public var delegate: CropVideoDelegate?
    public var avAsset: AVURLAsset!
    public var url: URL!

    private var originalUrl: URL!
    private var originalAsset: AVURLAsset!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var avPlayerLayer: AVPlayerLayer!
    private let playerView = UIView()

    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let doneButton = UIButton()
    private let revertButton = UIButton()
    private let cancelButton = UIButton()

    private let bottomView = UIView()
    private let cropButton = UIButton()
    private let trimmerButton = UIButton()
    private let trimmerView = TrimmerView()
    private var playbackTimeCheckerTimer: Timer?

    private let cropContainerView = UIView()
    private let cropAreaView = UIView()
    private let overlayLayer = CAShapeLayer()

    private let userTapMargin: CGFloat = 35
    private let cropAreaViewMinWidth: CGFloat = maxWidth * 0.2
    private let cropAreaViewMinHeight: CGFloat = maxWidth * 0.2

    private let actionView = UIView()
    private let actionContainerView = UIView()
    private let playButton = UIButton()
    private let pauseButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private var hideActionTimer: Timer?

    private let topDotView = UIView()
    private let bottomDotView = UIView()
    private let leftDotView = UIView()
    private let rightDotView = UIView()

    private var hasSetupConsstraints: Bool = false

    private var isCroping: Bool = false {
        didSet {
            self.cancelButton.isHidden = !isCroping
            self.backButton.isHidden = isCroping
            self.cropContainerView.isHidden = !isCroping

            let doneTitle =
                isCroping ? configs.strings.crop : configs.strings.done
            self.doneButton.setTitle(doneTitle, for: .normal)

            let buttonFont = configs.fonts.buttonFont
            let doneWidth = configs.strings.trim.width(
                height: 32, font: buttonFont)

            self.doneButton.snp.updateConstraints {
                $0.width.equalTo(doneWidth + 10)
            }

            if isCroping {
                self.revertButton.disable()
                self.cropButton.disable()
                self.trimmerButton.disable()
                self.doneButton.enable()
            } else {

                self.cropButton.enable()
                self.trimmerButton.enable()

                if url != originalUrl {
                    self.revertButton.enable()
                    self.doneButton.enable()
                } else {
                    self.doneButton.disable()
                }
            }

            self.view.layoutIfNeeded()
        }
    }

    private var isTrimming: Bool = false {
        didSet {
            self.cancelButton.isHidden = !isTrimming
            self.backButton.isHidden = isTrimming
            self.trimmerView.isHidden = !isTrimming

            let doneTitle =
                isTrimming ? configs.strings.trim : configs.strings.done
            self.doneButton.setTitle(doneTitle, for: .normal)

            let buttonFont = configs.fonts.buttonFont
            let doneWidth = configs.strings.trim.width(
                height: 32, font: buttonFont)

            self.doneButton.snp.updateConstraints {
                $0.width.equalTo(doneWidth + 10)
            }

            if isTrimming {
                self.revertButton.disable()
                self.doneButton.enable()
                self.cropButton.disable()
                self.trimmerButton.disable()
            } else {
                self.cropButton.enable()
                self.trimmerButton.enable()

                if url != originalUrl {
                    self.revertButton.enable()
                    self.doneButton.enable()
                } else {
                    self.doneButton.disable()
                }
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissView() {
        switch configs.transition {
        case .push(let animated):
            navigationController?.popViewController(animated: animated)
        case .present(let animated):
            dismiss(animated: animated)
        }
    }
}

//MARK: Lifecycle
extension CropVideoViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(
            true, animated: false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = playerView.bounds
        avPlayerLayer.layoutIfNeeded()

    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.trimmerView.asset = originalAsset
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stop()
    }
}

//MARK: Public Functions
extension CropVideoViewController {
    public func deleteCaches(_ completion: ((Error?) -> Void)? = nil) {
        MTFileHelper.shared.deleteCaches(completion)
    }

    public func play() {
        NotificationCenter.default.removeObserver(
            self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: self.player?.currentItem
        )

        player.play()
        autoHideActionView()

        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
    }

    public func pause() {
        NotificationCenter.default.removeObserver(
            self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player.pause()
        hideActionTimer?.invalidate()
        self.playButton.isHidden = false
        self.pauseButton.isHidden = true
    }

    public func stop() {
        NotificationCenter.default.removeObserver(
            self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.pause()
        player.seek(to: .zero)
    }

}

//MARK: - Private function
extension CropVideoViewController {
    private func setupPlayer() {
        if let player = self.player {
            player.pause()
            player.seek(to: .zero)
        }

        if let layer = self.avPlayerLayer {
            layer.removeFromSuperlayer()
        }

        guard let asset = avAsset else {
            self.player = AVPlayer()
            return
        }

        self.playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: self.playerItem)

        self.avPlayerLayer = AVPlayerLayer(player: self.player)
        self.avPlayerLayer.videoGravity = .resizeAspect
        self.playerView.layer.addSublayer(self.avPlayerLayer)

        self.avPlayerLayer.frame = playerView.bounds
        self.view.layoutIfNeeded()

        self.play()
    }

    private func setupView() {
        view.backgroundColor = configs.colors.backgroundColor
        let buttonFont = configs.fonts.buttonFont

        headerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(50 + topSafeHeight)
            }
            $0.backgroundColor = configs.colors.bgHeaderColor
        }

        backButton >>> headerView >>> {
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-16)
                $0.leading.equalToSuperview().offset(16)
                $0.width.height.equalTo(32)
            }
            $0.setImage(configs.images.backButton, for: .normal)
            $0.handle {
                self.delegate?.didTapBack()
                self.dismissView()
            }
        }

        let cancelWidth = configs.strings.cancel.width(
            height: 32, font: buttonFont)
        cancelButton >>> headerView >>> {
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-16)
                $0.leading.equalToSuperview().offset(16)
                $0.height.equalTo(32)
                $0.width.equalTo(cancelWidth + 10)
            }
            $0.contentHorizontalAlignment = .left
            $0.titleLabel?.font = buttonFont
            $0.setTitle(configs.strings.cancel, for: .normal)
            $0.setTitleColor(configs.colors.nativationTintColor, for: .normal)
            $0.isHidden = true
            $0.handle {
                if self.isCroping {
                    self.isCroping = false
                }
                if self.isTrimming {
                    self.isTrimming = false
                }

            }
        }

        let doneWidth = configs.strings.done.width(height: 32, font: buttonFont)

        doneButton >>> headerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(backButton)
                $0.trailing.equalToSuperview().offset(-8)
                $0.height.equalTo(32)
                $0.width.equalTo(doneWidth + 10)
            }
            $0.titleLabel?.font = buttonFont
            $0.setTitle(configs.strings.done, for: .normal)
            $0.setTitleColor(configs.colors.nativationTintColor, for: .normal)
            $0.disable()
            $0.handle {
                if self.isCroping {
                    self.doneCroping()
                } else if self.isTrimming {
                    self.doneTrimming()
                } else {
                    self.delegate?.didTapDone(editedUrl: self.url)
                    self.dismissView()
                }

            }
        }

        let resetWidth = configs.strings.revert.width(
            height: 32, font: buttonFont)
        revertButton >>> headerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(backButton)
                $0.trailing.equalTo(doneButton.snp.leading).offset(-8)
                $0.height.equalTo(32)
                $0.width.equalTo(resetWidth + 10)
            }
            $0.titleLabel?.font = buttonFont
            $0.setTitle(configs.strings.revert, for: .normal)
            $0.setTitleColor(configs.colors.nativationTintColor, for: .normal)
            $0.disable()
            $0.handle {
                self.url = self.originalUrl
                self.avAsset = self.originalAsset
                self.trimmerView.asset = self.originalAsset
                self.setupPlayer()
                self.revertButton.disable()
                self.doneButton.disable()
                self.delegate?.didRevertVideo()
            }
        }

        titleLabel >>> headerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(backButton)
                $0.centerX.equalToSuperview().priority(.low)
                $0.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(
                    8
                ).priority(.high)
                $0.trailing.lessThanOrEqualTo(revertButton.snp.leading).offset(
                    -8
                ).priority(.high)
                $0.height.equalTo(32)
            }
            $0.font = configs.fonts.titleFont
            $0.textColor = configs.colors.titleColor
            $0.text = configs.strings.title
            $0.textAlignment = .center
        }

        bottomView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(botSafeHeight + 56)
            }
            $0.backgroundColor = configs.colors.bgBottomColor
        }

        cropButton >>> bottomView >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.centerX.equalToSuperview().multipliedBy(0.5)
                $0.width.height.equalTo(32)
            }
            $0.backgroundColor = .clear
            $0.setImage(configs.images.cropIcon, for: .normal)
            $0.handle { [weak self] in self?.openCropView() }
        }

        trimmerButton >>> bottomView >>> {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.centerX.equalToSuperview().multipliedBy(1.5)
                $0.width.height.equalTo(32)
            }
            $0.backgroundColor = .clear
            $0.setImage(configs.images.trimmerIcon, for: .normal)
            $0.handle { [weak self] in self?.openStrimmerView() }
        }

        trimmerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.top.equalTo(bottomView)
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().offset(-16)
                $0.height.equalTo(50)
            }
            $0.handleColor = configs.colors.handleColor
            $0.mainColor = configs.colors.mainColor
            $0.delegate = self
            $0.isHidden = true
            $0.minDuration = configs.values.minDuration
        }

        playerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.top.equalTo(headerView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(bottomView.snp.top)
            }
            $0.backgroundColor = configs.colors.bgPlayerView
        }

        //Setup player
        actionView >>> view >>> {
            $0.snp.makeConstraints {
                $0.top.equalTo(headerView.snp.bottom)
                $0.bottom.equalTo(bottomView.snp.top)
                $0.leading.trailing.equalToSuperview()
            }
            $0.backgroundColor = .clear
            $0.tapHandle {
                self.autoHideActionView()
            }
        }

        actionContainerView >>> actionView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            $0.backgroundColor = .clear
        }

        playButton >>> actionContainerView >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(79)
            }
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 10
            $0.setImage(configs.images.playIcon, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.isHidden = true
            $0.handle {
                self.play()
            }
        }

        pauseButton >>> actionContainerView >>> {
            $0.snp.makeConstraints {
                $0.edges.equalTo(playButton)
            }
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 10
            $0.setImage(configs.images.pauseIcon, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.handle {
                self.pause()
            }
        }

        previousButton >>> actionContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(playButton)
                $0.width.height.equalTo(39)
                $0.trailing.equalTo(playButton.snp.leading).offset(
                    Padding.botRight)
            }
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 10
            $0.setImage(configs.images.previousIcon, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.handle {
                let currentTime = self.player.currentTime().seconds
                let newTime = max(currentTime - 15, 0)

                let time = CMTime(
                    seconds: newTime,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.player.seek(to: time)
            }
        }

        nextButton >>> actionContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(playButton)
                $0.width.height.equalTo(39)
                $0.leading.equalTo(playButton.snp.trailing).offset(
                    Padding.topLeft)
            }
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 10
            $0.setImage(configs.images.nextIcon, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.handle {
                guard let duration = self.player.currentItem?.duration else {
                    return
                }
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                let totalDuration = CMTimeGetSeconds(duration)
                let newTime = min(currentTime + 15, totalDuration)

                let time = CMTime(
                    seconds: newTime,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.player.seek(to: time)
            }
        }

        //setup crop
        cropContainerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.edges.equalTo(playerView)
            }
            $0.backgroundColor = .clear
            $0.isHidden = true
        }

        cropAreaView >>> cropContainerView >>> {
            $0.frame = CGRect(
                x: (maxWidth / 4), y: (maxHeight / 2) - maxWidth * 0.25,
                width: maxWidth / 2,
                height: maxWidth * 0.5)
            $0.backgroundColor = .clear
            $0.layer.borderColor = configs.colors.cropBorderColor.cgColor
            $0.layer.borderWidth = 2
        }

        topDotView >>> cropContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(cropAreaView.snp.top).offset(1)
                $0.centerX.equalTo(cropAreaView)
                $0.width.height.equalTo(12)
            }
            $0.layer.cornerRadius = 6
            $0.backgroundColor = configs.colors.cropDotColor
        }

        bottomDotView >>> cropContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(cropAreaView.snp.bottom).offset(-1)
                $0.centerX.equalTo(cropAreaView)
                $0.width.height.equalTo(12)
            }
            $0.layer.cornerRadius = 6
            $0.backgroundColor = configs.colors.cropDotColor
        }

        leftDotView >>> cropContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(cropAreaView)
                $0.centerX.equalTo(cropAreaView.snp.leading).offset(1)
                $0.width.height.equalTo(12)
            }
            $0.layer.cornerRadius = 6
            $0.backgroundColor = configs.colors.cropDotColor
        }

        rightDotView >>> cropContainerView >>> {
            $0.snp.makeConstraints {
                $0.centerY.equalTo(cropAreaView)
                $0.centerX.equalTo(cropAreaView.snp.trailing).offset(-1)
                $0.width.height.equalTo(12)
            }
            $0.layer.cornerRadius = 6
            $0.backgroundColor = configs.colors.cropDotColor
        }

        hasSetupConsstraints = true
        setupGestures()
    }

    private func openStrimmerView() {
        self.isTrimming = true
    }

    private func openCropView() {
        isCroping = true
        updateMask()
    }

    private func setupGestures() {
        // Pan Gesture để di chuyển cropAreaView
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(handlePan(_:)))
        cropAreaView.addGestureRecognizer(panGesture)
    }

    private func doneCroping() {
        self.showLoading(
            color: .white, containerColor: configs.colors.loadingColor)
        guard
            let outputUrl = MTFileHelper.shared.createFile(
                fileName: "crop_\(Date().timeIntervalSince1970)",
                fileExtension: "mp4")
        else {
            return
        }
        Task {
            let videoSize = await self.getOriginalVideoSize()
            self.cropVideo(outputUrl: outputUrl, videoSize: videoSize)
        }

    }

    private func cropVideo(outputUrl: URL, videoSize: CGSize) {
        let playerSize = self.playerView.bounds.size

        let videoAspectRatio = videoSize.width / videoSize.height
        let playerAspectRatio = playerSize.width / playerSize.height

        var displayedVideoSize: CGSize
        if videoAspectRatio > playerAspectRatio {
            let width = playerSize.width
            let height = width / videoAspectRatio
            displayedVideoSize = CGSize(width: width, height: height)
        } else {
            let height = playerSize.height
            let width = height * videoAspectRatio
            displayedVideoSize = CGSize(width: width, height: height)
        }

        let paddingX = (playerSize.width - displayedVideoSize.width) / 2
        let paddingY = (playerSize.height - displayedVideoSize.height) / 2

        let cropFrame = self.cropAreaView.convert(
            self.cropAreaView.bounds, to: self.playerView)

        let cropX = cropFrame.origin.x - paddingX
        let cropY = cropFrame.origin.y - paddingY

        let scaleX = videoSize.width / displayedVideoSize.width
        let scaleY = videoSize.height / displayedVideoSize.height

        let adjustedX = max(0, cropX * scaleX)
        let adjustedY = max(0, cropY * scaleY)
        let adjustedWidth = min(
            videoSize.width - adjustedX, cropFrame.width * scaleX)
        let adjustedHeight = min(
            videoSize.height - adjustedY, cropFrame.height * scaleY)

        let cropRect = CGRect(
            x: adjustedX, y: adjustedY, width: adjustedWidth,
            height: adjustedHeight)

        MTFileHelper.shared.cropVideo(
            inputURL: self.url, outputURL: outputUrl,
            cropRect: cropRect
        ) { success in
            Queue.main {
                self.hideLoading()
                if success {
                    self.delegate?.didCropVideo(
                        cropUrl: outputUrl, originalUrl: self.originalUrl)
                    self.url = outputUrl
                    self.avAsset = AVURLAsset(url: outputUrl)
                    self.trimmerView.asset = self.avAsset
                    self.setupPlayer()
                    self.revertButton.enable()

                    if self.configs.values.showAlertWhenCompleted {
                        self.showAlert(
                            title: self.configs.strings.saved,
                            message: self.configs.strings.cropVideoSuccess,
                            actionTile: self.configs.strings.ok)
                    }
                } else {
                    if self.configs.values.showAlertWhenCompleted {
                        self.showAlert(
                            title: self.configs.strings.failed,
                            message: self.configs.strings.cropVideoFailed,
                            actionTile: self.configs.strings.ok)
                    }

                }
                self.isCroping = false
            }
        }
    }

    private func doneTrimming() {
        Task {
            guard let startTime = await self.trimmerView.getStartTime(),
                let endTime = await self.trimmerView.getEndTime()
            else {
                printDebug("TrimmerView not init")
                self.isTrimming = false
                return
            }

            trimVideo(startTime: startTime, endTime: endTime)
        }
    }

    private func trimVideo(startTime: CMTime, endTime: CMTime) {
        self.showLoading(
            color: .white, containerColor: configs.colors.loadingColor)
        guard
            let outputUrl = MTFileHelper.shared.createFile(
                fileName: "trim_\(Date().timeIntervalSince1970)",
                fileExtension: "mp4")
        else {
            return
        }

        Task {
            let success = await MTFileHelper.shared.trimVideo(
                inputPath: self.url, outputPath: outputUrl,
                startTime: startTime, endTime: endTime)
            self.hideLoading()
            if success {
                self.delegate?.didTrimVideo(
                    trimUrl: outputUrl, originalUrl: self.originalUrl)
                self.url = outputUrl
                self.avAsset = AVURLAsset(url: outputUrl)
                self.trimmerView.asset = self.avAsset
                self.setupPlayer()
                self.revertButton.enable()

                if self.configs.values.showAlertWhenCompleted {
                    self.showAlert(
                        title: self.configs.strings.saved,
                        message: self.configs.strings.trimVideoSuccess,
                        actionTile: self.configs.strings.ok)
                }

            } else {
                if self.configs.values.showAlertWhenCompleted {
                    self.showAlert(
                        title: self.configs.strings.failed,
                        message: self.configs.strings.trimVideoFailed,
                        actionTile: self.configs.strings.ok)
                }
            }
            self.isTrimming = false
        }
    }

    private func updateMask() {
        let path = UIBezierPath(rect: cropContainerView.bounds)
        let cropRect = cropAreaView.frame
        let transparentPath = UIBezierPath(rect: cropRect).reversing()

        path.append(transparentPath)

        overlayLayer.path = path.cgPath
        overlayLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor

        if overlayLayer.superlayer == nil {
            cropContainerView.layer.addSublayer(overlayLayer)

            cropContainerView.bringSubviewToFront(topDotView)
            cropContainerView.bringSubviewToFront(leftDotView)
            cropContainerView.bringSubviewToFront(rightDotView)
            cropContainerView.bringSubviewToFront(bottomDotView)
        }
    }

    private func getOriginalVideoSize() async -> CGSize {
        let asset = self.avAsset ?? AVURLAsset(url: self.url)

        do {
            // Load video tracks asynchronously
            let tracks = try await asset.loadTracks(withMediaType: .video)
            guard let track = tracks.first else {
                print("No video track found")
                return .zero
            }

            // Load preferredTransform and naturalSize asynchronously
            let preferredTransform = try await track.load(.preferredTransform)
            let naturalSize = try await track.load(.naturalSize)

            // Apply the preferredTransform to a rectangle and get the transformed size
            let transformedRect = CGRect(origin: .zero, size: naturalSize)
                .applying(preferredTransform)
            let transformedSize = transformedRect.size

            // Return the absolute size
            return CGSize(
                width: abs(transformedSize.width),
                height: abs(transformedSize.height))
        } catch {
            print(
                "Error loading video properties: \(error.localizedDescription)")
            return .zero
        }
    }

    private func autoHideActionView() {
        self.hideActionTimer?.invalidate()

        if self.actionContainerView.isHidden {
            self.actionContainerView.alpha = 1
            self.actionContainerView.isHidden = false

            self.autoHideActionView()
        } else {
            self.hideActionTimer = Timer.scheduledTimer(
                withTimeInterval: 5, repeats: false,
                block: { _ in
                    UIView.animate(
                        withDuration: 1,
                        animations: {
                            self.actionContainerView.alpha = 0
                        },
                        completion: { _ in
                            self.actionContainerView.isHidden = true
                        })
                })
        }

    }

    private func updateUI() {
        // Cập nhật strings
        cancelButton.setTitle(configs.strings.cancel, for: .normal)
        doneButton.setTitle(configs.strings.done, for: .normal)
        revertButton.setTitle(configs.strings.revert, for: .normal)
        titleLabel.text = configs.strings.title

        // Cập nhật colors
        view.backgroundColor = configs.colors.backgroundColor
        headerView.backgroundColor = configs.colors.loadingColor
        cropAreaView.layer.borderColor = configs.colors.cropBorderColor.cgColor
        trimmerView.handleColor = configs.colors.handleColor
        trimmerView.mainColor = configs.colors.mainColor
        topDotView.backgroundColor = configs.colors.cropDotColor
        bottomDotView.backgroundColor = configs.colors.cropDotColor
        leftDotView.backgroundColor = configs.colors.cropDotColor
        rightDotView.backgroundColor = configs.colors.cropDotColor

        titleLabel.textColor = configs.colors.titleColor
        doneButton.setTitleColor(
            configs.colors.nativationTintColor, for: .normal)
        revertButton.setTitleColor(
            configs.colors.nativationTintColor, for: .normal)
        cancelButton.setTitleColor(
            configs.colors.nativationTintColor, for: .normal)

        // Cập nhật images
        backButton.setImage(configs.images.backButton, for: .normal)
        cropButton.setImage(configs.images.cropIcon, for: .normal)
        trimmerButton.setImage(configs.images.trimmerIcon, for: .normal)
        playButton.setImage(configs.images.playIcon, for: .normal)
        pauseButton.setImage(configs.images.pauseIcon, for: .normal)
        previousButton.setImage(configs.images.previousIcon, for: .normal)
        nextButton.setImage(configs.images.nextIcon, for: .normal)

        // Cập nhật font
        titleLabel.font = configs.fonts.titleFont

        let buttonFont = configs.fonts.buttonFont
        cancelButton.titleLabel?.font = buttonFont
        doneButton.titleLabel?.font = buttonFont
        revertButton.titleLabel?.font = buttonFont

        guard hasSetupConsstraints else { return }

        let resetWidth = configs.strings.revert.width(
            height: 32, font: buttonFont)
        let doneWidth = configs.strings.done.width(height: 32, font: buttonFont)
        let cancelWidth = configs.strings.cancel.width(
            height: 32, font: buttonFont)

        self.doneButton.snp.updateConstraints {
            $0.width.equalTo(doneWidth + 10)
        }

        self.revertButton.snp.updateConstraints {
            $0.width.equalTo(resetWidth + 10)
        }

        self.cancelButton.snp.updateConstraints {
            $0.width.equalTo(cancelWidth + 10)
        }
        self.view.layoutIfNeeded()
    }
}

//MARK: - @objc Functions
extension CropVideoViewController {
    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        self.player?.seek(to: .zero)
        self.player?.play()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: playerView)
        let locationInCropArea = gesture.location(in: cropAreaView)

        var directionType: PanDirectionType = .left
        if gesture.state == .changed {
            if abs(translation.x) > abs(translation.y) {
                directionType = translation.x > 0 ? .right : .left
            } else {
                directionType = translation.y > 0 ? .bottom : .top
            }
        }

        let isAtLeftEdge = locationInCropArea.x <= userTapMargin
        let isAtRightEdge =
            locationInCropArea.x >= cropAreaView.bounds.width - userTapMargin
        let isAtTopEdge = locationInCropArea.y <= userTapMargin
        let isAtBottomEdge =
            locationInCropArea.y >= cropAreaView.bounds.height - userTapMargin

        var newFrame = cropAreaView.frame
        let oldFrame = newFrame

        if isAtLeftEdge && directionType.isHorizontal {
            let newX = oldFrame.origin.x + translation.x
            let deltaX = oldFrame.origin.x - newX
            newFrame.origin.x = newX
            newFrame.size.width += deltaX
        } else if isAtRightEdge && directionType.isHorizontal {
            let newWidth = oldFrame.size.width + translation.x
            newFrame.size.width = max(
                30, min(newWidth, playerView.bounds.width - newFrame.origin.x))
        } else if isAtTopEdge && directionType.isVertical {
            let newY = oldFrame.origin.y + translation.y
            let deltaY = oldFrame.origin.y - newY
            newFrame.origin.y = newY
            newFrame.size.height += deltaY
        } else if isAtBottomEdge && directionType.isVertical {
            let newHeight = oldFrame.size.height + translation.y
            newFrame.size.height = max(
                30, min(newHeight, playerView.bounds.height - newFrame.origin.y)
            )
        } else if let view = gesture.view {
            var newCenter = CGPoint(
                x: view.center.x + translation.x,
                y: view.center.y + translation.y
            )

            newCenter.x = max(
                min(
                    newCenter.x, playerView.bounds.maxX - view.bounds.width / 2),
                view.bounds.width / 2
            )
            newCenter.y = max(
                min(
                    newCenter.y, playerView.bounds.maxY - view.bounds.height / 2
                ),
                view.bounds.height / 2
            )

            view.center = newCenter
            gesture.setTranslation(.zero, in: playerView)
            updateMask()
            return
        }

        if newFrame.origin.x >= 0, newFrame.origin.y >= 0,
            newFrame.size.width >= cropAreaViewMinWidth,
            newFrame.size.height >= cropAreaViewMinHeight,
            newFrame.maxX <= playerView.bounds.width,
            newFrame.maxY <= playerView.bounds.height
        {
            cropAreaView.frame = newFrame
        }

        gesture.setTranslation(.zero, in: playerView)
        updateMask()
    }

    @objc func onPlaybackTimeChecker() {
        Task {
            guard let startTime = await trimmerView.getStartTime(),
                let endTime = await trimmerView.getEndTime(),
                let player = player
            else {
                return
            }

            let playBackTime = player.currentTime()
            trimmerView.seek(to: playBackTime)

            if playBackTime >= endTime {
                await player.seek(
                    to: startTime, toleranceBefore: CMTime.zero,
                    toleranceAfter: CMTime.zero)
                trimmerView.seek(to: startTime)
            }
        }
    }

    @objc func itemDidFinishPlaying(_ notification: Notification) {
        Task {
            if let startTime = await trimmerView.getStartTime() {
                await player?.seek(to: startTime)
                if player?.isPlaying != true {
                    player?.play()
                }
            }
        }
    }

}

extension CropVideoViewController: TrimmerViewDelegate {
    public func didChangePositionBar(_ playerTime: CMTime) {
        player?.seek(
            to: playerTime, toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero)
        play()
        startPlaybackTimeChecker()
    }

    public func positionBarStoppedMoving(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(
            to: playerTime, toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero)
        play()
    }

    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(
            timeInterval: 0.1, target: self,
            selector:
                #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }

    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
}
