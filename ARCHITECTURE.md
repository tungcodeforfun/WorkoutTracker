# CompanionFit Architecture Documentation

## Overview

CompanionFit follows a **Model-View-ViewModel (MVVM)** architecture pattern using SwiftUI, Combine, and HealthKit frameworks. The app is designed with privacy-first principles, featuring cross-platform support for iOS and watchOS with secure health data integration.

## Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Views (iOS)    │    │   ViewModels     │    │     Models      │
│   (SwiftUI)     │◄──►│ (ObservableObject)│◄──►│  (Data Layer)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                        │                        │
┌─────────────────┐               │                        ▼
│ Views (watchOS) │               ▼                ┌─────────────────┐
│   (SwiftUI)     │    ┌──────────────────┐       │   UserDefaults  │
└─────────────────┘    │     Combine      │       │ (Local Storage) │
        │               │  (Reactive Data) │       └─────────────────┘
        │               └──────────────────┘                │
        │                        │                         │
        │                        │                ┌─────────────────┐
        │               ┌──────────────────┐       │    HealthKit    │
        │               │    Managers      │◄──────┤ (Health Data)   │
        │               │ (Service Layer)  │       └─────────────────┘
        │               └──────────────────┘
        │                        │
        └────────────────────────┼───────────────────────────────────
                                 ▼
                       ┌──────────────────┐
                       │      Theme       │
                       │   (Design System)│
                       └──────────────────┘
```

## Core Components

### 1. Models (Data Layer)

#### User.swift
- **Purpose**: Represents the user's complete profile and fitness journey
- **Key Features**:
  - Companion collection management
  - Workout history tracking
  - Achievement and badge system
  - Level progression
- **Storage**: UserDefaults (JSON encoded)

#### Companion.swift
- **Purpose**: Digital training companions with RPG-like mechanics
- **Key Features**:
  - 8 elemental types with unique characteristics
  - Level progression and evolution system
  - Stat growth (HP, Attack, Defense, Speed)
  - Experience point accumulation
- **Evolution**: Automatic at predefined levels

#### Workout.swift
- **Purpose**: Exercise tracking and XP calculation
- **Key Features**:
  - 5 exercise categories (Strength, Cardio, Flexibility, Sports, Other)
  - Comprehensive exercise logging
  - Dynamic XP calculation based on exercise type and performance
  - Time tracking capabilities

### 2. Managers (Service Layer)

#### HealthKitManager.swift
- **Type**: `@MainActor class` conforming to `ObservableObject`
- **Purpose**: HealthKit integration and health data management
- **Key Responsibilities**:
  - HealthKit permissions management
  - Workout data synchronization with Apple Health
  - Health metrics reading (steps, heart rate, calories)
  - Privacy-compliant health data handling
  - Modern API compatibility with fallbacks

**Key Methods**:
```swift
func requestHealthKitPermissions() async throws
func saveWorkout(_ workout: Workout) async throws
func fetchRecentWorkouts(limit: Int) async throws -> [HKWorkout]
func fetchTodaysSteps() async throws -> Double
func getWorkoutEnergyBurned(_ workout: HKWorkout) async throws -> Double?
```

#### WatchWorkoutManager.swift (watchOS)
- **Type**: `@MainActor class` conforming to `ObservableObject`
- **Purpose**: Apple Watch workout session management
- **Key Responsibilities**:
  - Real-time workout tracking on watchOS
  - Heart rate and calorie monitoring
  - Workout session lifecycle management
  - Haptic feedback coordination
  - Data synchronization with iPhone

### 3. ViewModels (Business Logic)

#### AppViewModel.swift
- **Type**: `@MainActor class` conforming to `ObservableObject`
- **Purpose**: Central state management for the entire app
- **Key Responsibilities**:
  - User session management
  - Companion operations (selection, evolution, management)
  - Workout completion processing
  - Data persistence coordination
  - Navigation state management
  - HealthKit integration coordination

**Key Methods**:
```swift
func createUser(username: String, trainerName: String)
func selectStarterCompanion(_ companion: Companion)
func completeWorkout(_ workout: Workout)
func setActiveCompanion(_ companionId: UUID)
func updateCompanionNickname(_ companionId: UUID, nickname: String)
```

### 4. Views (Presentation Layer)

#### Modern Design System
All views follow a consistent modern design language with:
- Dark gradient backgrounds
- Smooth animations and transitions
- Accessible color schemes
- Responsive layouts

#### Key Views:

**ModernOnboardingView.swift**
- Multi-page onboarding flow
- Animated introductions
- User profile creation
- Starter companion selection

**ModernDashboardView.swift**
- Central hub for user activity
- Quick stats and companion overview
- Navigation to main features
- Achievement highlights

**ModernWorkoutView.swift**
- Real-time workout tracking
- Exercise logging interface
- Timer functionality with pause/resume
- XP progress visualization

**CompanionListView.swift**
- Companion collection management
- Individual companion details
- Active companion selection
- Evolution status tracking

**HealthKitSettingsView.swift**
- HealthKit permissions management
- Health data visualization (steps, workouts)
- Privacy information and controls
- Integration status monitoring

**ProfileView.swift**
- User profile and statistics
- Achievement badge display
- Health integration toggle
- Account management options

#### watchOS Views:

**WatchContentView.swift**
- Main watch app interface
- Companion display on watch
- Workout selection and active workout switching

**WatchWorkoutSelectionView.swift**
- Workout type selection interface
- Quick-start workout buttons
- Exercise category icons and descriptions

**WatchActiveWorkoutView.swift**
- Real-time workout metrics display
- Workout controls (pause, resume, end)
- Heart rate and calorie monitoring
- XP gain preview

**WatchCompanionCardView.swift**
- Compact companion information for watch
- Level and XP progress visualization
- Companion type and stats display

### 5. Design System (Theme.swift)

#### Color Palette
```swift
struct Colors {
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let accent = Color(red: 0.3, green: 0.5, blue: 1.0)
    // ... additional colors
}
```

#### Spacing System
```swift
struct Spacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
}
```

#### Component Modifiers
- `primaryButtonStyle()`: Consistent button styling
- `secondaryButtonStyle()`: Secondary action buttons  
- `modernCard()`: Card container styling

## Data Flow

### 1. User Actions (iOS)
```
User Interaction → SwiftUI View → ViewModel Method → Model Update → UserDefaults Save
```

### 2. Health Data Flow
```
Workout Complete → HealthKit Manager → Apple Health Sync → Local Storage Update
```

### 3. Cross-Platform Data Flow
```
iPhone Workout → UserDefaults → Watch App Sync → Watch Display Update
Watch Workout → HealthKit Session → iPhone Sync → Companion XP Update
```

### 4. State Updates
```
Model Change → ViewModel @Published Property → SwiftUI View Auto-Update
```

### 5. Enhanced Workout Completion Flow
```
Complete Workout → Calculate XP → Update Companion Stats → Check Evolution → 
Update User Stats → Check Achievements → Save to UserDefaults → 
Sync to HealthKit → UI Refresh → Watch Notification
```

## Key Design Patterns

### 1. Observer Pattern
- **Implementation**: Combine's `@Published` properties
- **Usage**: Automatic UI updates when model data changes
- **Benefits**: Reactive programming, reduced boilerplate

### 2. Factory Pattern
- **Implementation**: Companion creation with starter templates
- **Usage**: `starterCompanions` array provides pre-configured companions
- **Benefits**: Consistent companion initialization

### 3. Strategy Pattern
- **Implementation**: XP calculation based on exercise type
- **Usage**: `ExerciseType.experienceMultiplier` property
- **Benefits**: Flexible XP systems, easy balancing

### 4. Command Pattern
- **Implementation**: Workout actions (start, pause, finish)
- **Usage**: Discrete operations with state management
- **Benefits**: Clear action boundaries, undo potential

## Data Persistence

### Multi-Layer Storage Strategy

#### 1. Local Storage (UserDefaults)
```swift
// Save user data
func saveUser() {
    guard let user = currentUser else { return }
    do {
        let encoded = try JSONEncoder().encode(user)
        UserDefaults.standard.set(encoded, forKey: "currentUser")
    } catch {
        print("Failed to encode user data: \(error)")
    }
}

