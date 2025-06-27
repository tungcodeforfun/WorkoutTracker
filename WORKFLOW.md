# CompanionFit Development Workflow

## Overview

This document outlines the branching strategy, versioning, and release process for CompanionFit.

## Branching Strategy

### Branch Structure

```
main (production)
├── dev (development/integration)
│   ├── feature/feature-name
│   ├── bugfix/bug-description
│   └── hotfix/urgent-fix
```

### Branch Types

#### `main` Branch
- **Purpose**: Production-ready code
- **Protection**: Protected branch, requires PR review
- **Auto-deployment**: Triggers release workflow
- **Testing**: Full test suite must pass

#### `dev` Branch  
- **Purpose**: Integration branch for development
- **Testing**: Automated tests run on every push/PR
- **Merging**: Feature branches merge here first
- **Stability**: Should always be in a working state

#### Feature Branches
- **Naming**: `feature/description-of-feature`
- **Source**: Created from `dev`
- **Lifecycle**: Merge into `dev` via PR, then delete
- **Examples**: 
  - `feature/apple-watch-integration`
  - `feature/healthkit-sync`
  - `feature/new-companion-types`

#### Bugfix Branches
- **Naming**: `bugfix/description-of-bug`
- **Source**: Created from `dev`
- **Purpose**: Fix non-critical bugs
- **Examples**:
  - `bugfix/workout-timer-accuracy`
  - `bugfix/companion-evolution-display`

#### Hotfix Branches
- **Naming**: `hotfix/critical-issue`
- **Source**: Created from `main`
- **Purpose**: Critical production fixes
- **Process**: Merge into both `main` and `dev`

## Development Workflow

### 1. Feature Development

```bash
# Start new feature
git checkout dev
git pull origin dev
git checkout -b feature/your-feature-name

# Work on feature
git add .
git commit -m "Add your feature"
git push origin feature/your-feature-name

# Create PR to dev branch
# PR is reviewed and tested
# Merge into dev
```

### 2. Bug Fixes

```bash
# Start bugfix
git checkout dev
git pull origin dev
git checkout -b bugfix/issue-description

# Fix the issue
git add .
git commit -m "Fix: description of bug fix"
git push origin bugfix/issue-description

# Create PR to dev branch
```

### 3. Release Process

```bash
# When dev is ready for release
git checkout main
git pull origin main
git merge dev

# Push to main (triggers release workflow)
git push origin main
```

## Pull Request Process

### Creating a PR

1. **Use the PR template** (automatically loaded)
2. **Fill out all sections** completely
3. **Link related issues** if applicable
4. **Add reviewers** (at least one)
5. **Ensure tests pass** before requesting review

### PR Requirements

- [ ] All automated tests pass
- [ ] Code review approved
- [ ] Documentation updated (if needed)
- [ ] No merge conflicts
- [ ] PR template completed

### Review Guidelines

**For Reviewers:**
- Check code quality and standards
- Verify test coverage
- Test functionality manually if needed
- Ensure Apple Watch/HealthKit features work
- Validate UI/UX consistency

## Versioning Strategy

### Semantic Versioning (SemVer)

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes or major new features
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Version Examples

- `2.0.0` → `2.0.1`: Bug fix (patch)
- `2.0.1` → `2.1.0`: New feature (minor)
- `2.1.0` → `3.0.0`: Breaking changes (major)

### Release Types

#### Automatic Releases
- Triggered when merging to `main`
- Default: `patch` version bump
- Creates GitHub release with changelog

#### Manual Releases
- Use GitHub Actions `workflow_dispatch`
- Choose version bump type: `major`, `minor`, or `patch`
- Useful for planned releases

## Automated Testing

### Test Triggers

- **Every PR**: Tests run on PR creation/updates
- **Push to dev**: Tests run on direct pushes
- **Push to main**: Full test suite + release tests

### Test Requirements

- All unit tests must pass
- Integration tests must pass
- Build must succeed on iOS Simulator
- No breaking changes in existing APIs

## Release Workflow

### Automatic Process (Main Branch)

1. **Tests Run**: Full test suite on iOS Simulator
2. **Version Bump**: Automatically increment patch version
3. **Changelog Update**: Add new release section
4. **Git Tag**: Create version tag
5. **GitHub Release**: Create release with notes
6. **Notification**: Ready for App Store submission

### Manual Release Process

1. Go to **Actions** tab in GitHub
2. Select **Release** workflow
3. Click **Run workflow**
4. Choose version bump type
5. Release is created automatically

## Environment Setup

### Local Development

```bash
# Clone repository
git clone <repository-url>
cd WorkoutTracker

# Install dependencies (if any)
# Open in Xcode
open WorkoutTracker.xcodeproj

# Create feature branch
git checkout dev
git checkout -b feature/your-feature
```

### Required Tools

- **Xcode 16.0+**: For iOS/watchOS development
- **iOS 15.0+ SDK**: Minimum deployment target
- **Git**: Version control
- **GitHub CLI** (optional): For easier PR management

## Best Practices

### Commit Messages

Use conventional commits format:

```
type(scope): description

feat(watch): add heart rate monitoring
fix(healthkit): resolve sync permission issue
docs(readme): update installation instructions
test(companion): add evolution test cases
```

### Code Quality

- Follow Swift coding conventions
- Add unit tests for new features
- Update documentation for API changes
- Use meaningful variable and function names
- Comment complex logic

### Security

- Never commit API keys or secrets
- Keep HealthKit permissions minimal
- Validate user input
- Use secure storage for sensitive data

## Troubleshooting

### Common Issues

**Tests failing in CI:**
- Check simulator availability
- Verify Xcode version compatibility
- Review test dependencies

**Merge conflicts:**
- Rebase feature branch on latest dev
- Resolve conflicts locally
- Force push to update PR

**Release workflow fails:**
- Check permissions
- Verify version format
- Review changelog syntax

## Contact & Support

For questions about the workflow:
- Create an issue in the repository
- Check existing documentation
- Review PR template guidelines

---

**Last Updated**: 2025-06-27
**Version**: 1.0.0