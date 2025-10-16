# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-XX

### Added
- User authentication with Firebase
  - Email/password sign in
  - Email/password sign up
  - User role selection (regular user / trainer)
- User profiles
  - Profile creation with name and bio
  - Avatar upload and display
  - Profile editing
- Notes feature
  - Create personal notes
  - Edit existing notes
  - Delete notes
  - View all user notes

### Technical
- Flutter with BLoC state management
- Clean Architecture with feature-based structure
- Firebase Authentication integration
- Cloud Firestore database
- Firebase Storage for file uploads

### Known Issues
- iOS version not yet implemented
- No offline mode support
- Limited error handling in some flows

[Unreleased]: https://github.com/YOUR_USERNAME/YOUR_REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/YOUR_USERNAME/YOUR_REPO/releases/tag/v1.0.0