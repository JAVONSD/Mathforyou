//
//  ImageDownloader+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher

extension ImageDownloader {

    static func set(image: String,
                    employeeCode: String? = nil,
                    to imageView: UIImageView?) {
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
                    progressBlock: nil) { (image, _, _, _) in
                        imageView?.image = image
            }
        }
    }

    static func download(image: String,
                         employeeCode: String? = nil,
                         completion: @escaping ((UIImage?) -> Void)) {
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
                    progressBlock: nil) { (image, _, _, _) in
                        completion(image)
            }
        }
    }

    private static func url(for image: String, employeeCode: String? = nil) -> URL? {
        var url = URL(string: image)

        if let code = employeeCode {
            url = URL(string: "\(App.String.apiBaseUrl)/employees/\(code)/avatar")
        } else if !image.hasPrefix("http") {

            let ratio: CGFloat = 360.0 / 300.0
            let width = UIScreen.main.bounds.size.width * 2
            let height = Int(width / ratio)

            let urlParams = "?isMedia=true&width=\(Int(width))&height=\(height)&isAttachment=true"
            url = URL(string: "\(App.String.apiBaseUrl)/Files/\(image)\(urlParams)")
        }

        return url
    }

}
