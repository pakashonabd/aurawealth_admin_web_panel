# ⚡ START HERE - First Time Setup

This is your **first stop** after cloning the repository. Follow these steps in order.

---

## 🎯 Step 1: Check Prerequisites (2 minutes)

### Required Software

**1. Flutter SDK**
```bash
flutter --version
```

Expected output: `Flutter 3.10.4` or higher

❌ **If not installed:**
- Download: https://flutter.dev/docs/get-started/install
- Or use snap (Linux): `sudo snap install flutter --classic`

**2. Chrome Browser**
```bash
google-chrome --version
```

❌ **If not installed:**
- Download: https://www.google.com/chrome/

---

## 🔧 Step 2: Install Dependencies (1 minute)

```bash
# Navigate to project directory
cd aurawealth_admin_web_panel

# Install Flutter packages
flutter pub get
```

**Expected output:**
```
Running "flutter pub get" in aurawealth_admin_web_panel...
Resolving dependencies...
+ get 4.6.6
+ http 1.2.0
+ shared_preferences 2.2.2
+ intl 0.19.0
Got dependencies!
```

✅ **Success!** Dependencies installed.

---

## ⚙️ Step 3: Configure API URL (1 minute)

**Open this file:**
```
lib/core/constants/app_constants.dart
```

**Find this line:**
```dart
static const String baseUrl = 'https://api.aurawealth.com';
```

**Replace with your actual API URL:**
```dart
static const String baseUrl = 'http://localhost:8000';  // Development
// or
static const String baseUrl = 'https://your-api.com';   // Production
```

**Save the file.**

✅ **Success!** API configured.

---

## 🔒 Step 4: Verify Backend (2 minutes)

**1. Make sure your backend API is running**

Test with curl:
```bash
curl http://localhost:8000/health
# or
curl https://your-api.com/health
```

**2. Test admin login endpoint**
```bash
curl -X POST http://localhost:8000/admin/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=salman12345"
```

Expected: JSON response with `access_token`

**3. Configure CORS in backend**

If using FastAPI, add this:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "*"],  # Update for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

✅ **Success!** Backend ready.

---

## 🚀 Step 5: Run the App (1 minute)

```bash
flutter run -d chrome
```

**Expected output:**
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
✓ Built build/web
Launching lib/main.dart on Chrome in debug mode...

Application running at: http://localhost:xxxxx
```

**Browser will open automatically with the login screen.**

✅ **Success!** App is running!

---

## 🔑 Step 6: Login (30 seconds)

**Use these credentials:**
- **Email:** `salmanfarid43@gmail.com`
- **Password:** `salman12345`

**Click "Sign In"**

✅ **Success!** You should see the Dashboard.

---

## 🎉 Step 7: Explore Features (5 minutes)

### Dashboard
- View 8 statistics cards
- Check pending transactions
- Review recent activity

### Transactions
- Click "Transactions" in sidebar
- Try filtering by status
- Try searching
- Test action buttons (if you have test data)

### Gold Management
- Click "Gold Management"
- View current prices
- Try updating the price

### Users
- Click "Users" in sidebar
- View user list
- Click "View Details" on any user

### Messages
- Click "Messages" in sidebar
- View conversations (if any exist)
- Try the reply feature

### Manual Operations
- Click "Credit Grams"
- Try the form (requires valid user ID)
- Click "Redeem Code"
- Try code redemption (requires valid code)

---

## ✅ Verification Checklist

After setup, verify:

- [ ] App launches without errors
- [ ] Login works
- [ ] Dashboard displays
- [ ] Can navigate between screens
- [ ] Sidebar/drawer works
- [ ] Responsive layout changes on resize
- [ ] Can logout successfully

---

## 🐛 Quick Troubleshooting

### Problem: "flutter: command not found"
**Solution:** Add Flutter to PATH or reinstall Flutter

### Problem: "CORS error" in browser console
**Solution:** Configure CORS in your backend API (see Step 4)

### Problem: "Cannot connect to API"
**Solution:** 
1. Check API URL in `app_constants.dart`
2. Verify backend is running
3. Test API with curl

### Problem: "401 Unauthorized"
**Solution:** Check admin credentials in your database

### Problem: Blank screen
**Solution:** 
1. Check browser console (F12)
2. Look for errors
3. Verify API URL is correct

**For more help:** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📖 What to Read Next

### For Quick Setup
1. ✅ **You are here** → START_HERE.md
2. → QUICKSTART.md (if you want more details)

### For Understanding
3. → GETTING_STARTED.md (usage guide)
4. → FEATURES.md (what it can do)
5. → SCREENS.md (visual overview)

### For Deployment
6. → DEPLOYMENT.md (when ready to deploy)

### For Development
7. → ARCHITECTURE.md (how it works)
8. → API_INTEGRATION.md (API details)

### Full Index
- See all documentation in **PROJECT_SUMMARY.md**

---

## 🎊 Congratulations!

If you've completed all steps successfully:

✅ Your admin panel is running  
✅ You can login and navigate  
✅ All features are accessible  
✅ You're ready to use or deploy  

---

## 🚀 Next Steps

### For Development
- Explore each feature
- Test with real data
- Customize as needed
- Add your branding

### For Production
- Update API URL to production
- Change admin credentials
- Build for production: `flutter build web --release`
- Deploy using DEPLOYMENT.md guide
- Set up monitoring

### For Team
- Share documentation
- Set up Git workflow
- Plan future enhancements
- Assign roles

---

## 💡 Pro Tips

1. **Keep backend running** while testing
2. **Use Chrome DevTools** (F12) for debugging
3. **Test responsive** by resizing browser
4. **Read documentation** as needed
5. **Check TROUBLESHOOTING.md** if issues arise

---

## 📞 Support

**Documentation:**
- All guides in project root
- Start with QUICKSTART.md
- Check TROUBLESHOOTING.md for issues

**Code:**
- Clean, well-documented
- Easy to understand
- Easy to modify

**Community:**
- Refer to project documentation
- Check GitHub issues
- Contact development team

---

## ✨ You're All Set!

Your AuraWealth Admin Panel is ready to use.

**Current Status:**
- ✅ Setup complete
- ✅ App running
- ✅ Ready to use
- ✅ Ready to deploy

**Enjoy your new admin panel!** 💎

---

**Questions?** Check the documentation files or run `./setup_check.sh` to verify your setup.
