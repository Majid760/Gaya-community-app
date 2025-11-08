#!/bin/bash

# Script to push the clean Gaya repository to a new GitHub repository

echo "=== Gaya Project - Push to New GitHub Repository ==="
echo ""

# Prompt for GitHub username
read -p "Enter your GitHub username: " github_username

# Prompt for repository name
read -p "Enter your new GitHub repository name: " repo_name

echo ""
echo "Setting up remote origin..."
git remote add origin https://github.com/$github_username/$repo_name.git

echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "=== Repository successfully pushed to GitHub! ==="
echo "Repository URL: https://github.com/$github_username/$repo_name"
echo ""
echo "Don't forget to run the setup_env.sh script to configure your environment variables:"
echo "cd /Users/majid/Desktop/PC DATA/Projects Data/Gaya-clean"
echo "./setup_env.sh"