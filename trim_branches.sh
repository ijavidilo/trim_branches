#!/bin/bash

# Git Branch Synchronization Script
# Script to sync master/main commits onto development branch when both are protected
# Creates feature branch from development and rebases master/main to maintain coherent history
# 
# Version: 1.0.0
# Author: ijavidilo
# License: MIT
# 
# Usage: ./trim_branches.sh <repository_url> <personal_access_token> [branch_name]

set -e  # Exit on any error

# Script version
VERSION="1.0.0"

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
    echo "Usage: $0 <repository_url> <personal_access_token> [feature_branch_name] [git_user_name] [git_user_email]"
    echo ""
    echo "Parameters:"
    echo "  repository_url        Git repository URL (supports GitHub.com and GitHub Enterprise)"
    echo "  personal_access_token Personal Access Token for authentication"
    echo "  feature_branch_name   Feature branch name (optional, default: feature/trim_branches)"
    echo "  git_user_name         Git user name (optional, uses global git config if not provided)"
    echo "  git_user_email        Git user email (optional, uses global git config if not provided)"
    echo ""
    echo "Options:"
    echo "  --help, -h            Show this help message"
    echo "  --version, -v         Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/owner/repo.git ghp_xxxxxxxxxxxx"
    echo "  $0 https://github.enterprise.com/owner/repo.git ghp_xxxxxxxxxxxx feature/sync-branches"
    echo "  $0 https://github.enterprise.com/owner/repo.git ghp_xxxxxxxxxxxx feature/sync-branches \"John Doe\" \"john.doe@company.com\""
}

# Handle special arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --version|-v)
        show_version
        exit 0
        ;;
esac

# Verify parameters
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

# Extract repository information
REPO_NAME=$(basename "$REPO_URL" .git)
# Extract host, owner and full name from any git URL
GIT_HOST=$(echo "$REPO_URL" | sed -n 's|.*://||p' | sed 's|/.*||')
REPO_PATH=$(echo "$REPO_URL" | sed -n 's|.*://[^/]*/||p' | sed 's|\.git$||')
REPO_OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
REPO_FULL_NAME="$REPO_PATH"

print_info "Starting branch synchronization process"
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

# Detect main branch (master or main)
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

# Verify development branch exists
if ! git show-ref --verify --quiet refs/remotes/origin/development; then
    print_error "Branch 'development' does not exist in the repository"
    exit 1
fi

# Fetch all branches
print_info "Fetching all branches..."
git fetch --all

# Check for differences between main/master and development
print_info "Checking differences between $MAIN_BRANCH and development..."
COMMITS_AHEAD=$(git rev-list --count origin/development..origin/$MAIN_BRANCH)
COMMITS_BEHIND=$(git rev-list --count origin/$MAIN_BRANCH..origin/development)

print_info "Commits in $MAIN_BRANCH not in development: $COMMITS_AHEAD"
print_info "Commits in development not in $MAIN_BRANCH: $COMMITS_BEHIND"

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
print_info "Creating branch $FEATURE_BRANCH from development..."
git checkout -b "$FEATURE_BRANCH" "origin/development"

# Check if branches have common history
print_info "Checking if branches have common history..."
MERGE_BASE=$(git merge-base "origin/$MAIN_BRANCH" "origin/development" 2>/dev/null || echo "")

if [[ -z "$MERGE_BASE" ]]; then
    SYNC_STRATEGY="Merge (unrelated histories)"
    print_warning "Branches have no common history. Using merge strategy with --allow-unrelated-histories..."
    print_info "Merging $MAIN_BRANCH into $FEATURE_BRANCH..."
    
    # Use merge instead of rebase for unrelated histories
    if ! git merge -X theirs "origin/$MAIN_BRANCH" --allow-unrelated-histories -m "Merge $MAIN_BRANCH into $FEATURE_BRANCH (unrelated histories)"; then
        print_warning "Merge failed with conflicts. Attempting to resolve automatically..."
        
        # Resolve conflicts by accepting all changes from master/main
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

    # Try rebase with automatic conflict resolution
    if ! git rebase -X theirs "origin/$MAIN_BRANCH"; then
        print_warning "Rebase failed with conflicts. Attempting to resolve automatically..."
        
        # If rebase fails, resolve all conflicts by keeping the incoming changes (from master/main)
        while [ -f .git/rebase-apply/applying ] || [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; do
            print_info "Resolving conflicts by accepting all changes from $MAIN_BRANCH..."
            
            # Get list of conflict files
            CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
            
            if [ -n "$CONFLICT_FILES" ]; then
                # For each conflict file, accept the incoming version (from master/main)
                echo "$CONFLICT_FILES" | while read -r file; do
                    print_info "Resolving conflict in: $file"
                    git checkout --theirs "$file"
                    git add "$file"
                done
            fi
            
            # Continue rebase
            if ! git rebase --continue; then
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
    PR_TITLE="Sync $COMMITS_AHEAD commit from $MAIN_BRANCH to development"
else
    PR_TITLE="Sync $COMMITS_AHEAD commits from $MAIN_BRANCH to development"
fi

PR_BODY="This PR synchronizes $COMMITS_AHEAD commits from $MAIN_BRANCH to development branch.\\n\\nStrategy: $SYNC_STRATEGY\\nFeature branch: $FEATURE_BRANCH\\n\\nGenerated automatically by trim_branches.sh script."

# Create PR with curl - following GitHub API docs exactly
API_URL="$API_BASE_URL/repos/$REPO_FULL_NAME/pulls"
print_info "API URL: $API_URL"
print_info "Creating PR from $FEATURE_BRANCH to development..."

# Create JSON payload exactly as specified in GitHub Enterprise docs
PR_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  "$API_URL" \
  -d "{\"title\":\"$PR_TITLE\",\"body\":\"$PR_BODY\",\"head\":\"$FEATURE_BRANCH\",\"base\":\"development\"}")

# Extract HTTP status code
HTTP_CODE=$(echo "$PR_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
PR_RESPONSE_BODY=$(echo "$PR_RESPONSE" | sed '/HTTP_CODE:/d')

print_info "HTTP Status Code: $HTTP_CODE"

# Verify if PR was created successfully
if [ "$HTTP_CODE" = "201" ]; then
    PR_URL=$(echo "$PR_RESPONSE_BODY" | grep -o '"html_url": "[^"]*"' | cut -d'"' -f4)
    print_success "Pull Request created successfully!"
    print_success "URL: $PR_URL"
    
    # Get PR number
    PR_NUMBER=$(echo "$PR_RESPONSE_BODY" | grep -o '"number": [0-9]*' | cut -d' ' -f2)
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

# Show final summary
echo ""
echo "=== FINAL SUMMARY ==="
echo "Repository: $REPO_FULL_NAME"
echo "Main branch: $MAIN_BRANCH"
echo "Feature branch: $FEATURE_BRANCH"
echo "Commits synchronized: $COMMITS_AHEAD"
echo "Pull Request: $PR_URL"
echo "====================="