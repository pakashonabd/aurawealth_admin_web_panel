# AuraWealth Admin Panel - Features Documentation

## 🎯 Overview

The AuraWealth Admin Panel is a fully responsive web application built with Flutter for managing the 24 Carat gold investment platform.

## 🔐 Authentication

### Login
- Email and password authentication
- JWT token-based session management
- 12-hour token validity
- Automatic token storage and retrieval
- Secure logout with token cleanup

### Authorization
- All routes protected with auth middleware
- Automatic redirect to login if not authenticated
- Persistent session across browser refreshes

## 📊 Dashboard

### Statistics Cards
- **Total Transactions**: Count of all transactions across all users
- **Pending Transactions**: Count of transactions awaiting admin action
- **Total Gold Holdings**: Net gold balance across all users (buys - sells/exchanges)
- **Total Revenue**: Sum of all fee amounts from non-rejected transactions
- **Buy Transactions**: Count of all buy transactions (in-app and in-store)
- **Sell Transactions**: Count of all sell transactions (bank and store)
- **Exchange Transactions**: Count of all jewellery exchange transactions
- **Gold Type**: Display of supported gold type (24 Carat)

### Recent Activity
- **Pending Transactions**: Real-time list of all pending transactions
- **Recent Transactions**: Last 10 transactions across all users
- Responsive table/card view based on screen size

### Auto-Calculations
- Real-time statistics computed from transaction data
- Automatic refresh capability
- Pull-to-refresh support

## 💼 Transaction Management

### Transaction List
- View all transactions across all users
- Responsive data table (desktop) and card list (mobile)
- Real-time status updates

### Filters & Search
- **Status Filter**: Filter by Pending, Approved, Paid, or Rejected
- **Type Filter**: Filter by transaction type
  - BUY_IN_APP
  - BUY_IN_STORE
  - SELL_TO_BANK
  - SELL_TO_STORE
  - EXCHANGE_TO_JEWELLERY
- **Search**: Search by transaction ID, user email, or redemption code
- **Clear Filters**: Reset all filters at once

### Transaction Actions
- **Mark as Paid**: For APPROVED bank sell transactions
- **Reject Transaction**: Reject pending transactions with optional note
- **View Details**: See complete transaction information

### Transaction Details
- Transaction ID
- User information (email/name)
- Transaction type and status
- Grams amount
- BDT amount
- Fee percentage and amount
- Timestamps (created, approved, paid, rejected)
- Redemption code (for store/exchange transactions)
- Admin notes

## 💰 Gold Management

### Current Prices Display
- **Market Price**: Base price per gram
- **Bank Sell Price**: Market price - 2% (for bank sell transactions)
- **Store Sell Price**: Market price - 17% (for store sell transactions)
- **Exchange Price**: Market price - 10% (for jewellery exchange)
- Last updated timestamp

### Price Update
- Set new market price per gram
- Automatic calculation of all derived prices
- Real-time update across the system
- Input validation

### Price Information
- Gold type specification (24 Carat only)
- Minimum trade amount (0.5g)
- Trade increment (0.5g)
- Minimum exchange amount (5.0g)
- Complete fee structure display

## 👥 User Management

### User List
- View all users extracted from transaction data
- Search by user ID, email, or phone
- Responsive table (desktop) and card list (mobile)

### User Details
- User ID and contact information
- Join date
- Total gold holdings
- Transaction count
- Complete transaction history

### User Analytics
- Calculated from transaction data:
  - Total grams owned
  - Number of transactions
  - Transaction types breakdown

## 💳 Credit Grams (In-Store Purchases)

### Manual Credit Form
- User ID input with validation
- Grams input with validation
  - Minimum: 0.5g
  - Increment: 0.5g multiples
- Automatic fee calculation (8% + 7.5% VAT)
- Transaction auto-approval
- Success/error feedback

### Process Flow
1. Customer makes in-store purchase
2. Admin verifies payment
3. Admin enters user ID and grams
4. System creates APPROVED BUY_IN_STORE transaction
5. Grams credited to user wallet instantly

## 🎫 Redeem Code

### Code Redemption Form
- 6-character code input
- Auto-uppercase conversion
- Code validation

### Supported Transactions
- SELL_TO_STORE (17% fee, 60-minute expiry)
- EXCHANGE_TO_JEWELLERY (10% fee, 60-minute expiry, 5g minimum)

