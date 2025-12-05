//
//  TextField.swift
//  ios
//
//  Design System - TextField Component
//

import UIKit

class DSTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = DesignColors.backgroundSecondary
        textColor = DesignColors.textPrimary
        font = DesignTypography.body
        layer.cornerRadius = DesignBorder.radiusMD
        layer.borderWidth = DesignBorder.widthThin
        layer.borderColor = DesignColors.borderPrimary.cgColor
        
        // Better padding with proper left/right insets
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSpacing.base, height: 56))
        leftView = leftPaddingView
        leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSpacing.base, height: 56))
        rightView = rightPaddingView
        rightViewMode = .never // Will be set when password toggle is added
        
        // Minimum height for touch target
        heightAnchor.constraint(greaterThanOrEqualToConstant: DesignLayout.touchTargetMinimum).isActive = true
        
        // Placeholder styling
        updatePlaceholder()
        
        // Focus state
        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }
    
    private func updatePlaceholder() {
        guard let placeholder = placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: DesignColors.textTertiary,
                NSAttributedString.Key.font: DesignTypography.body
            ]
        )
    }
    
    override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    @objc private func editingDidBegin() {
        UIView.animate(withDuration: DesignAnimation.durationFast) {
            self.layer.borderColor = DesignColors.primary.cgColor
            self.layer.borderWidth = DesignBorder.widthMedium
        }
    }
    
    @objc private func editingDidEnd() {
        UIView.animate(withDuration: DesignAnimation.durationFast) {
            self.layer.borderColor = DesignColors.borderPrimary.cgColor
            self.layer.borderWidth = DesignBorder.widthThin
        }
    }
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isSecureTextEntry {
                setupPasswordToggle()
            }
        }
    }
    
    private func setupPasswordToggle() {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .selected)
        button.tintColor = DesignColors.textSecondary
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 56)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        rightView = button
        rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isSecureTextEntry.toggle()
        sender.isSelected.toggle()
    }
}