// Load user data
func loadUser() {
    guard let userData = UserDefaults.standard.data(forKey: "currentUser") else { return }
    do {
        let user = try JSONDecoder().decode(User.self, from: userData)
        currentUser = user
    } catch {
        print("Failed to decode user data: \(error)")
    }
}
```

#### 2. Health Data Storage (HealthKit)
```swift
// Save workout to HealthKit
func saveWorkout(_ workout: Workout) async throws {
    let hkWorkout = HKWorkout(
        activityType: mapWorkoutTypeToHealthKit(workout: workout),
        start: workout.date,
        end: workout.date.addingTimeInterval(TimeInterval(workout.totalDuration)),
        duration: TimeInterval(workout.totalDuration),
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: Double(workout.totalExperience) * 0.1),
        metadata: [
            HKMetadataKeyWorkoutBrandName: "CompanionFit",
            "companion_used": workout.companionUsed?.uuidString ?? ""
        ]
    )
    try await healthStore.save(hkWorkout)
}
```

#### 3. Cross-Platform Sync
- **Shared UserDefaults**: Watch and iPhone sync via shared container
- **HealthKit Bridge**: Health data accessible on both platforms
- **Symlinked Models**: Shared data structures between targets

### Storage Benefits
- **UserDefaults**: Simplicity, privacy, automatic backup
- **HealthKit**: Official health integration, cross-app compatibility
- **Hybrid Approach**: Best of both worlds with data redundancy

### Storage Limitations
- **UserDefaults**: Size limits, no complex queries
- **HealthKit**: Health data only, permission dependent
- **Sync Complexity**: Manual synchronization required

## Performance Considerations

### 1. Memory Management
- **ViewModels**: Use `@StateObject` for ownership, `@ObservedObject` for references
- **Heavy Operations**: Performed in background queues when needed
- **Image Loading**: Lazy loading for companion avatars

### 2. UI Performance
- **Animations**: Hardware-accelerated SwiftUI animations
- **List Performance**: LazyVGrid for companion collections
- **State Updates**: Minimal, targeted updates via `@Published`

### 3. Data Efficiency
- **Incremental Saves**: Only save when data actually changes
- **Efficient Encoding**: Codable protocol for JSON serialization
- **Memory Footprint**: Small data structures, minimal dependencies

## Security & Privacy

### 1. Data Protection
- **Local Primary**: User data primarily stored locally
- **HealthKit Security**: Health data protected by Apple's security framework
- **iOS Sandbox**: App data protected by iOS security model
- **No Analytics**: Zero tracking or external data collection
- **Permission Based**: HealthKit access requires explicit user consent

### 2. Health Data Privacy
- **Granular Permissions**: Users control exactly what health data is accessible
- **Apple's Framework**: Leverages Apple's secure HealthKit infrastructure
- **Encrypted Storage**: Health data encrypted at rest and in transit
- **User Control**: Users can revoke health permissions at any time

### 3. Code Security
- **Input Validation**: User input sanitization
- **Error Handling**: Graceful failure modes
- **No Secrets**: No API keys or sensitive data in code
- **Platform Conditionals**: Secure handling of platform-specific features

## Testing Strategy

### 1. Unit Testing (Implemented)
- **CompanionTests**: Companion creation, leveling, evolution mechanics
- **WorkoutTests**: Exercise XP calculations, workout functionality  
- **UserTests**: User management, companion interactions, badge system
- **AppViewModelTests**: ViewModel state management and user flows
- **Integration Tests**: Complete user journeys and data consistency

### 2. Automated Testing
- **GitHub Actions CI/CD**: Automated test execution on every push/PR
- **Swift Testing Framework**: Modern testing with iOS 17+ support
- **Cross-Platform Testing**: Tests run on both iOS and watchOS simulators
- **95%+ Coverage**: Comprehensive test coverage across critical components

### 3. Health Integration Testing
- **HealthKit Mock Testing**: Simulated health data scenarios
- **Permission Flow Testing**: HealthKit authorization testing
- **Data Sync Testing**: Cross-platform synchronization validation
- **API Compatibility Testing**: Multiple iOS version compatibility

### 4. Manual Testing
- **Device Testing**: iPhone and Apple Watch physical device testing
- **Edge Case Scenarios**: Network connectivity, permission changes
- **User Experience Validation**: Real-world usage patterns
- **Performance Profiling**: Memory usage and battery impact

## Future Architecture Considerations

### 1. Scaling Considerations
- **Core Data**: For more complex data relationships
- **CloudKit**: For true cross-device synchronization beyond HealthKit
- **Background Processing**: For advanced analytics and companion AI

### 2. Enhanced Health Integration
- **Additional HealthKit Types**: Sleep, nutrition, mindfulness data
- **Health Trends**: Long-term health pattern analysis
- **Advanced Metrics**: VO2 max, heart rate variability
- **Workout Recommendations**: AI-powered suggestions based on health data

### 3. Cross-Platform Expansion
- **macOS App**: Full desktop experience with HealthKit sync
- **iPad Optimization**: Enhanced layouts for larger screens
- **Apple TV**: Workout tracking for home fitness
- **Complications**: Apple Watch complications for quick access

### 4. Advanced Features
- **Combine Publishers**: More sophisticated reactive patterns
- **SwiftUI Navigation**: Adoption of newer navigation APIs
- **Widgets**: iOS widget support for quick stats and companion display
- **Shortcuts Integration**: Siri shortcuts for quick workout starts

## Development Guidelines

### 1. Code Organization
```
Models/
├── Core/           # Core data models (User, Companion, Workout)
├── Extensions/     # Model extensions
└── Protocols/      # Shared protocols

