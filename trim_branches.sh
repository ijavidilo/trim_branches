#!/bin/bash

# Git Branch Synchronization Script
# Script to sync main/master commits onto development branch when both are protected
# Creates feature branch from development and rebases main/master to maintain coherent history
# Supports multiple development branch names: development, develop, dev
# 
# Version: 1.2.3
# Author: ijavidilo
# License: MIT
# 
# Usage: ./trim_branches.sh <repository_url> <personal_access_token> [branch_name]

set -e  # Exit on any error

# Configure git to be non-interactive for automated operations
export GIT_EDITOR="true"
export GIT_MERGE_AUTOEDIT="no"

# Script version
VERSION="1.2.3"

# Global variables
INTERACTIVE_MODE=false

# Prevent interactive authentication and GUI prompts
export GIT_TERMINAL_PROMPT=0  # Disable terminal prompts for credentials
export GIT_ASKPASS=""  # Disable askpass program
export SSH_ASKPASS=""  # Disable SSH askpass
export DISPLAY=""  # Disable X11 display to prevent GUI prompts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show version
show_version() {
    echo "Git Branch Synchronization Script v$VERSION"
    echo "Copyright (c) 2025 ijavidilo"
    echo "Licensed under MIT License"
}

# Function to show help
show_help() {
    show_version
    echo ""
    echo "Usage: $0 [OPTIONS] <repository_url> <personal_access_token> [feature_branch_name] [git_user_name] [git_user_email]"
    echo "   or: $0 -i [feature_branch_name] [git_user_name] [git_user_email]"
    echo ""
    echo "Parameters:"
    echo "  repository_url        Git repository URL (supports GitHub.com and GitHub Enterprise)"
    echo "  personal_access_token Personal Access Token for authentication"
    echo "  feature_branch_name   Feature branch name (optional, default: feature/trim_branches)"
    echo "  git_user_name         Git user name (optional, uses global git config if not provided)"
    echo "  git_user_email        Git user email (optional, uses global git config if not provided)"
    echo ""
    echo "Options:"
    echo "  -i, --interactive     Interactive mode - prompts for repository URL and token"
    echo "  --help, -h            Show this help message"
    echo "  --version, -v         Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/owner/repo.git ghp_xxxxxxxxxxxx"
    echo "  $0 -i"
    echo "  $0 --interactive feature/my-branch"
    echo "  $0 https://github.enterprise.com/owner/repo.git ghp_xxxxxxxxxxxx feature/sync-branches \"John Doe\" \"john.doe@company.com\""
}

# Function to validate GitHub repository URL
validate_github_url() {
    local url="$1"
    
    # Check if URL is empty
    if [ -z "$url" ]; then
        return 1
    fi
    
    # Check if URL starts with http:// or https://
    if [[ ! "$url" =~ ^https?:// ]]; then
        print_error "URL must start with http:// or https://"
        return 1
    fi
    
    # Check if URL contains github (github.com or github enterprise)
    if [[ ! "$url" =~ github ]]; then
        print_error "URL must be a GitHub repository (github.com or GitHub Enterprise)"
        return 1
    fi
    
    # Check basic URL structure for repository pattern (with or without .git)
    if [[ ! "$url" =~ /[^/]+/[^/]+(/|\.git)?$ ]]; then
        print_error "URL should follow pattern: https://github.com/owner/repository"
        return 1
    fi
    
    return 0
}

# Function to read input with prompt
read_input() {
    local prompt="$1"
    local is_secret="${2:-false}"
    local value=""
    
    if [ "$is_secret" = "true" ]; then
        echo -n "$prompt >> " >&2
        read -s value
        echo "" >&2  # New line after hidden input
    else
        echo -n "$prompt >> " >&2
        read value
    fi
    
    echo "$value"
}

# Handle special arguments and interactive mode
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --version|-v)
        show_version
        exit 0
        ;;
    -i|--interactive)
        INTERACTIVE_MODE=true
        # Shift parameters to handle optional ones after -i
        shift
        ;;
esac

