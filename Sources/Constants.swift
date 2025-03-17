//
//  Constants.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import MiTuKit
import UIKit

public struct ButtonImageConfigs {
    public static let smallImageConfig = UIImage.SymbolConfiguration(
        pointSize: 25, weight: .regular, scale: .default)
    public static let defaultImageConfig = UIImage.SymbolConfiguration(
        pointSize: 27, weight: .regular, scale: .default)
    public static let lagerImageConfig = UIImage.SymbolConfiguration(
        pointSize: 60, weight: .regular, scale: .default)
}

public struct CropVideoConfigs {
    // MARK: - Strings
    public struct Strings {
        public var cancel: String
        public var done: String
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

    // MARK: - Colors
    public struct Colors {
        public var backgroundColor: UIColor
        public var loadingColor: UIColor
        public var bgPlayerView: UIColor
        public var bgHeaderColor: UIColor
        public var bgBottomColor: UIColor
        public var handleColor: UIColor
        public var mainColor: UIColor
        public var white: UIColor
        public var black: UIColor
        public var blackWithAlpha: UIColor
        public var nativationTintColor: UIColor
        public var titleColor: UIColor
        

        public init(
            backgroundColor: UIColor = UIColor.from("36374b"),
            bgHeaderColor: UIColor = UIColor.from("36374b"),
            bgBottomColor: UIColor = UIColor.from("36374b"),
            bgPlayerView: UIColor = UIColor.from("000000"),
            primaryColor: UIColor = UIColor.from("1a182d"),
            handleColor: UIColor = UIColor.white,
            mainColor: UIColor = UIColor.from("ffc81c"),
            white: UIColor = UIColor.white,
            black: UIColor = UIColor.black,
            blackWithAlpha: UIColor = UIColor.black.withAlphaComponent(0.6),
            nativationTintColor: UIColor = UIColor.white,
            titleColor: UIColor = UIColor.white
        ) {
            self.bgHeaderColor = bgHeaderColor
            self.backgroundColor = backgroundColor
            self.loadingColor = primaryColor
            self.bgPlayerView = bgPlayerView
            self.bgBottomColor = bgBottomColor
            self.handleColor = handleColor
            self.mainColor = mainColor
            self.white = white
            self.black = black
            self.blackWithAlpha = blackWithAlpha
            self.nativationTintColor = nativationTintColor
            self.titleColor = titleColor
        }
    }

    // MARK: - Images
    public struct Images {
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
                withConfiguration: ButtonImageConfigs.defaultImageConfig)?
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
    
    // MARK: - Fonts
    public struct Fonts {
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
    
    // MARK: - Values
    public struct Values {
        public var minDuration: TimeInterval
        
        public init(
            minDuration: TimeInterval = 2
        ) {
            self.minDuration = minDuration
        }
    }

    public var strings: Strings
    public var colors: Colors
    public var images: Images
    public var fonts: Fonts
    public var values: Values

    // Default initializer
    public init(
        strings: Strings = Strings(),
        colors: Colors = Colors(),
        images: Images = Images(),
        fonts: Fonts = Fonts(),
        values: Values = Values()
    ) {
        self.strings = strings
        self.colors = colors
        self.images = images
        self.fonts = fonts
        self.values = values
    }
}

// Example of custom configs
public var viConfigs: CropVideoConfigs {
    var configs = CropVideoConfigs()
    configs.strings = CropVideoConfigs.Strings(
        cancel: "Hủy",
        done: "Xong",
        revert: "Khôi phục",
        title: "Chỉnh sửa",
        saved: "Đã lưu",
        cropVideoSuccess: "Cắt video thành công!",
        cropVideoFailed: "Cắt video thất bại!",
        trimVideoSuccess: "Cắt đoạn video thành công!",
        trimVideoFailed: "Cắt đoạn video thất bại!",
        failed: "Thất bại!",
        ok: "OK"
    )
    return configs
}

public let customConfigs = CropVideoConfigs(
    strings: CropVideoConfigs.Strings(
        cancel: "Hủy",
        done: "Xong",
        revert: "Khôi phục",
        title: "Chỉnh sửa",
        saved: "Đã lưu",
        cropVideoSuccess: "Cắt video thành công!",
        cropVideoFailed: "Cắt video thất bại!",
        trimVideoSuccess: "Cắt đoạn video thành công!",
        trimVideoFailed: "Cắt đoạn video thất bại!",
        failed: "Thất bại!",
        ok: "OK"
    ),
    colors: CropVideoConfigs.Colors(
        bgBottomColor: .blue,
        primaryColor: .red,
        handleColor: .white,
        mainColor: .yellow,
        white: .white,
        black: .black,
        blackWithAlpha: UIColor.black.withAlphaComponent(0.6)
    ),
    images: CropVideoConfigs.Images(
        backButton: UIImage(named: "custom_back_icon"),
        cropIcon: UIImage(systemName: "custom_crop_icon"),
        trimmerIcon: UIImage(systemName: "custom_trimmer_icon"),
        playIcon: UIImage(systemName: "custom_play_icon"),
        pauseIcon: UIImage(systemName: "custom_pause_icon"),
        previousIcon: UIImage(systemName: "custom_previous_icon"),
        nextIcon: UIImage(systemName: "custom_next_icon")
    )
)

// Padding
public struct Padding {
    public static let topLeft: CGFloat = 16
    public static let botRight: CGFloat = -16
}
