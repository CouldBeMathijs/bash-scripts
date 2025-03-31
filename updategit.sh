#!/bin/bash

find "$HOME" -type d -name ".git" | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  cd "$repo_dir" || continue

  remote_url=$(git remote get-url origin 2>/dev/null)

  if [[ $remote_url == *"github.com/JustPassingBy06/"* ]]; then
    new_url=${remote_url/JustPassingBy06/CouldBeMathijs}
    git remote set-url origin "$new_url"
    echo "Updated remote in $repo_dir"
  fi
done
