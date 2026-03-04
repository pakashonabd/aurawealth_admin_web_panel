# Installation & Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.10.4 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Chrome** (for web development)
   - Required for running and testing Flutter web apps

3. **Git**
   - For cloning the repository

## Step-by-Step Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Salman-Farid/aurawealth_admin_web_panel.git
cd aurawealth_admin_web_panel
```

### 2. Install Dependencies

```bash
flutter pub get
```

Expected output:
```
Running "flutter pub get" in aurawealth_admin_web_panel...
Resolving dependencies...
Got dependencies!
```

### 3. Configure API URL

**Option A: Edit Constants File (Recommended)**

Open `lib/core/constants/app_constants.dart` and update:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

**Option B: Environment Variable (Advanced)**

You can modify the code to use environment variables, but this requires additional setup.

### 4. Verify Setup

Check that everything is configured correctly:

```bash
flutter doctor
```

Ensure these are checked:
- ✓ Flutter SDK
- ✓ Chrome (for web development)
- ✓ Connected device (Chrome shown)

### 5. Run the Application

**Development Mode:**

```bash
flutter run -d chrome
```

Or specify web server:

```bash
flutter run -d web-server --web-port=8080
```

**Production Build:**

```bash
flutter build web --release
```

## Common Issues & Solutions

### Issue 1: "flutter: command not found"

**Solution:**
Add Flutter to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"

# Apply changes
source ~/.bashrc  # or source ~/.zshrc
```

### Issue 2: "Waiting for connection from debug service"

**Solution:**
- Ensure Chrome is installed
- Try running with explicit device: `flutter run -d chrome`
- Clear Flutter cache: `flutter clean && flutter pub get`

### Issue 3: "Version solving failed"

**Solution:**
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### Issue 4: CORS Errors in Browser

**Problem:** API requests fail with CORS errors

**Solution:**
Configure CORS in your backend API:

```python
# FastAPI example
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "https://your-domain.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Issue 5: "Failed to load network image"

**Solution:**
- Check internet connection
- Verify API URL is correct
- Check API is running and accessible

### Issue 6: Hot Reload Not Working

**Solution:**
- Save files explicitly (Ctrl+S / Cmd+S)
- Try hot restart: Press `R` in terminal or use hot restart button
- If still not working, stop and restart `flutter run`

## Development Workflow

### 1. Make Code Changes
Edit files in your preferred IDE (VS Code, Android Studio, IntelliJ)

### 2. Hot Reload
- Save file (Ctrl+S / Cmd+S)
- Or press `r` in terminal where Flutter is running
- UI updates automatically

### 3. Hot Restart
- Press `R` in terminal
- Restarts app with new code
- Clears state

### 4. Full Restart
- Press `q` to quit
- Run `flutter run -d chrome` again

## Testing

### Run Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

### Analyze Code
```bash
flutter analyze
```

## Building for Production

### 1. Build Web App
```bash
flutter build web --release
```

### 2. Output Location
Built files will be in: `build/web/`

### 3. Deploy

**Option A: Static Web Hosting**
Upload `build/web/` contents to:
- Firebase Hosting
- Netlify
- Vercel
- AWS S3 + CloudFront
- Any static web server

**Option B: Traditional Web Server**
```bash
# Copy built files
cp -r build/web/* /var/www/html/admin/

# Configure web server (nginx example)
server {
    listen 80;
    server_name admin.aurawealth.com;
    root /var/www/html/admin;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## IDE Setup

### Visual Studio Code

**Recommended Extensions:**
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens

**Settings:**
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "dart.lineLength": 80
}
```

### Android Studio / IntelliJ IDEA

**Recommended Plugins:**
- Flutter
- Dart

## Environment Variables (Optional)

If you want to use different configurations for development/production:

### 1. Create configuration files:

`lib/core/config/dev_config.dart`:
```dart
class DevConfig {
  static const String apiUrl = 'http://localhost:8000';
}
```

`lib/core/config/prod_config.dart`:
```dart
class ProdConfig {
  static const String apiUrl = 'https://api.aurawealth.com';
}
```

### 2. Update app_constants.dart:
```dart
import 'config/dev_config.dart';
// import 'config/prod_config.dart';  // Uncomment for production

static const String baseUrl = DevConfig.apiUrl;
```

## Performance Optimization

### 1. Enable Web Renderer
```bash
flutter run -d chrome --web-renderer html
# or
flutter run -d chrome --web-renderer canvaskit
```

### 2. Build Optimization
```bash
flutter build web --release --web-renderer canvaskit
```

### 3. Tree Shaking
Automatically enabled in release builds to remove unused code.

## Debugging

### Enable DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Console Logging
In your code:
```dart
import 'dart:developer' as developer;

developer.log('Debug message', name: 'AuraWealth');
```

### Network Debugging
Use Chrome DevTools:
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Monitor API requests

## Security Checklist

Before deployment:

- [ ] Update API URL to production endpoint
- [ ] Remove debug logging
- [ ] Enable HTTPS
- [ ] Configure CORS properly
- [ ] Test authentication flow
- [ ] Verify token expiry handling
- [ ] Check for exposed sensitive data
- [ ] Review error messages (no sensitive info)

## Next Steps

After successful installation:

1. **Configure API URL** in `lib/core/constants/app_constants.dart`
2. **Run the app**: `flutter run -d chrome`
3. **Login** with admin credentials
4. **Test features** systematically
5. **Customize** as needed
6. **Build for production** when ready
7. **Deploy** to your hosting platform

## Support

If you encounter issues:

1. Check this guide first
2. Review error messages carefully
3. Check Flutter and package versions
4. Verify API is accessible
5. Check CORS configuration
6. Review browser console for errors

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
- [API Documentation](assets/api_documentation/README.md)
