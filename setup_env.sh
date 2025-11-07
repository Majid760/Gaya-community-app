#!/bin/bash

# Script to set up environment variables for the Gaya project

echo "=== Gaya Project - Environment Variables Setup ==="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

echo "Setting up Firebase Functions environment variables..."
echo ""

# Navigate to functions directory
cd functions

# Check if we're in the functions directory
if [ ! -f "package.json" ]; then
    echo "Error: This script must be run from the project root directory"
    exit 1
fi

echo "=== Setting up Algolia environment variables ==="
read -p "Enter your Algolia App ID (or press Enter to skip): " algolia_app_id
if [ ! -z "$algolia_app_id" ]; then
    firebase functions:config:set algolia.app_id="$algolia_app_id"
    echo "Algolia App ID set successfully"
fi

read -p "Enter your Algolia Admin Key (or press Enter to skip): " algolia_admin_key
if [ ! -z "$algolia_admin_key" ]; then
    firebase functions:config:set algolia.admin_key="$algolia_admin_key"
    echo "Algolia Admin Key set successfully"
fi

echo ""
echo "=== Setting up OpenAI environment variables ==="
read -p "Enter your OpenAI API Key (or press Enter to skip): " openai_api_key
if [ ! -z "$openai_api_key" ]; then
    firebase functions:config:set openai.api_key="$openai_api_key"
    echo "OpenAI API Key set successfully"
fi

echo ""
echo "=== Current Firebase Functions configuration ==="
firebase functions:config:get

echo ""
echo "=== Instructions for Flutter environment variables ==="
echo "For Flutter development, use the following commands:"
echo ""
echo "Development:"
echo "  flutter run --dart-define=FIREBASE_API_KEY=your_dev_key"
echo ""
echo "Production:"
echo "  flutter build apk --dart-define=FIREBASE_API_KEY=your_prod_key"
echo "  flutter build ios --dart-define=FIREBASE_API_KEY=your_prod_key"

echo ""
echo "Setup completed successfully!"
echo "Please refer to ENVIRONMENT_VARIABLES.md for more detailed instructions."