//
//  IconTextField.swift
//  ios
//
//  TextField with Icon Prefix
//

import UIKit

enum TextFieldIcon {
    case envelope
    case person
    case lock
    
    var systemName: String {
        switch self {
        case .envelope: return "envelope"
        case .person: return "person"
        case .lock: return "lock"
        }
    }
}

class IconTextField: DSTextField {
    
    private let iconType: TextFieldIcon?
    private var iconImageView: UIImageView?
    
    override init(frame: CGRect) {
        self.iconType = nil
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        self.iconType = nil
        super.init(coder: coder)
    }
    
    init(icon: TextFieldIcon, placeholder: String) {
        self.iconType = icon
        super.init(frame: .zero)
        self.placeholder = placeholder
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if iconType != nil {
            setupIconIfNeeded()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if iconType != nil {
            setupIconIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup icon if needed
        if iconType != nil {
            setupIconIfNeeded()
        }
        
        // Position icon
        if let iconView = iconImageView {
            let iconSize: CGFloat = 20
            let padding: CGFloat = 16
            let iconX = padding
            let iconY = (bounds.height - iconSize) / 2
            
            iconView.frame = CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize)
        }
    }
    
    private func setupIconIfNeeded() {
        guard let icon = iconType else { return }
        guard iconImageView == nil else { return }
        
        // Create icon image view
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = DesignColors.textSecondary
        iconView.isUserInteractionEnabled = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        iconView.image = UIImage(systemName: icon.systemName, withConfiguration: config)
        
        addSubview(iconView)
        iconImageView = iconView
        
        // Update left padding to make room for icon + spacing
        let iconWidth: CGFloat = 20
        let spacing: CGFloat = 8
        let totalPadding = DesignSpacing.base + iconWidth + spacing
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: totalPadding, height: 56))
        leftPaddingView.isUserInteractionEnabled = false
        leftView = leftPaddingView
        leftViewMode = .always
        
        // Ensure text field can receive input
        isEnabled = true
        isUserInteractionEnabled = true
    }
    
    // Override textRect to account for icon
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if iconImageView != nil {
            rect.origin.x += 8 // Extra spacing after icon
        }
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if iconImageView != nil {
            rect.origin.x += 8 // Extra spacing after icon
        }
        return rect
    }
}
