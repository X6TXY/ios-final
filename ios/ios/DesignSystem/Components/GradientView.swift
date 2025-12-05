//
//  GradientView.swift
//  ios
//
//  Design System - Gradient View Component
//

import UIKit

class GradientView: UIView {
    
    var colors: [UIColor] = [] {
        didSet {
            updateGradient()
        }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func updateGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
    }
}

