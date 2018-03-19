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
    public func set(image: String, employeeCode: String? = nil, placeholderImage: UIImage? = nil) {
        let url = self.url(for: image, employeeCode: employeeCode)
        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        kf.setImage(with: url, placeholder: placeholderImage, options: [.requestModifier(modifier)])
    }

    private func url(for image: String, employeeCode: String? = nil) -> URL? {
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
}
