#!/bin/bash

# Version calculation script for Terraform projects
# This script calculates the next version based on existing GitHub releases

set -e

# Function to get the latest version from GitHub releases
get_latest_version() {
    # Get all tags sorted by version
    latest_tag=$(git tag --sort=-version:refname | head -n 1)
    
    if [ -z "$latest_tag" ]; then
        echo "0.1.0"
    else
        echo "$latest_tag"
    fi
}

# Function to calculate next version based on conventional commits
calculate_next_version() {
    local current_version="$1"
    local commit_type="$2"
    
    # Parse current version
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    major="${VERSION_PARTS[0]}"
    minor="${VERSION_PARTS[1]}"
    patch="${VERSION_PARTS[2]}"
    
    case "$commit_type" in
        "feat"|"feature")
            # Bump minor version for new features
            minor=$((minor + 1))
            patch=0
            ;;
        "fix"|"bugfix"|"hotfix")
            # Bump patch version for bug fixes
            patch=$((patch + 1))
            ;;
        "breaking"|"major")
            # Bump major version for breaking changes
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            # Default to patch bump
            patch=$((patch + 1))
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Function to determine commit type from recent commits
get_commit_type() {
    # Get the last commit message
    local last_commit=$(git log -1 --pretty=%B)
    
    # Check for conventional commit patterns
    if [[ "$last_commit" =~ ^feat: ]]; then
        echo "feat"
    elif [[ "$last_commit" =~ ^fix: ]]; then
        echo "fix"
    elif [[ "$last_commit" =~ ^BREAKING\ CHANGE: ]]; then
        echo "breaking"
    elif [[ "$last_commit" =~ ^hotfix: ]]; then
        echo "hotfix"
    else
        echo "patch"
    fi
}

# Main execution
main() {
    # Get current working directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$script_dir/.."
    
    # Get the latest version
    local current_version=$(get_latest_version)
    
    # Get commit type
    local commit_type=$(get_commit_type)
    
    # Calculate next version
    local next_version=$(calculate_next_version "$current_version" "$commit_type")
    
    # Output the version
    echo "$next_version"
}

# Run main function
main "$@" 