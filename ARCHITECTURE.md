# CompanionFit Architecture Documentation

## Overview

CompanionFit follows a **Model-View-ViewModel (MVVM)** architecture pattern using SwiftUI and Combine frameworks. The app is designed with privacy-first principles, storing all data locally on the device.

## Architecture Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     Views       │    │   ViewModels     │    │     Models      │
│   (SwiftUI)     │◄──►│   (ObservableObject) │◄──►│  (Data Layer)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                        │                        │
        │                        ▼                        ▼
        │              ┌──────────────────┐    ┌─────────────────┐
        │              │     Combine      │    │   UserDefaults  │
        │              │  (Reactive Data) │    │ (Local Storage) │
        └──────────────┼──────────────────┘    └─────────────────┘
                       │
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

### 2. ViewModels (Business Logic)

#### AppViewModel.swift
- **Type**: `@MainActor class` conforming to `ObservableObject`
- **Purpose**: Central state management for the entire app
- **Key Responsibilities**:
  - User session management
  - Companion operations (selection, evolution, management)
  - Workout completion processing
  - Data persistence coordination
  - Navigation state management

**Key Methods**:
```swift
func createUser(username: String, trainerName: String)
func selectStarterCompanion(_ companion: Companion)
func completeWorkout(_ workout: Workout)
func setActiveCompanion(_ companionId: UUID)
func updateCompanionNickname(_ companionId: UUID, nickname: String)
```

### 3. Views (Presentation Layer)

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

### 4. Design System (Theme.swift)

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

### 1. User Actions
```
User Interaction → SwiftUI View → ViewModel Method → Model Update → UserDefaults Save
```

### 2. State Updates
```
Model Change → ViewModel @Published Property → SwiftUI View Auto-Update
```

### 3. Workout Completion Flow
```
Complete Workout → Calculate XP → Update Companion Stats → Check Evolution → 
Update User Stats → Check Achievements → Save to UserDefaults → UI Refresh
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

### Local Storage Strategy
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

### Benefits of UserDefaults
- **Simplicity**: No complex database setup
- **Privacy**: All data stays on device
- **Reliability**: iOS handles backup/restore automatically
- **Performance**: Fast access for small datasets

### Limitations
- **Size**: Limited to reasonable data sizes
- **Querying**: No complex queries or relationships
- **Concurrency**: Single-threaded access

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
- **Local Only**: No network transmission of user data
- **iOS Sandbox**: App data protected by iOS security model
- **No Analytics**: Zero tracking or external data collection

### 2. Code Security
- **Input Validation**: User input sanitization
- **Error Handling**: Graceful failure modes
- **No Secrets**: No API keys or sensitive data in code

## Testing Strategy

### 1. Unit Testing (Planned)
- Model logic testing
- XP calculation verification
- Achievement trigger testing
- Data persistence testing

### 2. UI Testing (Planned)
- Critical user flows
- Accessibility testing
- Performance testing
- Device compatibility

### 3. Manual Testing
- Comprehensive device testing
- Edge case scenarios
- User experience validation
- Performance profiling

## Future Architecture Considerations

### 1. Scaling Considerations
- **Core Data**: For more complex data relationships
- **CloudKit**: For cross-device synchronization
- **Background Processing**: For advanced analytics

### 2. Modularity
- **Feature Modules**: Separate frameworks for major features
- **Dependency Injection**: More formal DI container
- **Protocol-Oriented**: Increased use of protocols for testability

### 3. Advanced Features
- **Combine Publishers**: More sophisticated reactive patterns
- **SwiftUI Navigation**: Adoption of newer navigation APIs
- **Widgets**: iOS widget support for quick stats

## Development Guidelines

### 1. Code Organization
```
Models/
├── Core/           # Core data models
├── Extensions/     # Model extensions
└── Protocols/      # Shared protocols

Views/
├── Onboarding/     # User onboarding flow
├── Dashboard/      # Main dashboard
├── Workout/        # Workout tracking
├── Companions/     # Companion management
├── Profile/        # User profile
└── Shared/         # Reusable components

ViewModels/
├── AppViewModel.swift
└── Extensions/     # ViewModel extensions

Design/
├── Theme.swift     # Design system
├── Components/     # Reusable UI components
└── Modifiers/      # Custom view modifiers
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