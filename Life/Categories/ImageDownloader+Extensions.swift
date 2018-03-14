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
                    to imageView: UIImageView?) {
        let imageKey = employeeCode ?? image
        guard !imageKey.isEmpty else {
            imageView?.image = nil
            return
        }
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey) {
            imageView?.image = image
            return
        }

        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = url(for: image, employeeCode: employeeCode) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (downloadedImage, _, _, _) in
                        if let downloadedImage = downloadedImage {
                            ImageCache.default.store(downloadedImage, forKey: imageKey)
                            imageView?.image = downloadedImage
                        }
            }
        }
    }

    static func download(image: String,
                         employeeCode: String? = nil,
                         completion: @escaping ((UIImage?) -> Void)) {
        let imageKey = employeeCode ?? image
        guard !imageKey.isEmpty else {
            completion(nil)
            return
        }
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey) {
            completion(image)
            return
        }

        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = url(for: image, employeeCode: employeeCode) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (downloadedImage, _, _, _) in
                        if let downloadedImage = downloadedImage {
                            ImageCache.default.store(downloadedImage, forKey: imageKey)
                        }
                        completion(downloadedImage)
            }
        }
    }

    public static func url(for image: String, employeeCode: String? = nil) -> URL? {
        var url = URL(string: image)

        if let code = employeeCode {
            url = URL(string: "\(App.String.apiBaseUrl)/employees/\(code)/avatar")
        } else if !image.hasPrefix("http") && !image.hasPrefix("https") {

            let ratio: CGFloat = 360.0 / 300.0
            let width = UIScreen.main.bounds.size.width * 2
            let height = Int(width / ratio)

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
