# Troubleshooting Guide

## Common Issues and Solutions

### 🔧 Installation Issues

#### Issue: "Flutter command not found"

**Symptoms:**
```bash
$ flutter --version
flutter: command not found
```

**Solutions:**

1. **Check Flutter Installation:**
   ```bash
   # Find Flutter installation
   which flutter
   find ~ -name "flutter" -type d 2>/dev/null
   ```

2. **Add to PATH:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/flutter/bin"
   
   # Reload shell configuration
   source ~/.bashrc  # or source ~/.zshrc
   ```

3. **Verify Installation:**
   ```bash
   flutter doctor
   ```

#### Issue: "Version solving failed"

**Symptoms:**
```
version solving failed
```

**Solutions:**

1. **Clear cache and reinstall:**
   ```bash
   flutter clean
   rm pubspec.lock
   flutter pub cache clean
   flutter pub get
   ```

2. **Check Flutter version:**
   ```bash
   flutter --version
   # Should be 3.10.4 or higher
   ```

3. **Upgrade Flutter if needed:**
   ```bash
   flutter upgrade
   ```

---

### 🌐 Runtime Issues

#### Issue: CORS Errors

**Symptoms:**
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**Causes:**
- API and web app on different domains
- API not configured for CORS
- Missing CORS headers

**Solutions:**

1. **Configure Backend CORS (FastAPI):**
   ```python
   from fastapi.middleware.cors import CORSMiddleware
   
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:8080", "https://admin.aurawealth.com"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **Test with Chrome CORS disabled (Development Only):**
   ```bash
   # macOS
   open -na Google\ Chrome --args --disable-web-security --user-data-dir=/tmp/chrome_dev
   
   # Linux
   google-chrome --disable-web-security --user-data-dir=/tmp/chrome_dev
   
   # Windows
   chrome.exe --disable-web-security --user-data-dir="C:\temp\chrome_dev"
   ```

#### Issue: "Cannot connect to API"

**Symptoms:**
- Login fails
- API calls timeout
- Network errors

**Solutions:**

1. **Verify API URL:**
   ```dart
   // lib/core/constants/app_constants.dart
   static const String baseUrl = 'https://your-actual-api.com';
   ```

2. **Check API is running:**
   ```bash
   curl https://your-api-url.com/health
   ```

3. **Check network connectivity:**
   - Open browser DevTools (F12)
   - Go to Network tab
   - Try login
   - Check request details

