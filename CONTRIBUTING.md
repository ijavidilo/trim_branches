# Contributing to Git Branch Synchronization Script

First off, thank you for considering contributing to this project! 🎉

## Code of Conduct

This project adheres to a simple code of conduct: be respectful, be constructive, and be collaborative.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check if the issue already exists. When creating a bug report, include:

- **Clear title** and description
- **Steps to reproduce** the behavior
- **Expected vs actual** behavior
- **Environment details** (OS, Git version, Bash version)
- **Log output** (sanitized of any tokens)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear title** and description
- **Use case** for the enhancement
- **Possible implementation** approach (if you have ideas)

### Pull Requests

1. **Fork** the repository
2. **Create** a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make** your changes
4. **Test** your changes thoroughly
5. **Follow** the coding standards
6. **Update** documentation if needed
7. **Commit** with clear messages:
   ```bash
   git commit -m "Add feature: brief description"
   ```
8. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
9. **Open** a Pull Request

## Coding Standards

### Shell Script Guidelines

- **Use bash syntax** (`#!/bin/bash`)
- **Quote variables** to prevent word splitting
- **Use meaningful variable names** (`REPO_URL` not `url`)
- **Add comments** for complex logic
- **Handle errors gracefully** with proper exit codes
- **Use consistent indentation** (2 spaces)

### Example:
```bash
# Good
if [ -n "$VARIABLE" ]; then
  print_info "Processing: $VARIABLE"
fi

# Avoid
if [ -n $VARIABLE ]; then
print_info "Processing: $VARIABLE"
fi
```

### Documentation

- **Update README.md** for user-facing changes
- **Update CHANGELOG.md** following [Keep a Changelog](https://keepachangelog.com/)
- **Add inline comments** for complex functions
- **Include examples** for new features

### Testing

- **Test on multiple platforms** (Windows Git Bash, macOS, Linux)
- **Test with both GitHub.com and GitHub Enterprise**
- **Test error scenarios** (invalid tokens, missing branches, etc.)
- **Verify cleanup** (no leftover temp directories)

## Development Setup

1. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/repository-name.git
   cd repository-name
   ```

2. **Test the script**:
   ```bash
   ./trim_branches.sh --help
   ```

3. **Make changes** and test thoroughly

## Questions?

Feel free to open an issue for any questions about contributing!

## Recognition

Contributors will be acknowledged in the README and release notes.

Thank you for contributing! 🚀