Views/
├── Onboarding/     # User onboarding flow
├── Dashboard/      # Main dashboard
├── Workout/        # Workout tracking
├── Companions/     # Companion management
├── Profile/        # User profile
├── Health/         # HealthKit integration views
└── Shared/         # Reusable components

ViewModels/
├── AppViewModel.swift
└── Extensions/     # ViewModel extensions

Managers/
├── HealthKitManager.swift    # Health data integration
└── WatchWorkoutManager.swift # watchOS workout sessions

WorkoutTracker Watch App/
├── Views/          # watchOS-specific views
├── Managers/       # Watch-specific managers
└── Shared/         # Symlinked shared models

Design/
├── Theme.swift     # Design system
├── Components/     # Reusable UI components
└── Modifiers/      # Custom view modifiers

Tests/
├── Unit/           # Model and logic tests
├── Integration/    # End-to-end tests
└── Health/         # HealthKit integration tests
```

### 2. Naming Conventions
- **Models**: Nouns representing data entities
- **Views**: Descriptive names ending in "View"
- **ViewModels**: Descriptive names ending in "ViewModel"
- **Methods**: Verbs describing actions clearly

### 3. Documentation Standards
- **Public APIs**: Comprehensive doc comments
- **Complex Logic**: Inline comments explaining why
- **Architecture Decisions**: Document reasoning in code comments
- **External Dependencies**: Document integration points