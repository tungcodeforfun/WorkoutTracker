# CompanionFit 🏋️‍♂️✨

> Transform your workouts into an adventure with your digital training companions!

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Overview

CompanionFit is an innovative iOS fitness app that gamifies your workout experience by pairing you with digital training companions. Each workout earns XP that helps your companions grow stronger and evolve, creating a motivating and engaging fitness journey.

### Key Features

- 🎮 **Gamified Fitness**: Every rep, set, and workout earns XP for your companions
- 🦸 **Companion System**: Choose from 8 unique starter companions with different elemental types
- 📊 **Comprehensive Tracking**: Log strength training, cardio, flexibility, and sports activities
- 🏆 **Achievement System**: Unlock badges for various fitness milestones
- 📱 **Modern Design**: Beautiful, intuitive interface with dark mode support
- 💾 **Local Storage**: All data stored securely on your device

## Screenshots

*Coming Soon - App Store screenshots will be added here*

## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later (for development)
- Swift 5.5 or later

## Installation

### For Users
*Coming Soon - App Store link*

### For Developers

1. **Clone the repository**
   ```bash
   git clone https://github.com/[username]/CompanionFit.git
   cd CompanionFit
   ```

2. **Open in Xcode**
   ```bash
   open WorkoutTracker.xcodeproj
   ```

3. **Build and run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## Project Structure

```
WorkoutTracker/
├── Models/                 # Data models
│   ├── User.swift         # User profile and data
│   ├── Companion.swift    # Companion creatures
│   ├── Workout.swift      # Workout and exercise models
│   └── ...
├── Views/                 # SwiftUI views
│   ├── ModernOnboardingView.swift
│   ├── ModernDashboardView.swift
│   ├── ModernWorkoutView.swift
│   ├── CompanionListView.swift
│   └── ...
├── ViewModels/           # Business logic
│   └── AppViewModel.swift
├── Design/               # Theme and styling
│   └── Theme.swift
└── ...
```

## Core Components

### Companion System
- **8 Elemental Types**: Flame, Aqua, Nature, Storm, Warrior, Mystic, Earth, Wind
- **Evolution Mechanics**: Companions evolve at specific levels
- **Stat Growth**: HP, Attack, Defense, and Speed increase with levels
- **XP Earning**: Gain experience through workout activities

### Workout Tracking
- **Exercise Types**: Strength, Cardio, Flexibility, Sports, Other
- **Comprehensive Logging**: Sets, reps, weight, duration, distance, notes
- **XP Calculation**: Dynamic XP based on exercise type and performance
- **Real-time Tracking**: Built-in timer and pause functionality

### Achievement System
- **Week Warrior**: Complete 7 workouts
- **Monthly Master**: Complete 30 workouts
- **Evolution Expert**: Evolve your first companion
- **Strong Trainer**: Lift 10,000 kg total
- **Distance Champion**: Run 100 km total

## Getting Started

1. **Create Your Profile**: Set your username and trainer name
2. **Choose Your Starter**: Pick from 8 unique companion types
3. **Start Training**: Log workouts to earn XP for your companion
4. **Watch Them Grow**: Level up and evolve your companions
5. **Unlock Achievements**: Complete challenges to earn badges

## Development

### Architecture
- **MVVM Pattern**: Clear separation of concerns
- **SwiftUI**: Modern, declarative UI framework
- **UserDefaults**: Simple, local data persistence
- **Combine**: Reactive programming for state management

### Code Style
- Swift API Design Guidelines
- Clear, descriptive naming conventions
- Comprehensive documentation
- Modular, reusable components

### Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Privacy

CompanionFit respects your privacy:
- All data is stored locally on your device
- No personal information is transmitted to external servers
- No analytics or tracking services are used
- You have complete control over your fitness data

See our [Privacy Policy](PRIVACY.md) for more details.

## Roadmap

### Version 1.1
- [ ] iCloud sync for cross-device data
- [ ] Apple Health integration
- [ ] Additional companion types
- [ ] Social features (friend challenges)

### Version 1.2
- [ ] Apple Watch companion app
- [ ] Advanced analytics and insights
- [ ] Custom workout programs
- [ ] Achievement sharing

## Support

- **Issues**: Report bugs on [GitHub Issues](https://github.com/[username]/CompanionFit/issues)
- **Questions**: Create a [Discussion](https://github.com/[username]/CompanionFit/discussions)
- **Email**: support@companionfit.app

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- SwiftUI community for inspiration and best practices
- SF Symbols for beautiful iconography
- Beta testers for valuable feedback

---

**Made with ❤️ for fitness enthusiasts who love a good adventure**