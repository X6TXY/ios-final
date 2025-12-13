//
//  GradientView.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

    func setupGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber]) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = locations
        
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