### Process Flow
1. User generates code in mobile app
2. User presents code at physical location
3. Admin enters code in panel
4. System validates code and expiry
5. Transaction approved, locked grams consumed
6. Success confirmation

### Code Features
- Expiry validation (60 minutes)
- Duplicate redemption prevention
- Status verification (must be PENDING)

## 💬 Messaging System

### Inbox Overview
- List all user conversations
- Sort by last message time
- Display unread message counts
- Last message preview
- User identification

### Message Thread View
- Full conversation history
- User-to-admin messages
- Admin-to-user messages
- Timestamp display
- Auto-marking messages as read

### Reply Functionality
- Text input for replies
- Send button with loading state
- Real-time message updates
- Success/error notifications

### Responsive Design
- Split view on desktop/tablet (list + conversation)
- Single view on mobile (with back navigation)
- Smooth transitions between views

## 🎨 UI/UX Features

### Color System
- **Primary**: Sky Blue (#2196F3) - buttons, links, highlights
- **Background**: White - all backgrounds
- **Text**: Black - all text content
- **Contextual**: Green (success), Red (error), Orange (warning) - icons and status

### Design Elements
- Rounded corners (12px)
- Minimal shadows (elevation: 2)
- Clean card-based layout
- Consistent spacing (16px base padding)
- Hover effects on interactive elements
- Smooth animations and transitions

### Responsive Features
- **Desktop**: Full sidebar navigation, grid layouts
- **Tablet**: Collapsible sidebar/drawer, 2-column grids
- **Mobile**: Drawer navigation, single column, scrollable tables

### Loading States
- Circular progress indicators
- Loading messages
- Skeleton screens (where applicable)

### Error States
- Error messages with icons
- Retry buttons
- User-friendly error descriptions

### Empty States
- Contextual empty state messages
- Helpful icons
- Action buttons (where applicable)

## 🔄 Data Flow

### API Integration
- Centralized API service
- Automatic token injection
- Error handling and response parsing
- Timeout configuration (30 seconds)

### State Management (GetX)
- Reactive state updates
- Automatic UI refreshes
- Centralized controller logic
- Dependency injection

### Storage
- Secure local storage via SharedPreferences
- Auth token persistence
- User session management

## 🛡️ Security Features

- JWT token authentication
- Secure token storage
- Protected routes with middleware
- Automatic logout on token expiration
- No sensitive data in logs
- HTTPS enforcement (production)

## ♿ Accessibility

- Semantic HTML structure
- ARIA labels (auto-generated by Flutter)
- Keyboard navigation support
- Screen reader compatible
- High contrast text
- Proper focus management

## 🚀 Performance

- Lazy loading of controllers
- Efficient list rendering
- Minimal rebuilds with GetX
- Optimized API calls
- Cached data where appropriate
- Fast navigation with GetX routing

## 📱 Progressive Web App (PWA)

- Installable as web app
- Offline-capable (with service worker)
- App-like experience
- Home screen icon support
- Full-screen mode

## 🔧 Admin Operations

### Quick Actions
- Instant price updates
- One-click transaction approval/rejection
- Quick code redemption
- Fast message replies
- Bulk operations support (future enhancement)

### Audit Trail
- All transactions timestamped
- Admin action tracking
- User activity monitoring
- Transaction history preservation

## 📈 Analytics & Reporting

### Dashboard Analytics
- Real-time transaction counts
- Gold holdings summary
- Revenue tracking
- Status distribution
- Type distribution

### Transaction Analytics
- Filter by any combination of:
  - Status
  - Type
  - Date range
  - User
- Export capability (future enhancement)

## 🎯 Business Rules Enforcement

- Minimum trade: 0.5g
- Trade increments: 0.5g multiples
- Minimum exchange: 5.0g
- Gold type: 24 Carat only
- Fee calculations:
  - Buy: 8% + 7.5% VAT
  - Bank Sell: 2%
  - Store Sell: 17%
  - Exchange: 10%

## 🔮 Future Enhancements

- Multi-carat gold support
- Advanced analytics dashboard
- Export to CSV/Excel
- Bulk operations
- Admin role management
- Notification system
- Real-time updates via WebSockets
- Advanced reporting
- User communication templates
- Transaction approval workflows
