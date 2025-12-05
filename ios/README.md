# iOS MovieTinder App

A modern iOS application for movie discovery and recommendations, built with UIKit and following a comprehensive design system.

## Features

- **Splash Screen** - Beautiful animated splash screen with logo and branding
- **Authentication** - Login and registration with secure token storage
- **Design System** - Comprehensive design tokens for consistent UI/UX
- **Network Layer** - Robust API integration with error handling
- **Secure Storage** - Keychain-based token storage

## Project Structure

```
ios/
├── ios/
│   ├── DesignSystem/
│   │   ├── DesignTokens.swift          # Color, typography, spacing tokens
│   │   └── Components/
│   │       ├── Button.swift            # DSButton component
│   │       └── TextField.swift         # DSTextField component
│   ├── Network/
│   │   ├── APIService.swift            # Base API service
│   │   ├── KeychainManager.swift       # Secure token storage
│   │   ├── Models/
│   │   │   └── AuthModels.swift        # Authentication models
│   │   └── Services/
│   │       └── AuthService.swift       # Authentication service
│   ├── ViewControllers/
│   │   ├── SplashViewController.swift  # Splash screen
│   │   ├── LoginViewController.swift   # Login screen
│   │   └── RegisterViewController.swift # Registration screen
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
```

## Design System

The app follows a comprehensive design system with:

- **Color Tokens**: Primary brand colors (#E50914), semantic colors, dark theme support
- **Typography**: Consistent font sizes, weights, and styles
- **Spacing**: 4px base unit system (4, 8, 12, 16, 24, 32, 48, 64, 96)
- **Components**: Reusable button and text field components
- **Animations**: Standard timing and easing curves

## Setup

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- Backend API running (default: `http://localhost:8000`)

### Configuration

1. Open the project in Xcode
2. Update the API base URL in `APIService.swift` if your backend is not on localhost:
   ```swift
   private let baseURL = "http://your-backend-url:8000"
   ```

### Running the App

1. Select your target device or simulator
2. Build and run (⌘R)
3. The app will start with the splash screen

## Authentication Flow

1. **Splash Screen** → Checks authentication status
2. **If not authenticated** → Shows Login screen
3. **Login Screen** → Allows sign in or navigation to Register
4. **Register Screen** → Create new account
5. **After successful auth** → Navigates to main app (to be implemented)

## API Integration

The app integrates with the FastAPI backend:

- **POST /auth/signup** - User registration
- **POST /auth/login** - User login
- **POST /auth/refresh** - Refresh access token
- **GET /auth/me** - Get current user

All tokens are securely stored in the iOS Keychain.

## Key Features

### Security

- Passwords are not auto-generated (user must create their own)
- Secure token storage using Keychain
- Input validation on all forms
- Error handling with user-friendly messages

### User Experience

- Smooth animations and transitions
- Keyboard-aware scrolling
- Loading states with indicators
- Error messages with clear feedback
- Dark theme support

## Next Steps

To complete the app, implement:

- Main home screen with movie listings
- Movie detail views
- Search functionality
- User profile
- Friends system
- Recommendations

## Design System Usage

### Colors

```swift
DesignColors.primary          // Brand red
DesignColors.backgroundPrimary // Dark background
DesignColors.textPrimary      // Primary text color
```

### Typography

```swift
DesignTypography.heading1     // Large heading
DesignTypography.body         // Body text
DesignTypography.caption      // Caption text
```

### Spacing

```swift
DesignSpacing.base            // 16px
DesignSpacing.lg              // 24px
DesignSpacing.xl              // 32px
```

### Components

```swift
let button = DSButton()
button.style = .primary
button.setTitle("Click Me", for: .normal)

let textField = DSTextField()
textField.placeholder = "Enter text"
```

## Notes

- The app uses programmatic UI (no storyboards)
- All network calls use async/await
- Design system follows atomic design principles
- Components are reusable and consistent
