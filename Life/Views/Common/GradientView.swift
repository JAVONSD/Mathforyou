//
//  GradientView.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class GradientView: View {
    private class GradientSubview: UIView {
        override open class var layerClass: AnyClass {
            return CAGradientLayer.classForCoder()
        }

        // MARK: - Methods

        public func setGradient(colors: [UIColor]) {
            if let gradientLayer = self.layer as? CAGradientLayer {
                gradientLayer.colors = colors.map { $0.cgColor }
            }
        }

        public func makeHorizontal() {
            if let gradientLayer = self.layer as? CAGradientLayer {
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            }
        }

        public func makeVertical() {
            if let gradientLayer = self.layer as? CAGradientLayer {
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            }
        }
    }

    private var gradient: GradientSubview?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        gradient = GradientSubview()

        guard let gradient = gradient else { return }

        addSubview(gradient)
        gradient.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    // MARK: - Methods

    public func setGradient(colors: [UIColor]) {
        gradient?.setGradient(colors: colors)
    }

    public func makeHorizontal() {
        gradient?.makeHorizontal()
    }

    public func makeVertical() {
        gradient?.makeVertical()
    }

}
