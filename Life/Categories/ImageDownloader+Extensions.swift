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

    static func set(image: String, to imageView: UIImageView?) {
        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = URL(string: image) {
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

    static func download(image: String, completion: @escaping ((UIImage?) -> Void)) {
        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = URL(string: image) {
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

}
