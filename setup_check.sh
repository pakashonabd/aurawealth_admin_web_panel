#!/bin/bash

# AuraWealth Admin Panel - Setup Verification Script

echo "🔍 Checking AuraWealth Admin Panel Setup..."
echo ""

# Check Flutter
echo "📱 Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    flutter_version=$(flutter --version | head -n 1)
    echo "✅ Flutter is installed: $flutter_version"
else
    echo "❌ Flutter is not installed"
    echo "   Install from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo ""

# Check Flutter doctor
echo "🏥 Running Flutter doctor..."
flutter doctor
echo ""

# Check if dependencies are installed
echo "📦 Checking dependencies..."
if [ -d ".dart_tool" ] && [ -f "pubspec.lock" ]; then
    echo "✅ Dependencies appear to be installed"
else
    echo "⚠️  Dependencies may not be installed. Run: flutter pub get"
fi

echo ""

# Check for Chrome
echo "🌐 Checking Chrome installation..."
if command -v google-chrome &> /dev/null || command -v chromium &> /dev/null; then
    echo "✅ Chrome/Chromium is installed"
else
    echo "⚠️  Chrome not found. Install Chrome for web development"
fi

echo ""

# Check API URL configuration
echo "🔧 Checking API configuration..."
api_url=$(grep "baseUrl =" lib/core/constants/app_constants.dart | cut -d'"' -f2)
if [ "$api_url" = "https://api.aurawealth.com" ]; then
    echo "⚠️  API URL is still set to default: $api_url"
    echo "   Update lib/core/constants/app_constants.dart with your actual API URL"
else
    echo "✅ API URL configured: $api_url"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Setup Status Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Install dependencies: flutter pub get"
echo "2. Configure API URL in lib/core/constants/app_constants.dart"
echo "3. Run the app: flutter run -d chrome"
echo ""
echo "For detailed instructions, see INSTALLATION.md"
echo ""
