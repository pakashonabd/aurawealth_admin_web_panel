# 🚀 Quick Start Guide

## Get Up and Running in 5 Minutes

### 1. Prerequisites
- Flutter SDK 3.10.4+ ([Install](https://flutter.dev/docs/get-started/install))
- Chrome browser
- Git

### 2. Installation

```bash
# Clone repository
git clone https://github.com/Salman-Farid/aurawealth_admin_web_panel.git
cd aurawealth_admin_web_panel

# Install dependencies
flutter pub get
```

### 3. Configuration

**Update API URL:**

Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

### 4. Run

```bash
flutter run -d chrome
```

### 5. Login

Use the admin credentials:
- **Email**: salmanfarid43@gmail.com
- **Password**: salman12345

⚠️ Change these in production!

## 📚 Documentation

- **[README.md](README.md)** - Project overview and features
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide
- **[CONFIG.md](CONFIG.md)** - Configuration instructions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture
- **[FEATURES.md](FEATURES.md)** - Complete feature list
- **[API_INTEGRATION.md](API_INTEGRATION.md)** - API integration details
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment guide

## 🎯 Key Features

- ✅ **Dashboard** with real-time statistics
- ✅ **Transaction Management** with filters and actions
- ✅ **Gold Price Management** with live updates
- ✅ **User Management** with transaction history
- ✅ **Messaging System** with inbox and replies
- ✅ **Manual Operations** (credit grams, redeem codes)
- ✅ **Fully Responsive** (desktop, tablet, mobile)

## 🎨 Design

- **Primary Color**: Sky Blue (#2196F3)
- **Background**: White
- **Text**: Black
- **Minimal & Professional** design

## 🔧 Common Commands

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run -d chrome

# Build for production
flutter build web --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build
flutter clean
```

## ⚡ Quick Troubleshooting

**CORS errors?**
→ Configure CORS in your backend API

**Can't connect to API?**
→ Check API URL in `app_constants.dart`
→ Verify API is running

**Flutter not found?**
→ Add Flutter to PATH: `export PATH="$PATH:/path/to/flutter/bin"`

**Hot reload not working?**
→ Press `R` for hot restart or restart app

## 📱 Responsive Preview

Test on different screen sizes:
- Open Chrome DevTools (F12)
- Toggle device toolbar (Ctrl+Shift+M)
- Select device or enter custom dimensions

## 🚢 Production Deployment

```bash
# Build
flutter build web --release

# Deploy files from build/web/ to:
# - Firebase Hosting
# - Netlify
# - Vercel  
# - AWS S3
# - Your web server
```

## 📞 Need Help?

1. Check documentation in this repository
2. Review API documentation: `assets/api_documentation/README.md`
3. Run setup check: `./setup_check.sh`
4. Contact the development team

## 🎉 You're Ready!

Once everything is set up:
1. Login to the admin panel
2. Explore the dashboard
3. Test transaction management
4. Try updating gold prices
5. Check the messaging system

Happy administrating! 💎
