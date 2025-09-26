# 🚀 Git Branch Sync Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

> **Automatically sync commits from `main`/`master` to `development` when both branches are protected**

## ⚡ Quick Start

```bash
# 1. Download the script
curl -O https://raw.githubusercontent.com/ijavidilo/trim_branches/main/trim_branches.sh
chmod +x trim_branches.sh

# 2. Run with your repository
./trim_branches.sh https://github.com/your-user/your-repo.git ghp_your_token_here
```

**That's it!** The script will automatically create a Pull Request to sync the branches.

---

## 🎯 What does this script do?

**Problem**: You have protected `main` and `development` branches, can't push directly  
**Solution**: Automatically creates a temporary branch and Pull Request

1. 📥 Clones your repository
2. 🔍 Detects if you use `main` or `master`
3. 🌿 Creates temporary branch from `development`
4. 🔄 Syncs commits from `main` → temporary branch
5. 📤 Push and creates Pull Request automatically
6. 🧹 Cleans up temporary files

## 📋 Requirements

- ✅ **Git** installed and configured
- ✅ **Bash** (Git Bash on Windows)
- ✅ **GitHub Token** with repository permissions

## 🔑 Create GitHub Token

1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. "Generate new token (classic)"
3. Select: ☑️ **repo** (Full control)
4. Copy the token (starts with `ghp_`)

## 💡 Usage

### Basic syntax:
```bash
./trim_branches.sh <repo_url> <token>
```

### Examples:

```bash
# Basic (recommended)
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890

# With custom branch
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890 feature/my-sync

# With specific configuration
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890 feature/sync "My Name" "my@email.com"
```

## ✨ Features

- 🔍 **Automatic detection** of `main` or `master`
- 🛡️ **Works with protected branches**
- 🔄 **Automatic conflict resolution**
- 📤 **Creates Pull Request automatically**
- 🌐 **Compatible with GitHub.com and GitHub Enterprise**
- 🧹 **Automatic cleanup of temporary files**
- ✅ **Cross-platform** (Windows, macOS, Linux)

## 🔧 Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `repository_url` | ✅ | Repository URL | `https://github.com/team/project.git` |
| `personal_access_token` | ✅ | Authentication token | `ghp_xxxxxxxxxxxx` |
| `feature_branch_name` | ❌ | Temporary branch name | `feature/sync-branches` |
| `git_user_name` | ❌ | Name for commits | `"John Doe"` |
| `git_user_email` | ❌ | Email for commits | `"john@company.com"` |

> **Note**: If you don't specify name/email, it uses your global Git configuration

## 📊 How it works?

```
1. 📥 Clones repository
2. 🔍 Detects main branch (main/master)
3. 🌿 Creates branch from development
4. 🔄 Applies commits from main → temporary branch
5. ✅ Resolves conflicts automatically
6. 📤 Push and creates Pull Request
7. 🧹 Cleans up temporary files
```

## 💡 Special Cases

- **Branches without common history**: Handled automatically
- **Conflicts**: Resolved by prioritizing the main branch
- **Multiple executions**: Recreates the branch if it already exists

## 🚨 Common Errors

### 🔐 Error 401 - Invalid token
```bash
[ERROR] API connectivity test failed (HTTP 401)
```
**Solution**: Regenerate your token at GitHub → Settings → Tokens

### 🚫 Error 403 - No permissions
```bash
[ERROR] Authentication failed or insufficient permissions
```
**Solutions**:
- Make sure to check ☑️ **repo** when creating the token
- For GitHub Enterprise: authorize SSO at Settings → Applications

### 🔍 Error 404 - Repository not found
```bash
[ERROR] Repository not found
```
**Solutions**:
- Verify the repository URL is correct
- Confirm you have access to the repository

### 🌿 Development branch doesn't exist
```bash
[INFO] Branch 'development' does not exist
```
**Solution**: Create the development branch:
```bash
git checkout -b development
git push origin development
```

## 📞 Help

Problems? [Open an issue](https://github.com/ijavidilo/trim_branches/issues) with:
- The command you executed
- The complete error you see
- Your operating system

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---
**⭐ If it helped you, give the repo a star!**  
**Created by**: [ijavidilo](https://github.com/ijavidilo)