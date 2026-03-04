# AuraWealth Admin Panel - Configuration Guide

## API Configuration

The admin panel requires the backend API to be running. Update the following in your code:

### File: `lib/core/constants/app_constants.dart`

```dart
static const String baseUrl = 'YOUR_API_URL_HERE'; // e.g., 'https://api.aurawealth.com'
```

## Backend API Setup

Make sure your backend API is running and accessible. The API should support the following admin endpoints:

- POST /admin/login
- GET /admin/dashboard
- POST /admin/set-price
- GET /prices
- POST /admin/buy/credit
- POST /admin/redeem-code
- POST /admin/{tx_id}/mark-as-paid
- POST /admin/{tx_id}/reject
- GET /admin/messages
- GET /admin/messages/{user_id}
- POST /admin/messages/{user_id}

## Admin Credentials

For testing, use the credentials provided in the API documentation:
- Email: salmanfarid43@gmail.com
- Password: salman12345

⚠️ **Important**: Change these credentials in production!

## CORS Configuration

If you're running the web app and API on different domains, ensure CORS is properly configured in your backend:

```python
# FastAPI example
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Running the App

1. Update the `baseUrl` in `lib/core/constants/app_constants.dart`
2. Run `flutter pub get`
3. Run `flutter run -d chrome` or `flutter run -d web-server`

## Building for Production

```bash
flutter build web --release
```

The output will be in `build/web/` directory. Deploy this to your web server or hosting platform.
