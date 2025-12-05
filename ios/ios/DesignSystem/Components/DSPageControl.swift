//
//  DSPageControl.swift
//  ios
//
//  Custom Page Control with Red Dots
//

import UIKit

class DSPageControl: UIView {
    
    var numberOfPages: Int = 0 {
        didSet {
            setupDots()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateCurrentPage()
        }
    }
    
    var dotSize: CGFloat = 8
    var dotSpacing: CGFloat = 8
    var activeDotColor: UIColor = DesignColors.primary
    var inactiveDotColor: UIColor = DesignColors.textTertiary
    
    private var dotViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    private func setupDots() {
        // Remove existing dots
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        
        // Create new dots
        for i in 0..<numberOfPages {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = i == currentPage ? activeDotColor : inactiveDotColor
            dot.layer.cornerRadius = dotSize / 2
            dot.alpha = i == currentPage ? 1.0 : 0.5
            
            addSubview(dot)
            dotViews.append(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
        
        // Layout dots horizontally
        for (index, dot) in dotViews.enumerated() {
            if index == 0 {
                dot.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                dot.leadingAnchor.constraint(equalTo: dotViews[index - 1].trailingAnchor, constant: dotSpacing).isActive = true
            }
            
            if index == dotViews.count - 1 {
                dot.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
        }
        
        updateCurrentPage()
    }
    
    private func updateCurrentPage() {
        guard currentPage >= 0 && currentPage < dotViews.count else { return }
        
        for (index, dot) in dotViews.enumerated() {
            let isActive = index == currentPage
            
            UIView.animate(withDuration: DesignAnimation.durationFast) {
                dot.backgroundColor = isActive ? self.activeDotColor : self.inactiveDotColor
                dot.alpha = isActive ? 1.0 : 0.5
                dot.transform = isActive ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let width = CGFloat(numberOfPages) * dotSize + CGFloat(max(0, numberOfPages - 1)) * dotSpacing
        return CGSize(width: width, height: dotSize)
    }
}

