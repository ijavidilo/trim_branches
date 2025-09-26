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

## 📄 Example Output

```bash
$ ./trim_branches.sh https://github.com/team/project ghp_token123

[INFO] Starting branch synchronization process
[INFO] Git Host: github.com
[INFO] Repository: team/project
[INFO] Main branch detected: master
[INFO] Development branch detected: development
[INFO] Commits in master not in development: 5
[INFO] Creating branch feature/trim_branches from development...
[INFO] Rebasing master onto feature/trim_branches...
[INFO] Preserving original commit dates and authorship...
[SUCCESS] All conflicts resolved automatically with rebase strategy
[INFO] Pushing branch feature/trim_branches...
[SUCCESS] Pull Request created successfully!
[SUCCESS] URL: https://github.com/team/project/pull/42

=== FINAL SUMMARY ===
Repository: team/project
Main branch: master
Development branch: development  
Feature branch: feature/trim_branches
Commits synchronized: 5
Pull Request: https://github.com/team/project/pull/42
=============================
```

## ✨ Features

- 🎯 **Interactive mode** - User-friendly prompts with validation
- 🔍 **Smart branch detection** - Auto-detects `main`/`master` and `development`/`develop`/`dev`
- ✅ **URL validation** - Validates GitHub URLs and tokens
- 🛡️ **Works with protected branches**
- 🔄 **Automatic conflict resolution**
- 📤 **Creates Pull Request automatically**
- 🌐 **Compatible with GitHub.com and GitHub Enterprise**
- 🧹 **Automatic cleanup of temporary files**
- 🎨 **Colorized output** - Clear visual feedback with final summary
- 📅 **Preserves commit dates** - Maintains original authorship and commit timestamps
- 🔧 **Non-interactive git operations** - Prevents editor prompts during automation
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
5. 🔄 Applies commits from main → temporary branch (preserving original dates)
6. ✅ Resolves conflicts automatically (favoring main branch changes)
7. 📤 Push and creates Pull Request with detailed summary
8. 🎨 Shows colorized final summary with all details
9. 🧹 Cleans up temporary files
```

## 💡 Special Cases

- **Branches without common history**: Handled automatically using merge strategy
- **Conflicts**: Resolved automatically by prioritizing the main branch changes
- **Multiple executions**: Recreates the branch if it already exists
- **Commit history preservation**: Original commit dates and authorship are maintained
- **Large repositories**: Efficient handling with smart branch detection and minimal cloning

## 🔧 Technical Details

### 📅 Commit Date Preservation
The script uses `--committer-date-is-author-date` during rebase operations to ensure:
- ✅ Original commit timestamps are preserved
- ✅ Author information remains intact  
- ✅ Historical timeline is maintained accurately
- ✅ No confusion about when changes were actually made

### 🤖 Automatic Conflict Resolution
When conflicts occur during synchronization:
- Uses `-X theirs` strategy to favor main branch changes
- Automatically resolves file conflicts without manual intervention
- Preserves the intent of main branch updates
- Continues rebase process seamlessly

### 🎨 Enhanced Output
- **Colorized messages**: Info (blue), success (green), warnings (yellow), errors (red)
- **Detailed final summary**: Repository info, branches, commit count, PR link
- **Progress indicators**: Clear status at each step of the process

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