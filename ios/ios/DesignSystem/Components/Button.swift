//
//  Button.swift
//  ios
//
//  Design System - Button Component
//

import UIKit

enum ButtonStyle {
    case primary
    case secondary
    case text
}

class DSButton: UIButton {
    var style: ButtonStyle = .primary {
        didSet {
            updateStyle()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = DesignBorder.radiusMD
        titleLabel?.font = DesignTypography.bodyBold
        translatesAutoresizingMaskIntoConstraints = false
        
        // Minimum touch target
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: DesignLayout.touchTargetMinimum)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        
        updateStyle()
    }
    
    private func updateStyle() {
        // Remove shadow for all styles first
        layer.shadowOpacity = 0
        
        switch style {
        case .primary:
            backgroundColor = isEnabled ? DesignColors.primary : DesignColors.textDisabled
            setTitleColor(DesignColors.textPrimary, for: .normal)
            setTitleColor(DesignColors.textTertiary, for: .disabled)
            layer.borderWidth = 0
            
            // Add subtle shadow for primary button
            if isEnabled {
                let shadow = DesignShadow.shadow(for: .low)
                layer.shadowColor = DesignColors.primary.cgColor
                layer.shadowOffset = shadow.offset
                layer.shadowRadius = shadow.radius
                layer.shadowOpacity = shadow.opacity * 0.5
            }
            
        case .secondary:
            backgroundColor = DesignColors.backgroundSecondary
            layer.borderWidth = DesignBorder.widthThin
            layer.borderColor = DesignColors.borderSecondary.cgColor
            setTitleColor(DesignColors.textPrimary, for: .normal)
            setTitleColor(DesignColors.textDisabled, for: .disabled)
            
        case .text:
            backgroundColor = .clear
            layer.borderWidth = 0
            setTitleColor(DesignColors.primary, for: .normal)
            setTitleColor(DesignColors.textDisabled, for: .disabled)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Padding is handled by height constraints and titleLabel insets
    }
    
    // MARK: - State Animations
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(down: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(down: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(down: false)
    }
    
    private func animatePress(down: Bool) {
        UIView.animate(withDuration: DesignAnimation.durationFast) {
            self.transform = down ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            self.alpha = down ? 0.8 : 1.0
        }
    }
}

