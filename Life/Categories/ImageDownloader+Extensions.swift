//
//  ImageDownloader+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

extension ImageDownloader {

    static func set(image: String,
                    employeeCode: String? = nil,
                    to imageView: UIImageView?,
                    placeholderImage: UIImage? = nil,
                    size: CGSize? = nil,
                    useDeviceScale: Bool = true) {
        imageView?.image = placeholderImage

        var imageKey = employeeCode ?? image
        if let employeeCode = employeeCode, let size = size {
            imageKey = "\(employeeCode)_\(Int(size.width))x\(Int(size.height))"
        } else if let size = size {
            imageKey = "\(image)_\(Int(size.width))x\(Int(size.height))"
        }

        guard !imageKey.isEmpty else {
            imageView?.image = placeholderImage
            return
        }
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey) {
            imageView?.image = image
            return
        }

        let modifier = AnyModifier { request in
            var req = request
            let token = User.current.token ?? ""
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return req
        }

        if let url = url(
            for: image,
            employeeCode: employeeCode,
            size: size,
            useDeviceScale: useDeviceScale) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (downloadedImage, _, _, _) in
                        if let downloadedImage = downloadedImage {
                            ImageCache.default.store(downloadedImage, forKey: imageKey)
                            imageView?.image = downloadedImage
                        } else {
                            imageView?.image = placeholderImage
                        }
            }
        }
    }

    static func download(image: String,
                         employeeCode: String? = nil,
                         placeholderImage: UIImage? = nil,
                         size: CGSize? = nil,
                         useDeviceScale: Bool = true,
                         completion: @escaping ((UIImage?) -> Void)) {
        var imageKey = employeeCode ?? image
        if let employeeCode = employeeCode, let size = size {
            imageKey = "\(employeeCode)_\(Int(size.width))x\(Int(size.height))"
        } else if let size = size {
            imageKey = "\(image)_\(Int(size.width))x\(Int(size.height))"
        }

        guard !imageKey.isEmpty else {
            completion(placeholderImage)
            return
        }
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey) {
            completion(image)
            return
        }

        let modifier = AnyModifier { request in
            var req = request
            let token = User.current.token ?? ""
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return req
        }

        if let url = url(
            for: image,
            employeeCode: employeeCode,
            size: size,
            useDeviceScale: useDeviceScale) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (downloadedImage, _, _, _) in
                        if let downloadedImage = downloadedImage {
                            ImageCache.default.store(downloadedImage, forKey: imageKey)
                            completion(downloadedImage)
                        } else {
                            completion(placeholderImage)
                        }
            }
        }
    }

    public static func url(
        for image: String,
        employeeCode: String? = nil,
        size: CGSize? = nil,
        useDeviceScale: Bool = true) -> URL? {
        var url = URL(string: image)

        if let code = employeeCode {
            if let size = size {
                let scale = useDeviceScale ? UIScreen.main.scale : 1
                let width = Int(size.width * scale)
                let height = Int(size.height * scale)
                let sizeQuery = "width=\(width)&height=\(height)"
                url = URL(string: "\(App.String.apiBaseUrl)/employees/\(code)/avatar?\(sizeQuery)")
            } else {
                url = URL(string: "\(App.String.apiBaseUrl)/employees/\(code)/avatar")
            }
        } else if !image.hasPrefix("http") && !image.hasPrefix("https") {

            let ratio: CGFloat = 360.0 / 300.0
            let scale = useDeviceScale ? UIScreen.main.scale : 1
            let width = size != nil ? size!.width * scale : UIScreen.main.bounds.size.width * scale
            let height = size != nil ? Int(size!.height * scale) : Int(width / ratio * scale)

            let urlParams = "?isMedia=true&width=\(Int(width))&height=\(height)&isAttachment=true"
            url = URL(string: "\(App.String.apiBaseUrl)/Files/\(image)\(urlParams)")
        }

        return url
    }

    public static func createThumbnailOfVideo(from streamId: String) -> UIImage? {
        let urlStr = "\(App.String.apiBaseUrl)/Files/\(streamId)"
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: urlStr) {
            return image
        }

        guard let url = URL(string: urlStr) else { return nil }

        let token = User.current.token ?? ""
        let headers = ["Authorization": "Bearer \(token)"]
        let asset = AVURLAsset(
            url: url,
            options: [
                "AVURLAssetHTTPHeaderFieldsKey": headers
            ]
        )
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            ImageCache.default.store(thumbnail, forKey: urlStr)
            return thumbnail
        } catch {
            print("Failed to get video thumbnail")
        }
        return nil
    }

}
