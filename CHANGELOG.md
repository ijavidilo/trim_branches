# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-26

### Added
- Initial release of Git Branch Synchronization Script
- Automatic branch detection for `master` and `main` branches
- Support for GitHub.com and GitHub Enterprise Server
- Automatic conflict resolution with configurable strategies
- Pull Request creation via GitHub API v3
- Comprehensive error handling and logging
- Support for protected branch workflows
- Cross-platform compatibility (Windows, macOS, Linux)
- Automatic cleanup of temporary working directories

### Features
- **Branch Detection**: Automatically detects whether repository uses `master` or `main`
- **Enterprise Support**: Full compatibility with GitHub Enterprise Server 3.14+
- **Conflict Resolution**: Automatic resolution prioritizing main branch changes
- **API Integration**: Creates Pull Requests using official GitHub API
- **Error Handling**: Comprehensive error messages and troubleshooting guidance
- **Security**: Secure token handling with no token exposure in logs

### Documentation
- Complete README with usage examples
- Troubleshooting guide
- Prerequisites and setup instructions
- Cross-platform compatibility notes

## [Unreleased]

### Planned
- Support for custom conflict resolution strategies
- Integration with GitHub Actions
- Support for multiple target branches
- Enhanced logging with different verbosity levels