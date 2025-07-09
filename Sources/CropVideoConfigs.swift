//
//  CropVideoConfigs.swift
//  Pods
//
//  Created by Admin on 17/3/25.
//

import MiTuKit

public struct ButtonImageConfigs {
    public static let smallImageConfig = UIImage.SymbolConfiguration(
        pointSize: 25, weight: .regular, scale: .default)
    public static let defaultImageConfig = UIImage.SymbolConfiguration(
        pointSize: 27, weight: .regular, scale: .default)
    public static let lagerImageConfig = UIImage.SymbolConfiguration(
        pointSize: 60, weight: .regular, scale: .default)
}

public struct CropVideoConfigs {
    public var strings: Strings
    public var colors: Colors
    public var images: Images
    public var fonts: Fonts
    public var values: Values
    public var paddings: Paddings
    public var transition: TransitionType

    public init(
        strings: Strings = Strings(),
        colors: Colors = Colors(),
        images: Images = Images(),
        fonts: Fonts = Fonts(),
        values: Values = Values(),
        padding: Paddings = Paddings(),
        transition: TransitionType = TransitionType.push(animated: true)
    ) {
        self.strings = strings
        self.colors = colors
        self.images = images
        self.fonts = fonts
        self.values = values
        self.paddings = padding
        self.transition = transition
    }
}

public extension CropVideoConfigs {
    // MARK: - Strings
    struct Strings {
        public var cancel: String
        public var done: String
        public var crop: String
        public var trim: String
        public var revert: String
        public var title: String
        public var saved: String
        public var cropVideoSuccess: String
        public var cropVideoFailed: String
        public var trimVideoSuccess: String
        public var trimVideoFailed: String
        public var failed: String
        public var ok: String

        public init(
            cancel: String = "Cancel",
            done: String = "Done",
            crop: String = "Crop",
            trim: String = "Trim",
            revert: String = "Revert",
            title: String = "Editor",
            saved: String = "Saved",
            cropVideoSuccess: String = "Crop video successfully!",
            cropVideoFailed: String = "Crop video failed!",
            trimVideoSuccess: String = "Trim video successfully!",
            trimVideoFailed: String = "Trim video failed!",
            failed: String = "Failed!",
            ok: String = "OK"
        ) {
            self.cancel = cancel
            self.done = done
            self.crop = crop
            self.trim = trim
            self.revert = revert
            self.title = title
            self.saved = saved
            self.cropVideoSuccess = cropVideoSuccess
            self.cropVideoFailed = cropVideoFailed
            self.trimVideoSuccess = trimVideoSuccess
            self.trimVideoFailed = trimVideoFailed
            self.failed = failed
            self.ok = ok
        }
    }
}

public extension CropVideoConfigs {
    // MARK: - Colors
    struct Colors {
        public var backgroundColor: UIColor
        public var cropBorderColor: UIColor
        public var cropDotColor: UIColor
        public var loadingColor: UIColor
        public var bgPlayerView: UIColor
        public var bgHeaderColor: UIColor
        public var bgBottomColor: UIColor
        public var handleColor: UIColor
        public var mainColor: UIColor
        public var nativationTintColor: UIColor
        public var titleColor: UIColor

        public init(
            backgroundColor: UIColor = UIColor.from("36374b"),
            cropBorderColor: UIColor = UIColor.white,
            cropDotColor: UIColor = UIColor.white,
            bgHeaderColor: UIColor = UIColor.from("36374b"),
            bgBottomColor: UIColor = UIColor.from("36374b"),
            bgPlayerView: UIColor = UIColor.from("000000"),
            primaryColor: UIColor = UIColor.from("1a182d"),
            handleColor: UIColor = UIColor.white,
            mainColor: UIColor = UIColor.from("ffc81c"),
            nativationTintColor: UIColor = UIColor.white,
            titleColor: UIColor = UIColor.white
        ) {
            self.cropDotColor = cropDotColor
            self.cropBorderColor = cropBorderColor
            self.bgHeaderColor = bgHeaderColor
            self.backgroundColor = backgroundColor
            self.loadingColor = primaryColor
            self.bgPlayerView = bgPlayerView
            self.bgBottomColor = bgBottomColor
            self.handleColor = handleColor
            self.mainColor = mainColor
            self.nativationTintColor = nativationTintColor
            self.titleColor = titleColor
        }
    }
}

public extension CropVideoConfigs {
    // MARK: - Images
    struct Images {
        public var backButton: UIImage?
        public var cropIcon: UIImage?
        public var trimmerIcon: UIImage?
        public var playIcon: UIImage?
        public var pauseIcon: UIImage?
        public var previousIcon: UIImage?
        public var nextIcon: UIImage?

        public init(
            backButton: UIImage? = UIImage(
                systemName: "chevron.backward",
                withConfiguration: ButtonImageConfigs.smallImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            cropIcon: UIImage? = UIImage(
                systemName: "crop",
                withConfiguration: ButtonImageConfigs.defaultImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            trimmerIcon: UIImage? = UIImage(
                systemName: "timeline.selection",
                withConfiguration: ButtonImageConfigs.defaultImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            playIcon: UIImage? = UIImage(
                systemName: "play.circle",
                withConfiguration: ButtonImageConfigs.lagerImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            pauseIcon: UIImage? = UIImage(
                systemName: "pause.circle",
                withConfiguration: ButtonImageConfigs.lagerImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            previousIcon: UIImage? = UIImage(
                systemName: "15.arrow.trianglehead.counterclockwise",
                withConfiguration: ButtonImageConfigs.smallImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal),
            nextIcon: UIImage? = UIImage(
                systemName: "15.arrow.trianglehead.clockwise",
                withConfiguration: ButtonImageConfigs.smallImageConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        ) {
            self.backButton = backButton
            self.cropIcon = cropIcon
            self.trimmerIcon = trimmerIcon
            self.playIcon = playIcon
            self.pauseIcon = pauseIcon
            self.previousIcon = previousIcon
            self.nextIcon = nextIcon
        }
    }
}

public extension CropVideoConfigs {
    // MARK: - Fonts
    struct Fonts {
        public var titleFont: UIFont
        public var buttonFont: UIFont

        public init(
            titleFont: UIFont = UIFont.boldSystemFont(ofSize: 20),
            buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 15)

        ) {
            self.titleFont = titleFont
            self.buttonFont = buttonFont
        }
    }
}

public extension CropVideoConfigs {
    // MARK: - Values
    struct Values {
        public var minDuration: TimeInterval
        public var showAlertWhenCompleted: Bool

        public init(
            minDuration: TimeInterval = 2,
            showAlert: Bool = true
        ) {
            self.minDuration = minDuration
            self.showAlertWhenCompleted = showAlert
        }
    }

}

public extension CropVideoConfigs {
    // MARK: - Paddings
    struct Paddings {
        public var trimmerViewLeftPadding: CGFloat
        public var trimmerViewRightPadding: CGFloat

        public init(
            trimmerViewLeftPadding: CGFloat = 16,
            trimmerViewRightPadding: CGFloat = 16
        ) {
            self.trimmerViewLeftPadding = trimmerViewLeftPadding
            self.trimmerViewRightPadding = trimmerViewRightPadding
        }
    }

}

public extension CropVideoConfigs {
    enum TransitionType {
        case push(animated: Bool)
        case present(animated: Bool)
    }
}