# Handle parameters based on mode
if [ "$INTERACTIVE_MODE" = true ]; then
    print_info "Interactive mode enabled"
    echo ""
    echo "Please provide the following required information:"
    echo ""
    
    # Get repository URL with validation
    echo "1. Repository URL (supports GitHub.com and GitHub Enterprise)"
    echo "   Examples: https://github.com/owner/repo.git"
    echo "             https://github.enterprise.com/owner/repo.git"
    echo ""
    
    while true; do
        REPO_URL=$(read_input "Enter repository URL")
        if validate_github_url "$REPO_URL"; then
            break
        fi
        echo "" >&2
        print_error "Please enter a valid GitHub repository URL" >&2
        echo "" >&2
    done
    echo ""
    
    # Get Personal Access Token with validation
    echo "2. Personal Access Token for authentication"
    echo "   Note: Your input will be hidden for security"
    echo "   Token needs 'repo' permissions for the repository"
    echo "   GitHub tokens usually start with 'ghp_', 'github_pat_', or 'gho_'"
    echo ""
    
    while true; do
        PAT=$(read_input "Enter Personal Access Token" true)
        if [ -z "$PAT" ]; then
            print_error "Personal Access Token is required" >&2
            echo "" >&2
            continue
        fi
        
        # Basic token format validation
        if [ ${#PAT} -lt 10 ]; then
            print_error "Token seems too short. GitHub tokens are usually longer." >&2
            echo "" >&2
            continue
        fi
        
        break
    done
    
    # Optional parameters from command line after -i
    FEATURE_BRANCH="${1:-feature/trim_branches}"
    GIT_USER_NAME_PARAM="$2"
    GIT_USER_EMAIL_PARAM="$3"
    
    echo ""
else
    # Verify parameters in non-interactive mode
    if [ $# -lt 2 ]; then
        print_error "Missing required parameters"
        show_help
        exit 1
    fi
    
    REPO_URL="$1"
    PAT="$2"
    FEATURE_BRANCH="${3:-feature/trim_branches}"
    GIT_USER_NAME_PARAM="$4"
    GIT_USER_EMAIL_PARAM="$5"
    
    # Validate repository URL in non-interactive mode
    if ! validate_github_url "$REPO_URL"; then
        print_error "Invalid repository URL provided"
        exit 1
    fi
    
    # Basic validation for PAT in non-interactive mode
    if [ -z "$PAT" ] || [ ${#PAT} -lt 10 ]; then
        print_error "Invalid or missing Personal Access Token"
        exit 1
    fi
fi

# Extract repository information
REPO_NAME=$(basename "$REPO_URL" .git)
# Extract host, owner and full name from any git URL
GIT_HOST=$(echo "$REPO_URL" | sed -n 's|.*://||p' | sed 's|/.*||')
REPO_PATH=$(echo "$REPO_URL" | sed -n 's|.*://[^/]*/||p' | sed 's|\.git$||')
REPO_OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
REPO_FULL_NAME="$REPO_PATH"

print_info "Starting branch synchronization process"
if [ "$INTERACTIVE_MODE" = true ]; then
    print_info "Mode: Interactive"
fi
print_info "Git Host: $GIT_HOST"
print_info "Repository: $REPO_FULL_NAME"
print_info "Feature branch: $FEATURE_BRANCH"

# Get script directory and create work directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/${REPO_NAME}_temp"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

print_info "Working directory: $WORK_DIR"

# Cleanup function
cleanup() {
    print_info "Cleaning up working directory..."
    cd "$SCRIPT_DIR"
    rm -rf "$WORK_DIR"
}

# Setup cleanup on exit
trap cleanup EXIT

# Early token validation to prevent interactive login prompts
print_info "Validating Personal Access Token..."
# Build correct API URL for GitHub.com vs GitHub Enterprise
if [ "$GIT_HOST" = "github.com" ]; then
    EARLY_API_URL="https://api.github.com/user"
else
    EARLY_API_URL="https://$GIT_HOST/api/v3/user"
fi

# Test token validity before attempting clone
EARLY_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "Authorization: token $PAT" "$EARLY_API_URL" 2>/dev/null)
EARLY_HTTP_CODE=$(echo "$EARLY_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)

if [ "$EARLY_HTTP_CODE" != "200" ]; then
    print_error "Invalid or expired Personal Access Token (HTTP $EARLY_HTTP_CODE)"
    print_error "This prevents interactive login prompts during clone operation"
    print_error "Please verify your token at: https://$GIT_HOST/settings/tokens"
    exit 1
fi
print_success "Token validation successful"

# Clone repository
print_info "Cloning repository..."
# Build the authenticated URL using the original host
AUTH_URL=$(echo "$REPO_URL" | sed "s|://|://$PAT@|")
git clone "$AUTH_URL" .

# Configure git with provided parameters or user's global settings or defaults
if [ -n "$GIT_USER_NAME_PARAM" ]; then
    GIT_USER_NAME="$GIT_USER_NAME_PARAM"
else
    GIT_USER_NAME=$(git config --global user.name 2>/dev/null || whoami)
fi

if [ -n "$GIT_USER_EMAIL_PARAM" ]; then
    GIT_USER_EMAIL="$GIT_USER_EMAIL_PARAM"
else
    GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "${USER:-$(whoami)}@$(hostname)")
fi

print_info "Configuring git with user: $GIT_USER_NAME <$GIT_USER_EMAIL>"
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

# Configure git to avoid opening editor during automated operations
git config core.editor "true"  # Use 'true' command as editor (non-interactive)
git config merge.ours.driver "true"  # Auto-accept merge strategy
git config advice.mergeConflict false  # Disable merge conflict advice

# Prevent interactive authentication prompts and web browser login
git config credential.helper ""  # Disable credential helper to prevent interactive prompts
git config core.askPass ""  # Disable askpass to prevent password prompts
git config credential.useHttpPath true  # Use HTTP path in credentials
git config http.version HTTP/1.1  # Use HTTP/1.1 for better compatibility

# Detect main branch (main or master)
MAIN_BRANCH=""
if git show-ref --verify --quiet refs/remotes/origin/main; then
    MAIN_BRANCH="main"
elif git show-ref --verify --quiet refs/remotes/origin/master; then
    MAIN_BRANCH="master"  
else
    print_error "Main branch not found (main/master)"
    exit 1
fi

print_info "Main branch detected: $MAIN_BRANCH"

# Detect development branch (development, develop, or dev)
DEV_BRANCH=""
if git show-ref --verify --quiet refs/remotes/origin/development; then
    DEV_BRANCH="development"
elif git show-ref --verify --quiet refs/remotes/origin/develop; then
    DEV_BRANCH="develop"
elif git show-ref --verify --quiet refs/remotes/origin/dev; then
    DEV_BRANCH="dev"
else
    print_error "Development branch not found (development/develop/dev)"
    exit 1
fi

print_info "Development branch detected: $DEV_BRANCH"

# Fetch all branches
print_info "Fetching all branches..."
git fetch --all

# Check for differences between main/master and development
print_info "Checking differences between $MAIN_BRANCH and $DEV_BRANCH..."
COMMITS_AHEAD=$(git rev-list --count origin/$DEV_BRANCH..origin/$MAIN_BRANCH)
COMMITS_BEHIND=$(git rev-list --count origin/$MAIN_BRANCH..origin/$DEV_BRANCH)

print_info "Commits in $MAIN_BRANCH not in $DEV_BRANCH: $COMMITS_AHEAD"
print_info "Commits in $DEV_BRANCH not in $MAIN_BRANCH: $COMMITS_BEHIND"

if [ "$COMMITS_AHEAD" -eq 0 ]; then
    print_success "Branches are already synchronized. Nothing to do."
    exit 0
fi

# Check if feature branch already exists and delete it
if git show-ref --verify --quiet refs/remotes/origin/$FEATURE_BRANCH; then
    print_warning "Branch $FEATURE_BRANCH already exists. Deleting it..."
    git push origin --delete "$FEATURE_BRANCH" || true
fi

# Create and switch to feature branch from development
print_info "Creating branch $FEATURE_BRANCH from $DEV_BRANCH..."
git checkout -b "$FEATURE_BRANCH" "origin/$DEV_BRANCH"

# Check if branches have common history
print_info "Checking if branches have common history..."
MERGE_BASE=$(git merge-base "origin/$MAIN_BRANCH" "origin/$DEV_BRANCH" 2>/dev/null || echo "")

if [[ -z "$MERGE_BASE" ]]; then
    SYNC_STRATEGY="Merge (unrelated histories)"
    print_warning "Branches have no common history. Using merge strategy with --allow-unrelated-histories..."
    print_info "Merging $MAIN_BRANCH into $FEATURE_BRANCH..."
    
    # Use merge instead of rebase for unrelated histories
    if ! git merge -X theirs "origin/$MAIN_BRANCH" --allow-unrelated-histories -m "Merge $MAIN_BRANCH into $FEATURE_BRANCH (unrelated histories)"; then
        print_warning "Merge failed with conflicts. Attempting to resolve automatically..."
        
        # Resolve conflicts by accepting all changes from main/master
        CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
        
        if [ -n "$CONFLICT_FILES" ]; then
            echo "$CONFLICT_FILES" | while read -r file; do
                print_info "Resolving conflict in: $file"
                git checkout --theirs "$file"
                git add "$file"
            done
            
            # Complete the merge
            git commit --no-edit
        else
            print_error "Merge failed but no conflicts found"
            git merge --abort
            exit 1
        fi
        
        print_success "All conflicts resolved automatically with merge strategy"
    fi
else
    SYNC_STRATEGY="Rebase (common history)"
    print_info "Branches have common history. Using rebase strategy..."
    print_info "Rebasing $MAIN_BRANCH onto $FEATURE_BRANCH..."
    print_info "Using 'theirs' strategy to resolve conflicts in favor of $MAIN_BRANCH changes..."
    print_info "Preserving original commit dates and authorship..."

    # Try rebase with automatic conflict resolution (non-interactive)
    # --committer-date-is-author-date preserves original commit dates
    if ! GIT_EDITOR=true git rebase --committer-date-is-author-date -X theirs "origin/$MAIN_BRANCH"; then
        print_warning "Rebase failed with conflicts. Attempting to resolve automatically..."
        
        # If rebase fails, resolve all conflicts by keeping the incoming changes (from main/master)
        while [ -f .git/rebase-apply/applying ] || [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; do
            print_info "Resolving conflicts by accepting all changes from $MAIN_BRANCH..."
            
            # Get list of conflict files
            CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
            
            if [ -n "$CONFLICT_FILES" ]; then
                # For each conflict file, accept the incoming version (from main/master)
                echo "$CONFLICT_FILES" | while read -r file; do
                    print_info "Resolving conflict in: $file"
                    git checkout --theirs "$file"
                    git add "$file"
                done
            fi
            
            # Continue rebase (non-interactive)
            if ! GIT_EDITOR=true git rebase --continue; then
                print_error "Failed to continue rebase even after resolving conflicts"
                git rebase --abort
                exit 1
            fi
        done
        
        print_success "All conflicts resolved automatically with rebase strategy"
    fi
fi

# Push feature branch
print_info "Pushing branch $FEATURE_BRANCH..."
git push -u origin "$FEATURE_BRANCH"

# Test API connectivity first
print_info "Testing API connectivity..."
# Build correct API URL for GitHub.com vs GitHub Enterprise
if [ "$GIT_HOST" = "github.com" ]; then
    API_TEST_URL="https://api.github.com/user"
    API_BASE_URL="https://api.github.com"
else
    API_TEST_URL="https://$GIT_HOST/api/v3/user"
    API_BASE_URL="https://$GIT_HOST/api/v3"
fi

API_TEST_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -H "Authorization: token $PAT" "$API_TEST_URL")
TEST_HTTP_CODE=$(echo "$API_TEST_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)

if [ "$TEST_HTTP_CODE" != "200" ]; then
    print_error "API connectivity test failed (HTTP $TEST_HTTP_CODE)"
    print_error "Cannot reach GitHub API at: $API_TEST_URL"
    print_error "Please verify:"
    print_error "  1. The GitHub server URL is correct"
    print_error "  2. Your Personal Access Token is valid"
    print_error "  3. Network connectivity to the server"
    echo "API Test Response:"
    echo "$API_TEST_RESPONSE" | sed '/HTTP_CODE:/d'
    exit 1
fi

print_success "API connectivity test passed"

# Create Pull Request using GitHub API
print_info "Creating Pull Request..."

# Create simple, clean PR title and body
if [ "$COMMITS_AHEAD" -eq 1 ]; then
    PR_TITLE="Sync $COMMITS_AHEAD commit from $MAIN_BRANCH to $DEV_BRANCH"
else
    PR_TITLE="Sync $COMMITS_AHEAD commits from $MAIN_BRANCH to $DEV_BRANCH"
fi

PR_BODY="This PR synchronizes $COMMITS_AHEAD commits from $MAIN_BRANCH to $DEV_BRANCH branch.\\n\\nStrategy: $SYNC_STRATEGY\\nFeature branch: $FEATURE_BRANCH\\n\\nGenerated automatically by trim_branches.sh script."

# Create PR with curl - following GitHub API docs exactly
API_URL="$API_BASE_URL/repos/$REPO_FULL_NAME/pulls"
print_info "API URL: $API_URL"
print_info "Creating PR from $FEATURE_BRANCH to $DEV_BRANCH..."

# Create JSON payload exactly as specified in GitHub Enterprise docs
PR_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  "$API_URL" \
  -d "{\"title\":\"$PR_TITLE\",\"body\":\"$PR_BODY\",\"head\":\"$FEATURE_BRANCH\",\"base\":\"$DEV_BRANCH\"}")

# Extract HTTP status code
HTTP_CODE=$(echo "$PR_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
PR_RESPONSE_BODY=$(echo "$PR_RESPONSE" | sed '/HTTP_CODE:/d')

print_info "HTTP Status Code: $HTTP_CODE"

# Verify if PR was created successfully
if [ "$HTTP_CODE" = "201" ]; then
    # Extract PR URL more safely
    PR_URL=$(echo "$PR_RESPONSE_BODY" | sed -n 's/.*"html_url": *"\([^"]*\)".*/\1/p' | head -1)
    print_success "Pull Request created successfully!"
    print_success "URL: $PR_URL"
    
    # Get PR number more safely
    PR_NUMBER=$(echo "$PR_RESPONSE_BODY" | sed -n 's/.*"number": *\([0-9]*\).*/\1/p' | head -1)
    print_info "PR Number: #$PR_NUMBER"
    
elif [ "$HTTP_CODE" = "404" ]; then
    print_error "Repository not found or API endpoint incorrect"
    print_error "Verify the repository URL and API access"
    print_error "API URL used: $API_URL"
    echo "API Response:"
    echo "$PR_RESPONSE_BODY"
    exit 1
elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    print_error "Authentication failed or insufficient permissions"
    print_error "Verify your Personal Access Token has the required permissions"
    echo "API Response:"
    echo "$PR_RESPONSE_BODY"
    exit 1
else
    print_error "Error creating Pull Request (HTTP $HTTP_CODE)"
    print_error "API URL: $API_URL"
    echo "Full API Response:"
    echo "$PR_RESPONSE_BODY"
    exit 1
fi

print_success "Process completed successfully!"
print_info "Next steps:"
echo "  1. Review the PR: $PR_URL"
echo "  2. Merge the PR when ready"
echo "  3. Branch $FEATURE_BRANCH can be deleted after merge"

# Show final summary with colors
echo ""
echo -e "${BLUE}=== ${GREEN}FINAL SUMMARY${BLUE} ===${NC}"
echo -e "${BLUE}Repository:${NC} ${YELLOW}$REPO_FULL_NAME${NC}"
echo -e "${BLUE}Main branch:${NC} ${YELLOW}$MAIN_BRANCH${NC}"
echo -e "${BLUE}Development branch:${NC} ${YELLOW}$DEV_BRANCH${NC}"
echo -e "${BLUE}Feature branch:${NC} ${YELLOW}$FEATURE_BRANCH${NC}"
echo -e "${BLUE}Commits synchronized:${NC} ${GREEN}$COMMITS_AHEAD${NC}"
echo -e "${BLUE}Pull Request:${NC} ${GREEN}$PR_URL${NC}"
echo -e "${BLUE}=============================${NC}"

# Ensure cleanup is called explicitly
cleanup