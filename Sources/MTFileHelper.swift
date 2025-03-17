//
//  MTFileHelper.swift
//  CropVideo
//
//  Created by Mitu Ultra on 16/3/25.
//

import AVFoundation
import MiTuKit
import ffmpegkit

open class MTFileHelper: NSObject {
    public static let shared = MTFileHelper()

    // Variables
    private let fileManager = FileManager.default

    public var cacheURL: URL? {
        guard
            let cachesDirectory = fileManager.urls(
                for: .cachesDirectory, in: .userDomainMask
            ).first
        else {
            return nil
        }
        return cachesDirectory
    }

    private let defaultFolderName = "CropVideo"
}

extension MTFileHelper {
    public func deleteFile(with url: URL, completion: @escaping (Bool) -> Void)
    {
        do {
            try fileManager.removeItem(atPath: url.path)
            completion(true)
        } catch let error {
            printDebug("deleteFile error: \(error.localizedDescription)")
            completion(false)
        }
    }

    public func cropVideo(
        inputURL: URL, outputURL: URL, cropRect: CGRect,
        completion: @escaping (Bool) -> Void
    ) {
        let command =
            "-i \(inputURL.path) -vf \"crop=\(cropRect.width):\(cropRect.height):\(cropRect.minX):\(cropRect.minY)\" -c:v mpeg4 -q:v 2 -c:a copy \(outputURL.path)"

        FFmpegKit.executeAsync(command) { session in
            guard let returnCode = session?.getReturnCode() else {
                completion(false)
                return
            }
            if ReturnCode.isSuccess(returnCode) {
                printDebug("Video đã được cắt thành công.")
                completion(true)
            } else {
                printDebug(
                    "Lỗi khi cắt video: \(String(describing: session?.getLogs()))"
                )
                completion(false)
            }
        }
    }

    public func checkAvailableVideoCodec() async -> String {
        return await withCheckedContinuation { continuation in
            FFmpegKit.executeAsync("-codecs") { session in
                let logs = session?.getOutput() ?? ""
                let selectedCodec =
                    logs.contains("libx264") ? "libx264" : "h264_videotoolbox"
                continuation.resume(returning: selectedCodec)
            }
        }
    }

    public func trimVideo(
        inputPath: URL, outputPath: URL, startTime: CMTime, endTime: CMTime
    ) async -> Bool {
        let startSeconds = CMTimeGetSeconds(startTime)
        let durationSeconds = CMTimeGetSeconds(endTime) - startSeconds

        guard durationSeconds > 0 else {
            print("Invalid trim range")
            return false
        }

        let codec = await checkAvailableVideoCodec()
        let command =
            "-i \"\(inputPath.path)\" -ss \(startSeconds) -t \(durationSeconds) -c:v \(codec) -c:a aac -reset_timestamps 1 \"\(outputPath.path)\""

        return await withCheckedContinuation { continuation in
            FFmpegKit.executeAsync(command) { session in
                let returnCode = session?.getReturnCode()
                let success = ReturnCode.isSuccess(returnCode)
                continuation.resume(returning: success)
            }
        }
    }

    public func trimVideo(
        inputPath: URL, outputPath: URL, startTime: CMTime, endTime: CMTime,
        completion: @escaping (Bool) -> Void
    ) {

        let startSeconds = CMTimeGetSeconds(startTime)
        let durationSeconds = CMTimeGetSeconds(endTime) - startSeconds

        guard durationSeconds > 0 else {
            printDebug("Invalid trim range")
            completion(false)
            return
        }
        let command =
            "-i \"\(inputPath)\" -ss \(startSeconds) -t \(durationSeconds) -c:v h264_videotoolbox -c:a aac -reset_timestamps 1 \"\(outputPath)\""
        //let command = "-i \"\(inputPath)\" -ss \(startSeconds) -t \(durationSeconds) -c copy \"\(outputPath)\""

        FFmpegKit.executeAsync(command) { session in
            let returnCode = session?.getReturnCode()

            if ReturnCode.isSuccess(returnCode) {
                printDebug("Trimming succeeded: \(outputPath)")
                completion(true)
            } else {
                printDebug("Trimming failed")
                completion(false)
            }
        }
    }
}

extension MTFileHelper {
    public func createFolder(in folder: String, childFolder: String = "")
        -> URL?
    {
        guard let cacheURL = cacheURL else { return nil }
        let albumDirectory = cacheURL.appendingPathComponent(
            folder + "\(childFolder)")

        if fileManager.fileExists(atPath: albumDirectory.path) {
            return albumDirectory
        }

        do {
            try fileManager.createDirectory(
                at: albumDirectory, withIntermediateDirectories: true,
                attributes: nil)
            return albumDirectory
        } catch {
            printDebug(error.localizedDescription)
            return nil
        }
    }

    public func createFile(
        in folder: String = "", fileName: String? = nil,
        fileExtension: String = "mp4"
    ) -> URL? {
        let folderName = folder.isEmpty ? defaultFolderName : folder
        guard let folderURL = MTFileHelper.shared.createFolder(in: folderName)
        else {
            printDebug("cannot create folder")
            return nil
        }

        let fileName =
            fileName
            ?? "Temp_\(Date().toString(dateFormat: "yyyyMMdd-HHmmssSSS"))"
        let fileURL = folderURL.appendingPathComponent(
            "\(fileName).\(fileExtension)")

        return fileURL
    }

    public func copyFile(
        from url: URL, to: URL, _ completion: @escaping (Error?) -> Void
    ) {
        do {
            try fileManager.copyItem(at: url, to: to)
            completion(nil)
        } catch {
            printDebug(error.localizedDescription)
            completion(error)
        }
    }

    public func rename(
        with url: URL, fileName: String,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        let newUrl = url.deletingLastPathComponent().appendingPathComponent(
            fileName
        ).appendingPathExtension(url.pathExtension)
        do {
            try fileManager.moveItem(at: url, to: newUrl)
            completion(newUrl, nil)
        } catch let error {
            printDebug(error.localizedDescription)
            completion(nil, error)
        }
    }

    public func deleteCaches(_ completion: ((Error?) -> Void)? = nil) {
        guard let folderURL = MTFileHelper.shared.createFolder(in: defaultFolderName)
        else {
            printDebug("Cannot find cache folder")
            completion?(nil)
            return
        }
        do {
            try fileManager.removeItem(at: folderURL)
            printDebug("Delete caches successfully")
            completion?(nil)
        } catch {
            printDebug("Delete caches failed: \(error.localizedDescription)")
            completion?(error)
        }
    }
}
