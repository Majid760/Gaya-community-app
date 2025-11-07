#!/bin/bash

# Navigate to the project directory
cd "/Users/majid/Desktop/PC DATA/Projects Data/Gaya"

# Rename the default branch to main (if it's not already)
git branch -M main

# Add your GitHub repository as the remote origin
# Replace 'your-username' with your actual GitHub username
git remote add origin https://github.com/your-username/gaya.git

# Push the code to GitHub and set the upstream
git push -u origin main

echo "Code pushed to GitHub successfully!"