#!/bin/bash

# Find all Git repositories in the home directory and subdirectories
find "$HOME" -type d -name ".git" 2>/dev/null | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  echo "Checking: $repo_dir"
  cd "$repo_dir" || continue

  # Get the remote URL
  remote_url=$(git remote get-url origin 2>/dev/null)
  echo "Remote URL: $remote_url"

  # Check if the remote URL contains 'JustPassingBy06'
  if [[ "$remote_url" == *"JustPassingBy06"* ]]; then
    # Replace 'JustPassingBy06' with 'CouldBeMathijs' (works for both SSH & HTTPS)
    new_url=$(echo "$remote_url" | sed 's/JustPassingBy06/CouldBeMathijs/')

    # Update the remote URL
    echo "Updating: $repo_dir"
    echo "Old URL: $remote_url"
    echo "New URL: $new_url"
    git remote set-url origin "$new_url"
  fi
done
