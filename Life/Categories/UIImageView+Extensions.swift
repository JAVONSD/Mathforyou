//
//  UIImageView+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 03.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    public func set(
        image: String,
        employeeCode: String? = nil,
        placeholderImage: UIImage? = nil,
        size: CGSize? = nil,
        useDeviceScale: Bool = true) {
        let url = ImageDownloader.url(
            for: image,
            employeeCode: employeeCode,
            size: size,
            useDeviceScale: useDeviceScale
        )
        let modifier = AnyModifier { request in
            var req = request
            let token = User.current.token ?? ""
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return req
        }

        kf.setImage(with: url, placeholder: placeholderImage, options: [.requestModifier(modifier)])
    }
}
