//
//  DesignTokens.swift
//  ios
//
//  Universal Design System - Design Tokens
//

import UIKit

// MARK: - Color Tokens

struct DesignColors {
    // Primary Brand Colors
    static let primary = UIColor(red: 0.898, green: 0.035, blue: 0.078, alpha: 1.0) // #E50914
    static let primaryDark = UIColor(red: 0.753, green: 0.031, blue: 0.067, alpha: 1.0)
    static let primaryLight = UIColor(red: 0.922, green: 0.322, blue: 0.353, alpha: 1.0)
    
    // Accent Colors
    static let accent = UIColor(red: 0.961, green: 0.651, blue: 0.137, alpha: 1.0) // #F5A623
    static let accentDark = UIColor(red: 0.804, green: 0.545, blue: 0.114, alpha: 1.0)
    
    // Semantic Colors
    static let success = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0) // #4CAF50
    static let warning = UIColor(red: 1.0, green: 0.757, blue: 0.027, alpha: 1.0) // #FFC107
    static let error = UIColor(red: 0.956, green: 0.262, blue: 0.212, alpha: 1.0) // #F44336
    static let info = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0) // #2196F3
    
    // Dark Theme Colors
    static let backgroundPrimary = UIColor(red: 0.059, green: 0.059, blue: 0.059, alpha: 1.0) // #0F0F0F
    static let backgroundSecondary = UIColor(red: 0.129, green: 0.129, blue: 0.129, alpha: 1.0) // #212121
    static let backgroundTertiary = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0) // #303030
    
    // Text Colors
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(red: 0.737, green: 0.737, blue: 0.737, alpha: 1.0) // #BCBCBC
    static let textTertiary = UIColor(red: 0.549, green: 0.549, blue: 0.549, alpha: 1.0) // #8C8C8C
    static let textDisabled = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    
    // Border Colors
    static let borderPrimary = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    static let borderSecondary = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
    
    // Overlay
    static let overlay = UIColor.black.withAlphaComponent(0.7)
    static let overlayLight = UIColor.black.withAlphaComponent(0.4)
}

// MARK: - Typography Tokens

struct DesignTypography {
    // Font Sizes (using system font with dynamic sizing)
    static let fontSizeXS: CGFloat = 12
    static let fontSizeSM: CGFloat = 14
    static let fontSizeBase: CGFloat = 16
    static let fontSizeLG: CGFloat = 18
    static let fontSizeXL: CGFloat = 20
    static let fontSize2XL: CGFloat = 24
    static let fontSize3XL: CGFloat = 30
    static let fontSize4XL: CGFloat = 36
    static let fontSize5XL: CGFloat = 48
    
    // Font Weights
    static let weightLight = UIFont.Weight.light
    static let weightRegular = UIFont.Weight.regular
    static let weightMedium = UIFont.Weight.medium
    static let weightSemibold = UIFont.Weight.semibold
    static let weightBold = UIFont.Weight.bold
    
    // Font Families
    static func systemFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    // Typography Styles
    static var heading1: UIFont {
        systemFont(size: fontSize4XL, weight: weightBold)
    }
    
    static var heading2: UIFont {
        systemFont(size: fontSize3XL, weight: weightBold)
    }
    
    static var heading3: UIFont {
        systemFont(size: fontSize2XL, weight: weightSemibold)
    }
    
    static var body: UIFont {
        systemFont(size: fontSizeBase, weight: weightRegular)
    }
    
    static var bodyBold: UIFont {
        systemFont(size: fontSizeBase, weight: weightSemibold)
    }
    
    static var caption: UIFont {
        systemFont(size: fontSizeSM, weight: weightRegular)
    }
    
    static var label: UIFont {
        systemFont(size: fontSizeSM, weight: weightMedium)
    }
}

// MARK: - Spacing Tokens

struct DesignSpacing {
    // Base unit: 4px
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    static let huge: CGFloat = 96
}

// MARK: - Border & Radius Tokens

struct DesignBorder {
    static let radiusXS: CGFloat = 4
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24
    static let radiusFull: CGFloat = 9999
    
    static let widthThin: CGFloat = 1
    static let widthMedium: CGFloat = 2
    static let widthThick: CGFloat = 4
}

// MARK: - Shadow Tokens

struct DesignShadow {
    static func shadow(for elevation: Elevation) -> (color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        switch elevation {
        case .none:
            return (.clear, .zero, 0, 0)
        case .low:
            return (.black, CGSize(width: 0, height: 2), 4, 0.1)
        case .medium:
            return (.black, CGSize(width: 0, height: 4), 8, 0.15)
        case .high:
            return (.black, CGSize(width: 0, height: 8), 16, 0.2)
        }
    }
    
    enum Elevation {
        case none
        case low
        case medium
        case high
    }
}

// MARK: - Animation Tokens

struct DesignAnimation {
    static let durationFast: TimeInterval = 0.15
    static let durationNormal: TimeInterval = 0.3
    static let durationSlow: TimeInterval = 0.5
    
    static let easingStandard = UIView.AnimationOptions.curveEaseInOut
    static let easingDecelerate = UIView.AnimationOptions.curveEaseOut
    static let easingAccelerate = UIView.AnimationOptions.curveEaseIn
}

// MARK: - Layout Tokens

struct DesignLayout {
    // Touch Targets
    static let touchTargetMinimum: CGFloat = 44
    
    // Container Widths
    static let containerMaxWidth: CGFloat = 428
    static let cardPadding: CGFloat = DesignSpacing.base
    static let sectionMargin: CGFloat = DesignSpacing.lg
    
    // Aspect Ratios
    static let posterAspectRatio: CGFloat = 2.0 / 3.0 // 2:3
    static let thumbnailAspectRatio: CGFloat = 16.0 / 9.0 // 16:9
}