4. **Verify HTTPS/HTTP:**
   - Make sure protocol matches (http:// or https://)
   - Mixed content (HTTPS site calling HTTP API) will fail

#### Issue: "401 Unauthorized" after login

**Symptoms:**
- Login succeeds
- Subsequent API calls fail with 401

**Solutions:**

1. **Check token storage:**
   ```dart
   // In browser console
   // Application → Local Storage → check for 'flutter.auth_token'
   ```

2. **Verify token format:**
   - Should be: `Bearer eyJhbGc...`
   - Check `ApiService._getHeaders()` method

3. **Check token expiry:**
   - Tokens expire after 12 hours
   - Login again to get new token

#### Issue: White screen / Blank page

**Symptoms:**
- App loads but shows nothing
- No errors in console

**Solutions:**

1. **Check browser console:**
   - Press F12
   - Look for JavaScript errors
   - Check Network tab for failed requests

2. **Clear browser cache:**
   - Hard refresh: Ctrl+Shift+R (Cmd+Shift+R on Mac)
   - Clear site data in DevTools

3. **Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

---

### 🐛 Development Issues

#### Issue: Hot Reload Not Working

**Solutions:**

1. **Try hot restart:**
   - Press `R` in terminal (not `r`)

2. **Full restart:**
   - Press `q` to quit
   - Run `flutter run -d chrome` again

3. **Check for syntax errors:**
   ```bash
   flutter analyze
   ```

#### Issue: Widget Rebuild Issues

**Symptoms:**
- UI not updating after data changes
- Stale data displayed

**Solutions:**

1. **Verify Obx usage:**
   ```dart
   // Correct:
   Obx(() => Text('${controller.value}'))
   
   // Incorrect:
   Text('${controller.value}')  // Missing Obx
   ```

2. **Check observable updates:**
   ```dart
   // Correct:
   myVariable.value = newValue;
   
   // Incorrect:
   myVariable = newValue;  // Doesn't trigger update
   ```

3. **Force refresh:**
   ```dart
   controller.refresh();  // If implemented
   ```

#### Issue: Navigation Not Working

**Symptoms:**
- Routes don't navigate
- Back button doesn't work

**Solutions:**

1. **Verify route names:**
   ```dart
   // Check routes are defined in app_pages.dart
   // Use exact route names from app_routes.dart
   ```

2. **Check middleware:**
   - If stuck at login, check `AuthMiddleware`
   - Verify token is saved correctly

3. **Use GetX navigation:**
   ```dart
   Get.toNamed(AppRoutes.dashboard);  // Correct
   Navigator.push(...)  // May not work with GetX routing
   ```

---

### 📱 UI Issues

#### Issue: Layout Overflow

**Symptoms:**
```
A RenderFlex overflowed by X pixels
```

**Solutions:**

1. **Add scroll view:**
   ```dart
   SingleChildScrollView(
     child: Column(children: [...])
   )
   ```

2. **Use Flexible/Expanded:**
   ```dart
   Row(
     children: [
       Expanded(child: Text('...')),  // Takes available space
     ]
   )
   ```

3. **Check responsive breakpoints:**
   - Test on different screen sizes
   - Use `Responsive.isMobile()` checks

#### Issue: Responsive Layout Not Switching

**Symptoms:**
- Mobile view shows on desktop
- Desktop view shows on mobile

**Solutions:**

1. **Check breakpoints:**
   ```dart
   // lib/core/constants/app_constants.dart
   static const double mobileBreakpoint = 600.0;
   static const double desktopBreakpoint = 1200.0;
   ```

2. **Use MediaQuery:**
   ```dart
   final width = MediaQuery.of(context).size.width;
   ```

3. **Test with device toolbar:**
   - Open Chrome DevTools (F12)
   - Toggle device toolbar (Ctrl+Shift+M)
   - Select different devices

---

### 🔐 Authentication Issues

#### Issue: Can't Login

**Symptoms:**
- Login button doesn't respond
- Error message shown

**Solutions:**

1. **Check credentials:**
   - Verify email format
   - Check password length (minimum 6 characters)

2. **Check API endpoint:**
   - Verify `/admin/login` is accessible
   - Check API is running

3. **Check request format:**
   - Should be `application/x-www-form-urlencoded`
   - Body: `username=email&password=pass`

4. **Check backend:**
   - Verify admin user exists in database
   - Check `is_admin = true` in user table

#### Issue: Logout Doesn't Work

**Solutions:**

1. **Clear all data:**
   ```dart
   await StorageService().clearAll();
   ```

2. **Force navigation:**
   ```dart
   Get.offAllNamed(AppRoutes.login);
   ```

3. **Clear browser storage manually:**
   - F12 → Application → Storage → Clear site data

---

### 💾 Data Issues

#### Issue: Data Not Loading

**Symptoms:**
- Spinning loader never stops
- Empty state shown despite data existing

**Solutions:**

1. **Check API response:**
   - Open Network tab in DevTools
   - Check response status and body
   - Verify JSON structure matches models

2. **Check model parsing:**
   - Look for JSON parsing errors in console
   - Verify field names match API response

3. **Add debugging:**
   ```dart
   print('API Response: $response');
   print('Parsed data: ${transactions.length}');
   ```

#### Issue: Statistics Show Zero

**Symptoms:**
- Dashboard cards show 0 for everything

**Solutions:**

1. **Check calculations:**
   - Verify transaction list is loaded
   - Check filter logic
   - Review calculation in `DashboardController`

2. **Verify transaction data:**
   ```dart
   print('Total transactions: ${allTransactions.length}');
   print('Transaction types: ${allTransactions.map((t) => t.type)}');
   ```

---

### 🎨 Styling Issues

#### Issue: Colors Not Showing Correctly

**Solutions:**

1. **Clear cache:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Check theme configuration:**
   - Verify `AppTheme.lightTheme` is applied
   - Check `AppColors` constants

3. **Hot restart:**
   - Press `R` in terminal
   - Or full restart

#### Issue: Icons Not Showing

**Solutions:**

1. **Check material design is enabled:**
   ```yaml
   # pubspec.yaml
   flutter:
     uses-material-design: true
   ```

2. **Verify icon name:**
   - Use valid Material Icons
   - Check: https://fonts.google.com/icons

---

### 📦 Build Issues

#### Issue: Build Fails

**Symptoms:**
```
Build failed with errors
```

**Solutions:**

1. **Run flutter doctor:**
   ```bash
   flutter doctor
   ```

2. **Check for errors:**
   ```bash
   flutter analyze
   ```

3. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

4. **Check Dart version:**
   ```bash
   dart --version
   # Should match pubspec.yaml requirements
   ```

#### Issue: Build Succeeds but App Doesn't Work

**Solutions:**

1. **Check build mode:**
   ```bash
   # Development build for debugging
   flutter build web
   
   # Production build (optimized)
   flutter build web --release
   ```

2. **Test locally:**
   ```bash
   cd build/web
   python -m http.server 8000
   # Open http://localhost:8000
   ```

3. **Check browser console:**
   - Look for runtime errors
   - Check network requests

---

### 🚀 Deployment Issues

#### Issue: Deployed App Shows Blank Page

**Solutions:**

1. **Check base href:**
   ```html
   <!-- web/index.html -->
   <base href="/">
   <!-- Or for subdirectory: -->
   <base href="/admin/">
   ```

2. **Rebuild with correct base:**
   ```bash
   flutter build web --release --base-href /admin/
   ```

3. **Check web server configuration:**
   - Ensure SPA routing works
   - All routes should serve `index.html`

#### Issue: Routes Don't Work After Refresh

**Symptoms:**
- Direct URL access returns 404
- Refresh on any page except home fails

**Solutions:**

**Nginx:**
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

**Apache (.htaccess):**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**Firebase:**
```json
{
  "hosting": {
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

### 🔒 Security Issues

#### Issue: Token Not Persisting

**Solutions:**

1. **Check SharedPreferences initialization:**
   ```dart
   // In main.dart
   await StorageService().init();
   ```

2. **Verify save operation:**
   ```dart
   await _storage.saveAuthToken(token);
   // Must use await!
   ```

3. **Check browser settings:**
   - Cookies enabled
   - Local storage enabled
   - Not in incognito mode (by default)

#### Issue: Unauthorized After Some Time

**Symptoms:**
- Works initially
- Fails after ~12 hours

**Cause:** Token expired (12-hour lifetime)

**Solution:**
- Re-login to get new token
- Implement token refresh (future enhancement)

---

### 📊 Performance Issues

#### Issue: Slow Initial Load

**Solutions:**

1. **Use release build:**
   ```bash
   flutter build web --release
   ```

2. **Enable caching:**
   - Configure CDN
   - Set cache headers
   - Enable gzip compression

3. **Optimize assets:**
   - Compress images
   - Minimize JSON payloads

#### Issue: Slow Navigation

**Solutions:**

1. **Use lazy loading:**
   - Already implemented with GetX
   - Controllers created only when needed

2. **Check for memory leaks:**
   - Dispose controllers properly
   - Use `Get.delete()` if needed

3. **Optimize list rendering:**
   - Use ListView.builder (already used)
   - Implement pagination (widget available)

---

### 🎯 Feature-Specific Issues

#### Issue: Transactions Not Filtering

**Solutions:**

1. **Check filter state:**
   ```dart
   print('Selected status: ${controller.selectedStatus.value}');
   print('Filtered count: ${controller.filteredTransactions.length}');
   ```

2. **Verify filter logic:**
   - Check `TransactionController.applyFilters()`
   - Ensure case-insensitive comparison

3. **Clear filters:**
   - Use "Clear Filters" button
   - Or: `controller.clearFilters()`

#### Issue: Messages Not Sending

**Solutions:**

1. **Check API endpoint:**
   - Verify `/admin/messages/{user_id}` works
   - Test with Postman/curl

2. **Check payload:**
   ```dart
   // Should be: { "body": "message text" }
   ```

3. **Verify user ID:**
   - Must be valid UUID
   - Must be from selected conversation

#### Issue: Price Update Fails

**Solutions:**

1. **Check input validation:**
   - Price must be > 0
   - Must be valid number

2. **Check API permissions:**
   - Verify admin token is valid
   - Check `is_admin = true`

3. **Check API endpoint:**
   - Should be: `POST /admin/set-price`
   - Body: `{ "price": 5200.00 }`

---

### 📱 Mobile/Responsive Issues

#### Issue: Sidebar Not Showing on Desktop

**Solutions:**

1. **Check screen width:**
   ```dart
   print('Width: ${MediaQuery.of(context).size.width}');
   ```

2. **Verify breakpoints:**
   - Desktop: > 1200px
   - Should show full sidebar

3. **Clear cache and refresh:**
   - Ctrl+Shift+R (hard refresh)

#### Issue: Drawer Not Showing on Mobile

**Solutions:**

1. **Check scaffold key:**
   - Scaffold should have drawer property
   - Use hamburger menu icon

2. **Verify responsive logic:**
   ```dart
   if (Responsive.isMobile(context)) {
     // Should use drawer
   }
   ```

---

### 🔍 Debugging Tools

#### Enable Verbose Logging

```dart
// In main.dart
void main() {
  Get.log = (message) => print('GetX: $message');
  runApp(MyApp());
}
```

#### Check Local Storage

**Chrome DevTools:**
1. F12 → Application tab
2. Storage → Local Storage
3. Check for `flutter.auth_token`

#### Monitor Network Requests

**Chrome DevTools:**
1. F12 → Network tab
2. Filter: Fetch/XHR
3. Click request to see details
4. Check headers, payload, response

#### Check Console Errors

**Chrome DevTools:**
1. F12 → Console tab
2. Look for red errors
3. Check error stack traces

---

### 🛠️ Development Tools

#### Run Flutter Analyze

```bash
flutter analyze
```

Checks for:
- Syntax errors
- Linting issues
- Deprecated APIs
- Type errors

#### Run Dart Fix

```bash
dart fix --apply
```

Auto-fixes:
- Deprecated APIs
- Linting issues
- Code style

#### Check Dependencies

```bash
flutter pub outdated
```

Shows:
- Current versions
- Latest versions
- Upgrade recommendations

---

### 📋 Checklist for Troubleshooting

When you encounter an issue:

1. **Check browser console** (F12)
2. **Check network requests** (F12 → Network)
3. **Verify API is running** (curl or browser)
4. **Check configuration** (API URL, credentials)
5. **Clear cache** (flutter clean, browser cache)
6. **Check documentation** (relevant .md files)
7. **Review error messages** (read carefully!)
8. **Test in incognito** (rule out cache issues)
9. **Check logs** (both frontend and backend)
10. **Ask for help** (with error details)

---

## 🆘 Getting Help

When reporting issues, include:

1. **Error message** (exact text)
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Environment:**
   - Flutter version (`flutter --version`)
   - Browser and version
   - Operating system
6. **Screenshots** (if UI issue)
7. **Console logs** (if applicable)
8. **Network requests** (from DevTools)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Web FAQ](https://flutter.dev/docs/development/platform-integration/web)
- [GetX Documentation](https://pub.dev/packages/get)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 🔧 Emergency Recovery

If nothing works:

```bash
# Nuclear option: Start fresh
flutter clean
rm -rf .dart_tool/
rm pubspec.lock
flutter pub cache clean
flutter pub get
flutter run -d chrome
```

## 💡 Pro Tips

1. **Always check browser console first**
2. **Use network tab to debug API issues**
3. **Test in incognito to rule out cache**
4. **Keep Flutter updated**
5. **Read error messages carefully**
6. **Test responsive layouts during development**
7. **Use Flutter DevTools for debugging**
8. **Keep backend API logs accessible**
9. **Test with real data**
10. **Document your own solutions**
