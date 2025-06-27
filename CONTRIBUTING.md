# Contributing to CompanionFit

Thank you for your interest in contributing to CompanionFit! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- **Be respectful**: Treat all contributors with respect and kindness
- **Be inclusive**: Welcome newcomers and people from all backgrounds
- **Be collaborative**: Work together constructively and share knowledge
- **Be patient**: Remember that everyone has different skill levels and experience

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue template** when available
3. **Provide detailed information** including:
   - iOS version and device model
   - Steps to reproduce the issue
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

We welcome feature suggestions! Please:

1. **Check existing feature requests** first
2. **Create a detailed proposal** including:
   - Clear description of the feature
   - Use cases and benefits
   - Potential implementation approach
   - Mock-ups or wireframes if applicable

### Pull Requests

#### Before You Start

1. **Fork the repository** and create a feature branch
2. **Check existing pull requests** to avoid duplicate work
3. **Discuss large changes** in an issue first

#### Development Setup

1. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/CompanionFit.git
   cd CompanionFit
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Open in Xcode**
   ```bash
   open WorkoutTracker.xcodeproj
   ```

#### Code Standards

##### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use **camelCase** for variables and functions
- Use **PascalCase** for types and protocols
- Use **descriptive names** that clearly indicate purpose

```swift
// Good
func calculateWorkoutExperience(for exercises: [Exercise]) -> Int

// Avoid
func calcXP(ex: [Exercise]) -> Int
```

##### SwiftUI Best Practices

- **Prefer computed properties** for view logic
- **Extract complex views** into separate components
- **Use @State sparingly** - prefer ViewModels for complex state
- **Follow MVVM pattern** for architecture

```swift
// Good
struct WorkoutCard: View {
    let workout: Workout
    
    var formattedDuration: String {
        // Computed property for view logic
    }
    
    var body: some View {
        // Simple, focused view
    }
}
```

##### Code Organization

- **Group related functionality** in extensions
- **Use MARK comments** for navigation
- **Keep files focused** - one main concept per file
- **Document public APIs** with doc comments

```swift
// MARK: - View Components
extension WorkoutView {
    private var headerSection: some View {
        // Implementation
    }
}
```

#### Commit Guidelines

Use **conventional commits** format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(companions): add evolution animations
fix(workout): resolve timer pause issue
docs(readme): update installation instructions
```

#### Testing

- **Test your changes** thoroughly on different devices/simulators
- **Verify existing functionality** isn't broken
- **Test edge cases** and error conditions
- **Include unit tests** for new business logic when possible

#### Pull Request Process

1. **Update documentation** if needed
2. **Add screenshots** for UI changes
3. **Write a clear PR description** including:
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Any breaking changes

4. **Link related issues** using keywords:
   ```
   Closes #123
   Fixes #456
   ```

5. **Request review** from maintainers

### Development Guidelines

#### Architecture

CompanionFit follows **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Data structures and business logic
- **Views**: SwiftUI views (presentation layer)
- **ViewModels**: State management and view logic

#### File Structure

```
WorkoutTracker/
├── Models/           # Data models
├── Views/            # SwiftUI views
├── ViewModels/       # Business logic
├── Design/           # Themes and styling
└── Resources/        # Assets, Info.plist, etc.
```

#### State Management

- Use **@StateObject** for ViewModels
- Use **@ObservedObject** for passed-in ViewModels
- Use **@State** for simple, local view state
- Use **@Binding** for two-way data flow

#### Data Persistence

Currently using **UserDefaults** for simplicity:
- All data is stored locally
- No network dependencies
- Easy to backup/restore

Future considerations for Core Data or CloudKit integration.

## Getting Help

- **Check the documentation** in this repository
- **Search existing issues** for similar questions
- **Ask in GitHub Discussions** for general questions
- **Create an issue** for bugs or feature requests

## Recognition

Contributors will be recognized in:
- README.md acknowledgments
- Release notes for significant contributions
- GitHub's contributor statistics

Thank you for helping make CompanionFit better! 🎉