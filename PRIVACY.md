# Privacy Policy

**Effective Date**: January 1, 2025  
**Last Updated**: January 1, 2025

## Introduction

CompanionFit ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our iOS application CompanionFit (the "App").

## TL;DR - The Short Version

- ✅ **All your data stays on your device** - we don't collect or transmit any personal information
- ✅ **No tracking or analytics** - we don't track your usage or behavior
- ✅ **No ads or third parties** - no external services have access to your data
- ✅ **You're in complete control** - you can delete all data at any time

## Information We Don't Collect

CompanionFit is designed with privacy as a core principle. We **do not collect, store, or transmit** any of the following:

### Personal Information
- Names, email addresses, or contact information
- Location data or GPS coordinates
- Device identifiers or advertising IDs
- Biometric data or health information
- Photos or camera access

### Usage Data
- App usage analytics or statistics
- Crash reports or diagnostic data
- User behavior or interaction patterns
- Search queries or preferences

### Technical Data
- IP addresses or network information
- Device specifications or system information
- App performance metrics
- Error logs or debugging information

## Information Stored Locally

All your CompanionFit data is stored **locally on your device only** using iOS's secure UserDefaults system:

### Workout Data
- Exercise logs (type, sets, reps, weight, duration, distance, notes)
- Workout history and timestamps
- Personal fitness statistics and progress

### Companion Data
- Companion names and nicknames
- Experience points and levels
- Evolution status and stats
- Active companion selection

### User Preferences
- Username and trainer name (chosen by you)
- App settings and preferences
- Achievement and badge progress

### Data Security
- All data is protected by iOS's built-in security features
- Data is sandboxed within the app's secure container
- No data leaves your device unless you explicitly export it
- Data is automatically deleted when you uninstall the app

## Third-Party Services

CompanionFit **does not integrate** with any third-party services, including:

- Analytics platforms (Google Analytics, Firebase, etc.)
- Advertising networks
- Social media platforms
- Cloud storage services
- Health or fitness platforms

## Data Sharing

We **do not share, sell, rent, or disclose** any information because:

1. We don't collect any personal information
2. All data remains on your device
3. No external services are integrated
4. No network connections are made for data purposes

## Your Data Rights

Since all data is stored locally on your device, you have complete control:

### Access
- View all your data within the app
- Export workout data (if/when export features are added)

### Modification
- Edit or update any information at any time
- Change companion names, workout logs, or preferences

### Deletion
- Delete individual workouts or companions
- Reset all data through the app's settings
- Uninstall the app to remove all data permanently

### Portability
- All data remains accessible to you at all times
- Future versions may include export functionality

## Children's Privacy

CompanionFit does not knowingly collect any information from children under 13 years of age. Since we don't collect any data at all, the app is safe for users of all ages.

## Changes to This Policy

If we ever change our privacy practices (highly unlikely given our local-only approach), we will:

1. Update this privacy policy
2. Notify users through an app update
3. Provide clear information about any changes
4. Maintain the same privacy-first approach

## International Users

Since CompanionFit doesn't collect or transmit any data:

- GDPR compliance is inherent (no data processing)
- CCPA compliance is automatic (no personal information sale)
- Other privacy regulations are naturally satisfied

## Technical Implementation

For transparency, here's how we ensure your privacy:

### Local Storage Only
```swift
// Data is stored using iOS UserDefaults
UserDefaults.standard.set(workoutData, forKey: "userWorkouts")
```

### No Network Requests
- No API calls to external servers
- No data synchronization
- No cloud backups (unless you use iOS backup)

### No Third-Party SDKs
- No analytics frameworks
- No advertising libraries
- No social media integrations

## Contact Information

If you have questions about this Privacy Policy or our privacy practices:

- **GitHub Issues**: [Create an issue](https://github.com/[username]/CompanionFit/issues)
- **Email**: privacy@companionfit.app *(when available)*

Since we don't collect any data, most privacy concerns are automatically addressed by our design.

## App Store Privacy Labels

When submitted to the App Store, CompanionFit will be labeled as:

- **Data Not Collected**: We don't collect any data linked to your identity
- **Data Not Tracked**: We don't track you across apps or websites
- **No Third-Party Data**: No external services have access to your information

---

**Remember**: Your privacy is not a feature we added—it's fundamental to how CompanionFit is built. Your fitness journey and companion adventures stay completely private to you.