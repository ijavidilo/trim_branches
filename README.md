# 🚀 Git Branch Sync Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

> **Automatically sync commits from `main`/`master` to `development` when both branches are protected**

## ⚡ Quick Start

```bash
# 1. Download the script
curl -O https://raw.githubusercontent.com/ijavidilo/trim_branches/main/trim_branches.sh
chmod +x trim_branches.sh

# 2. Run with your repository (Interactive mode - NEW!)
./trim_branches.sh -i

# 3. Or run with direct parameters
./trim_branches.sh https://github.com/your-user/your-repo.git ghp_your_token_here
```

**That's it!** The script will automatically create a Pull Request to sync the branches.

---

## 🎯 What does this script do?

**Problem**: You have protected `main` and `development` branches, can't push directly  
**Solution**: Automatically creates a temporary branch and Pull Request

1. 📥 Clones your repository
2. 🔍 Auto-detects main branch (`main` or `master`)
3. 🌿 Auto-detects development branch (`development`, `develop`, or `dev`)
4. 🌱 Creates temporary branch from development
5. 🔄 Syncs commits from main → temporary branch
6. 📤 Push and creates Pull Request automatically
7. 🧹 Cleans up temporary files

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

### 🎯 Interactive Mode (Recommended - NEW!)
```bash
# Interactive mode - asks for URL and token
./trim_branches.sh -i

# Interactive with custom branch
./trim_branches.sh -i feature/my-sync

# Interactive with all options
./trim_branches.sh -i feature/sync "My Name" "my@email.com"
```

### 📝 Direct Parameters Mode
```bash
# Basic syntax
./trim_branches.sh <repo_url> <token>

# Examples
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890 feature/my-sync
./trim_branches.sh https://github.com/my-team/project.git ghp_1234567890 feature/sync "My Name" "my@email.com"
```

### 📋 Other Options
```bash
./trim_branches.sh --help     # Show help
./trim_branches.sh --version  # Show version
```

## ✨ Features

- 🎯 **Interactive mode** - User-friendly prompts (NEW!)
- 🔍 **Smart branch detection** - Auto-detects `main`/`master` and `development`/`develop`/`dev`
- ✅ **URL validation** - Validates GitHub URLs and tokens
- 🛡️ **Works with protected branches**
- 🔄 **Automatic conflict resolution**
- 📤 **Creates Pull Request automatically**
- 🌐 **Compatible with GitHub.com and GitHub Enterprise**
- 🧹 **Automatic cleanup of temporary files**
- 🎨 **Colorized output** - Clear visual feedback
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
2. 🔍 Auto-detects main branch (main/master)
3. 🌿 Auto-detects development branch (development/develop/dev)
4. 🌱 Creates temporary branch from development
5. 🔄 Applies commits from main → temporary branch
6. ✅ Resolves conflicts automatically
7. 📤 Push and creates Pull Request
8. 🧹 Cleans up temporary files
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
[ERROR] Development branch not found (development/develop/dev)
```
**Solution**: Create a development branch:
```bash
git checkout -b development  # or 'develop' or 'dev'
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