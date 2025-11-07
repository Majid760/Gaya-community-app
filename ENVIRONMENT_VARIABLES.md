# Environment Variables Configuration

This document explains how to properly configure environment variables for the Gaya project to avoid hardcoding sensitive information.

## Firebase Functions Environment Variables

### Setting up Environment Variables

For Firebase Functions, you should use Firebase CLI to set environment variables:

```bash
# Navigate to the functions directory
cd functions

# Set Algolia credentials
firebase functions:config:set algolia.app_id="YOUR_ALGOLIA_APP_ID"
firebase functions:config:set algolia.admin_key="YOUR_ALGOLIA_ADMIN_KEY"

# Set OpenAI API key
firebase functions:config:set openai.api_key="YOUR_OPENAI_API_KEY"

# View current configuration
firebase functions:config:get
```

### Using Environment Variables in Code

In your Firebase Functions code, access environment variables using:

```javascript
const functions = require('firebase-functions');

// Access environment variables
const algoliaAppId = functions.config().algolia.app_id;
const algoliaAdminKey = functions.config().algolia.admin_key;
const openaiApiKey = functions.config().openai.api_key;
```

## Flutter Environment Variables

For Flutter applications, you can use compile-time constants:

```dart
// Using String.fromEnvironment for compile-time constants
static const String firebaseApiKey = String.fromEnvironment(
  'FIREBASE_API_KEY',
  defaultValue: 'YOUR_DEFAULT_API_KEY_HERE',
);

static const String fcmServerKey = String.fromEnvironment(
  'FCM_SERVER_KEY',
  defaultValue: 'YOUR_DEFAULT_FCM_KEY_HERE',
);
```

When building your Flutter app, you can pass these values:

```bash
# For development
flutter run --dart-define=FIREBASE_API_KEY=your_dev_key

# For production build
flutter build apk --dart-define=FIREBASE_API_KEY=your_prod_key
```

## Algolia Configuration

Instead of hardcoding Algolia credentials, use environment variables:

```javascript
// In functions/core/aloglia/algolia_config.js
const APP_ID = functions.config().algolia?.app_id || process.env.ALGOLIA_APP_ID || "YOUR_DEFAULT_APP_ID";
const APP_ADMIN_ID = functions.config().algolia?.admin_key || process.env.ALGOLIA_ADMIN_KEY || "YOUR_DEFAULT_ADMIN_KEY";
```

## Security Best Practices

1. **Never commit sensitive keys to version control**
2. **Use environment variables for all sensitive data**
3. **Provide safe default values for development**
4. **Document all required environment variables**
5. **Use different keys for development and production**
6. **Regularly rotate API keys**
7. **Use Firebase Secret Manager for highly sensitive data**

## Required Environment Variables

Here's a list of environment variables that need to be configured:

| Variable | Description | Required For |
|----------|-------------|--------------|
| `ALGOLIA_APP_ID` | Algolia Application ID | Search functionality |
| `ALGOLIA_ADMIN_KEY` | Algolia Admin API Key | Search indexing |
| `OPENAI_API_KEY` | OpenAI API Key | AI features |
| `FIREBASE_API_KEY` | Firebase Web API Key | Firebase client initialization |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging Server Key | Push notifications |

## Deployment

When deploying to different environments, make sure to set the appropriate environment variables:

### Firebase Deployment
```bash
# Set production environment variables
firebase functions:config:set algolia.app_id="PROD_APP_ID"
firebase functions:config:set algolia.admin_key="PROD_ADMIN_KEY"
firebase functions:config:set openai.api_key="PROD_OPENAI_KEY"

# Deploy functions
firebase deploy --only functions
```

### Flutter Deployment
```bash
# Build with production keys
flutter build apk --dart-define=FIREBASE_API_KEY=prod_key_here
```

## Troubleshooting

If you encounter issues with missing environment variables:

1. Check that all required variables are set
2. Verify that variable names match exactly
3. Ensure proper escaping of special characters
4. Confirm that environment variables are accessible in your deployment environment