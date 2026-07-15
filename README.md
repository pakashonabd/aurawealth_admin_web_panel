# AuraWealth Admin Web Panel

A fully responsive admin web panel for AuraWealth - a 24 Carat Gold Investment Platform.

## ⭐ **NEW USER? [START HERE →](START_HERE.md)**

Complete setup in 3 simple steps:
1. Install Flutter → 2. Configure API → 3. Run the app



---

## 🎯 Features

- **Dashboard**: Real-time statistics, analytics, and recent transactions
- **Transaction Management**: View, filter, approve, reject, and manage all transactions
- **Gold Price Management**: Set and update gold prices with automatic calculation of sell/exchange prices
- **User Management**: View users and their transaction history
- **Messaging System**: Respond to user inquiries and support messages
- **Credit Grams**: Manually credit grams for in-store purchases
- **Redeem Codes**: Approve store sell and exchange transactions via redemption codes

## 🏗 Architecture

Built with clean architecture principles:

```
lib/
├── core/
│   ├── constants/     # App constants, colors, API endpoints
│   ├── theme/         # App theme configuration
│   └── utils/         # Utility classes (formatters, responsive)
├── models/            # Data models
├── services/          # API and storage services
├── controllers/       # GetX controllers
├── views/             # UI screens
│   ├── auth/
│   ├── dashboard/
│   ├── transactions/
│   ├── users/
│   ├── gold_management/
│   └── messages/
├── widgets/           # Reusable widgets
│   ├── layout/
│   └── common/
├── routes/            # App routing
└── middleware/        # Auth middleware
```

## 🎨 Design System

**Colors (Strictly 3 colors as per requirements):**
- Primary: Professional Sky Blue (#2196F3)
- Background: White
- Text: Black

**Responsive Breakpoints:**
- Mobile: < 600px
- Tablet: 600px - 1200px
- Desktop: > 1200px

## 📦 Dependencies

- **get** (^4.6.6): State management and routing
- **http** (^1.2.0): API communication
- **shared_preferences** (^2.2.2): Local storage for auth tokens
- **intl** (^0.19.0): Date and number formatting

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- A working backend API (see API documentation in `assets/api_documentation/`)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Salman-Farid/aurawealth_admin_web_panel.git
cd aurawealth_admin_web_panel
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API base URL:
   - Open `lib/core/constants/app_constants.dart`
   - Update the `baseUrl` constant with your API URL

4. Run the app:
```bash
# For web (recommended)
flutter run -d chrome

# For web with hot reload
flutter run -d web-server --web-port 8080
```

5. Build for production:
```bash
flutter build web --release
```

## 🔐 Authentication

The admin panel uses email/password authentication with JWT tokens:

- Login endpoint: `POST /admin/login`
- Token stored securely in local storage
- Token valid for 12 hours
- Auto-logout on token expiration

## 📱 Responsive Design

- **Desktop (>1200px)**: Full sidebar with all menu items visible
- **Tablet (600-1200px)**: Collapsible sidebar or drawer navigation
- **Mobile (<600px)**: Drawer navigation with hamburger menu

## 🔧 API Integration

All admin APIs are integrated:

- `/admin/login` - Admin authentication
- `/admin/dashboard` - Get all transactions with optional status filter
- `/admin/set-price` - Update gold market price
- `/admin/buy/credit` - Credit grams for in-store purchases
- `/admin/redeem-code` - Approve store/exchange transactions
- `/admin/{tx_id}/mark-as-paid` - Mark bank sells as paid
- `/admin/{tx_id}/reject` - Reject pending transactions
- `/admin/messages` - Get message inbox overview
- `/admin/messages/{user_id}` - View and reply to user messages

## 📊 Transaction Management

Supports all transaction types:
- `BUY_IN_APP` - Online purchases
- `BUY_IN_STORE` - In-store purchases (manual credit)
- `SELL_TO_BANK` - Bank transfers (2% fee, 3-5 day settlement)
- `SELL_TO_STORE` - Store redemption (17% fee, 60-min code expiry)
- `EXCHANGE_TO_JEWELLERY` - Jewellery exchange (10% fee, 5g minimum)

Transaction statuses: `PENDING`, `APPROVED`, `PAID`, `REJECTED`

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 📦 Building

### Web Build
```bash
flutter build web --release
```

The build output will be in `build/web/` directory.

### Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

## 🔒 Security

- JWT token-based authentication
- Tokens stored in secure local storage
- All API calls require authentication
- Auto-redirect to login on unauthorized access
- Token refresh handling

## 📖 Documentation

### Quick Access
- **[START_HERE.md](START_HERE.md)** ⭐ - First-time setup (start here!)
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Usage guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues & solutions

### Complete Documentation
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation steps
- **[CONFIG.md](CONFIG.md)** - Configuration instructions
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment options (Firebase, Netlify, AWS, etc.)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture
- **[FEATURES.md](FEATURES.md)** - Complete feature documentation
- **[API_INTEGRATION.md](API_INTEGRATION.md)** - API integration reference
- **[SCREENS.md](SCREENS.md)** - Visual screen overview
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project summary
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

### Reference Documentation
- API Documentation: `assets/api_documentation/README.md`
- MVP Building Guide: `assets/pakashona-mvp-building-guide/`

### Setup Tools
- **[setup_check.sh](setup_check.sh)** - Automated setup verification script

## 🤝 Contributing

This is a private admin panel. Contact the repository owner for contribution guidelines.

## 📄 License

Proprietary - All rights reserved

## 📞 Support

For issues or questions, contact the development team.

