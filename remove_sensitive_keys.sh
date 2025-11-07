#!/bin/bash

# Script to remove sensitive keys from git history
# WARNING: This script will rewrite your git history and affect all collaborators

echo "=== Gaya Project - Sensitive Key Removal Script ==="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: This script must be run from within a git repository"
    exit 1
fi

echo "Current branch: $(git branch --show-current)"
echo "Warning: This operation will rewrite your git history!"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with removing sensitive keys from git history? (yes/no): " confirmation

if [[ $confirmation != "yes" ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "=== Step 1: Backup your repository ==="
echo "Creating a backup of your current repository..."
cd ..
cp -r Gaya Gaya_backup_$(date +%Y%m%d_%H%M%S)
cd Gaya
echo "Backup created successfully!"
echo ""

echo "=== Step 2: Install BFG Repo-Cleaner ==="
echo "Please download BFG Repo-Cleaner from https://rtyley.github.io/bfg-repo-cleaner/"
echo "Or install it using: brew install bfg"
echo ""

echo "=== Step 3: Create a file with sensitive strings to remove ==="
cat > sensitive_strings.txt << EOF
AIzaSyDMUbvC7tODkadWx8k32HT4hPnysjAx80w
AAAAp3_8N4g:APA91bHLd61dm6sxM--N-PzO4S_YjWGjQHFm6ewzTIvsC2lZTRB-dwEFPd9w3CbYQiiz-l4G4eMmyyIOAierghK0at6SL1mt7m4LiGlvFxk7LgVkvvTtnDwC--34FBzRZY4BkmUfrgy0
AAAAUjsLo_c:APA91bH-nhaKXnEZJJf8bxHPwSO3LZ8yBDRMUAJt75LhPgNZ29wRalF7hIqvK6PUJ52zH2jDEVt683KKzmr7-7Fw_jMC9E0lDvOtDAj2nZcX0xEkAZjD2A1suQo2cZ2fM6Vy4kzW19Io
7V8WUJ2HVJ
3490c9dbbf8a98d57849c35259816523
48366a10f2f6da5c63b7d0ccafb37c91
enter your openai api key here
EOF

echo "Created sensitive_strings.txt with known sensitive strings"
echo ""

echo "=== Step 4: Run BFG to remove sensitive strings ==="
echo "After installing BFG, run the following commands:"
echo ""
echo "bfg --replace-text sensitive_strings.txt"
echo "git reflog expire --expire=now --all && git gc --prune=now --aggressive"
echo ""

echo "=== Step 5: Update remote repository ==="
echo "After cleaning the history, force push to your remote repository:"
echo ""
echo "git push origin main --force"
echo ""

echo "=== Important Notes ==="
echo "1. This will rewrite your git history - inform all collaborators"
echo "2. All collaborators will need to re-clone the repository"
echo "3. Make sure to update your application to use environment variables instead of hardcoded keys"
echo "4. For Firebase configuration, use Firebase CLI to manage environment variables"
echo "5. For Algolia, use environment variables in your deployment platform"
echo ""

echo "Process completed. Please follow the instructions above to complete the cleanup."