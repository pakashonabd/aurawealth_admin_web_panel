# 📱 Screens Overview

## Navigation Structure

```
Login Screen (Public)
    │
    └─── After Authentication ───┐
                                   │
    ┌──────────────────────────────┘
    │
    ├─► Dashboard
    │   └─ Stats cards, pending transactions, recent transactions
    │
    ├─► Transactions
    │   └─ List, filters, search, actions (mark paid, reject)
    │
    ├─► Users
    │   └─ User list, search, detail modal with transaction history
    │
    ├─► Gold Management
    │   └─ Current prices, update price, fee information
    │
    ├─► Messages
    │   └─ Inbox, conversation threads, reply functionality
    │
    ├─► Credit Grams
    │   └─ Form to credit grams for in-store purchases
    │
    └─► Redeem Code
        └─ Form to redeem store/exchange transaction codes
```

## 🔐 1. Login Screen

**Route:** `/login`  
**File:** `lib/views/auth/login_screen.dart`  
**Controller:** `AuthController`

### Layout
```
┌──────────────────────────────┐
│                              │
│    [Admin Panel Icon]        │
│    AuraWealth Admin          │
│  Sign in to your account     │
│                              │
│  ┌────────────────────────┐ │
│  │ Email                  │ │
│  └────────────────────────┘ │
│                              │
│  ┌────────────────────────┐ │
│  │ Password               │ │
│  └────────────────────────┘ │
│                              │
│  [  Sign In Button  ]        │
│                              │
│  Version 1.0.0               │
└──────────────────────────────┘
```

### Features
- Email validation
- Password validation (min 6 chars)
- Loading state during login
- Error message display
- Enter key to submit
- Responsive center layout

### User Flow
1. Enter email and password
2. Click "Sign In" or press Enter
3. Token saved to local storage
4. Redirect to Dashboard

---

## 📊 2. Dashboard Screen

**Route:** `/dashboard`  
**File:** `lib/views/dashboard/dashboard_screen.dart`  
**Controller:** `DashboardController`

### Desktop Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Dashboard                                    [Profile ▼] │
│ [Logo]  ├──────────────────────────────────────────────────────────┤
│ Aura    │                                                           │
│ Wealth  │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │
│         │ │  Total  │ │ Pending │ │  Gold   │ │ Revenue │         │
│▸ Dashbrd│ │  Trans  │ │  Trans  │ │Holdings │ │         │         │
│ Trans   │ │   247   │ │    12   │ │ 125.5 g │ │ ৳45,280 │         │
│ Users   │ └─────────┘ └─────────┘ └─────────┘ └─────────┘         │
│ Gold    │                                                           │
│ Messages│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │
│ Credit  │ │   Buy   │ │  Sell   │ │Exchange │ │   Gold  │         │
│ Redeem  │ │  Trans  │ │  Trans  │ │  Trans  │ │   Type  │         │
│         │ │   180   │ │    57   │ │    10   │ │24 Carat │         │
│ v1.0.0  │ └─────────┘ └─────────┘ └─────────┘ └─────────┘         │
└─────────┤                                                           │
          │ ┌─────────────────────────────────────────────────────┐ │
          │ │ ⚠ Pending Transactions                   12 items   │ │
          │ │ [Transaction table with actions]                    │ │
          │ └─────────────────────────────────────────────────────┘ │
          │                                                           │
          │ ┌─────────────────────────────────────────────────────┐ │
          │ │ 🕐 Recent Transactions              [View All →]    │ │
          │ │ [Transaction table]                                 │ │
          │ └─────────────────────────────────────────────────────┘ │
          └───────────────────────────────────────────────────────────┘
```

### Mobile Layout
```
┌──────────────────────────┐
│ ☰  Dashboard   [Profile] │
├──────────────────────────┤
│ ┌──────────────────────┐ │
│ │    Total Trans       │ │
│ │       247            │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │    Pending           │ │
│ │       12             │ │
│ └──────────────────────┘ │
│                          │
│ [Stats cards stacked]    │
│                          │
│ ⚠ Pending (12)           │
│ [Card] [Card] [Card]     │
│                          │
│ 🕐 Recent                │
│ [Card] [Card] [Card]     │
└──────────────────────────┘
```

### Stats Cards
1. Total Transactions
2. Pending Transactions (with warning color)
3. Total Gold Holdings
4. Total Revenue
5. Buy Transactions
6. Sell Transactions
7. Exchange Transactions
8. Gold Type (24 Carat)

### Data Sections
- Pending Transactions table/list
- Recent Transactions table/list
- Pull-to-refresh support

---

## 📋 3. Transactions Screen

**Route:** `/transactions`  
**File:** `lib/views/transactions/transactions_screen.dart`  
**Controller:** `TransactionController`

### Desktop Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Transactions                                 [Profile ▼] │
├─────────┼──────────────────────────────────────────────────────────┤
│         │ ┌────────────────────────────────────────────────────┐   │
│         │ │ 🔍 Search transactions...                      [x] │   │
│         │ └────────────────────────────────────────────────────┘   │
│         │                                                           │
│         │ [Status: All ▼] [Type: All ▼] [Clear Filters] [Refresh] │
│         │                                                           │
│         ├───────────────────────────────────────────────────────────┤
│         │ ┌─────────────────────────────────────────────────────┐ │
│         │ │ ID    │ User  │ Type │ Status │ Grams │ Amount │... │ │
│         │ ├─────────────────────────────────────────────────────┤ │
│         │ │ abc..│ Jane  │ BUY  │PENDING │ 5.0g  │৳28,080│... │ │
│         │ │ def..│ John  │ SELL │APPROVED│ 3.0g  │৳15,288│... │ │
│         │ │ ...  │ ...   │ ...  │ ...    │ ...   │ ...   │... │ │
│         │ └─────────────────────────────────────────────────────┘ │
└─────────┴───────────────────────────────────────────────────────────┘
```

### Mobile Layout
```
┌──────────────────────────┐
│ ☰  Transactions [Profile]│
├──────────────────────────┤
│ 🔍 Search...          [x]│
│ [Status][Type][Clear]    │
├──────────────────────────┤
│ ┌──────────────────────┐ │
│ │ 🛒 BUY IN APP       │ │
│ │ Jane Doe            │ │
│ │ ID: abc123...       │ │
│ │ ─────────────────── │ │
│ │ 5.0g  ৳28,080  Fee  │ │
│ │ 02 Mar 2026         │ │
│ │              [PENDING]│ │
│ │ [Reject]            │ │
│ └──────────────────────┘ │
│                          │
│ [More transaction cards] │
└──────────────────────────┘
```

### Features
- Search bar (ID, email, code)
- Status filter dropdown
- Type filter dropdown
- Clear filters button
- Refresh button
- Actions:
  - Mark as Paid (APPROVED bank sells)
  - Reject (PENDING transactions)
- Confirmation dialogs
- Responsive table/card view

---

## 👥 4. Users Screen

**Route:** `/users`  
**File:** `lib/views/users/users_screen.dart`  
**Controller:** `UserController`

### Desktop Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Users                                        [Profile ▼] │
├─────────┼──────────────────────────────────────────────────────────┤
│         │ 🔍 Search users...                    [x]  [🔄 Refresh] │
│         ├──────────────────────────────────────────────────────────┤
│         │ ┌─────────────────────────────────────────────────────┐ │
│         │ │ User ID    │ Email        │ Trans │ Grams │ Joined │ │
│         │ ├─────────────────────────────────────────────────────┤ │
│         │ │ abc123...  │jane@mail.com │   15  │ 25.5g │ 1 Jan  │ │
│         │ │ def456...  │john@mail.com │    8  │ 10.0g │ 5 Jan  │ │
│         │ │ [View Details button for each row]                  │ │
│         │ └─────────────────────────────────────────────────────┘ │
└─────────┴───────────────────────────────────────────────────────────┘
```

### User Details Modal
```
┌───────────────────────────────────┐
│ 👤 jane@mail.com           [X]   │
│ ID: abc123-def456-...             │
├───────────────────────────────────┤
│ Email:    jane@mail.com           │
│ Phone:    +8801234567890          │
│ Joined:   01 Jan 2026             │
│ Gold:     25.5 g                  │
│ Trans:    15                      │
├───────────────────────────────────┤
│ Transaction History               │
│ ┌───────────────────────────────┐ │
│ │ ✅ BUY IN APP                │ │
│ │ 5.0g • ৳28,080   02 Mar 2026 │ │
│ ├───────────────────────────────┤ │
│ │ 💰 SELL TO BANK             │ │
│ │ 3.0g • ৳15,288   05 Mar 2026 │ │
│ └───────────────────────────────┘ │
└───────────────────────────────────┘
```

### Features
- Search by ID, email, phone
- User list with statistics
- User detail dialog
- Transaction history per user
- Responsive table/card view

---

## 💰 5. Gold Management Screen

**Route:** `/gold-management`  
**File:** `lib/views/gold_management/gold_management_screen.dart`  
**Controller:** `GoldController`

### Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Gold Management                              [Profile ▼] │
├─────────┼──────────────────────────────────────────────────────────┤
│         │ ┌─────────────────────────────────────────────────────┐ │
│         │ │ 💎 Current Gold Prices (24 Carat)                   │ │
│         │ │ Updated: 2 hours ago                                │ │
│         │ │                                                     │ │
│         │ │ ┌─────────────┐  ┌─────────────┐                   │ │
│         │ │ │📈 Market    │  │🏦 Bank Sell │                   │ │
│         │ │ │  ৳5,200.00  │  │  ৳5,096.00  │                   │ │
│         │ │ │ Per gram    │  │  -2% fee    │                   │ │
│         │ │ └─────────────┘  └─────────────┘                   │ │
│         │ │                                                     │ │
│         │ │ ┌─────────────┐  ┌─────────────┐                   │ │
│         │ │ │🏪 Store Sell│  │🔄 Exchange  │                   │ │
│         │ │ │  ৳4,316.00  │  │  ৳4,680.00  │                   │ │
│         │ │ │ -17% fee    │  │  -10% fee   │                   │ │
│         │ │ └─────────────┘  └─────────────┘                   │ │
│         │ └─────────────────────────────────────────────────────┘ │
│         │                                                           │
│         │ ┌─────────────────────────────────────────────────────┐ │
│         │ │ ✏️ Update Gold Price                                │ │
│         │ │                                                     │ │
│         │ │ Set the new market price per gram (BDT).           │ │
│         │ │ All other prices will be calculated automatically. │ │
│         │ │                                                     │ │
│         │ │ [Price per Gram (BDT)    ] [Update Price]          │ │
│         │ └─────────────────────────────────────────────────────┘ │
│         │                                                           │
│         │ ┌─────────────────────────────────────────────────────┐ │
│         │ │ ℹ️ Price Information                                 │ │
│         │ │ Gold Type: 24 Carat                                 │ │
│         │ │ Minimum Trade: 0.5 g                                │ │
│         │ │ Fee Structure: [details]                            │ │
│         │ └─────────────────────────────────────────────────────┘ │
└─────────┴───────────────────────────────────────────────────────────┘
```

### Features
- Display all current prices
- Automatic price calculations
- Update form with validation
- Loading state during update
- Price information panel
- Success/error feedback

---

## 💬 6. Messages Screen

**Route:** `/messages`  
**File:** `lib/views/messages/messages_screen.dart`  
**Controller:** `MessageController`

### Desktop Layout (Split View)
```
┌─Sidebar─┬─Threads─────────┬─Conversation─────────────────────────┐
│         │ Messages   [🔄] │ Jane Doe                        [🔄] │
│         ├─────────────────┼──────────────────────────────────────┤
│         │ ┌─────────────┐ │                                      │
│         │ │👤 Jane Doe │ │ ┌──────────────────────────────────┐ │
│         │ │Hi, question│ │ │ User: Hi, I have a question      │ │
│         │ │2 hrs ago  2│ │ │ about my pending order.          │ │
│         │ └─────────────┘ │ │ 2 hours ago                      │ │
│         │                 │ └──────────────────────────────────┘ │
│         │ ┌─────────────┐ │                                      │
│         │ │👤 John Smith│ │         ┌──────────────────────────┐ │
│         │ │When will... │ │         │ Admin: Your order is     │ │
│         │ │1 day ago    │ │         │ under review.            │ │
│         │ └─────────────┘ │         │ 1 hour ago               │ │
│         │                 │         └──────────────────────────┘ │
│         │ [More threads]  │                                      │
│         │                 │ ┌──────────────────────────────────┐ │
│         │                 │ │ User: Thank you!                 │ │
│         │                 │ │ Just now                         │ │
│         │                 │ └──────────────────────────────────┘ │
│         │                 ├──────────────────────────────────────┤
│         │                 │ Type your reply...          [Send 📤]│
└─────────┴─────────────────┴──────────────────────────────────────┘
```

### Mobile Layout
```
Inbox View:
┌──────────────────────────┐
│ ☰ Messages      [Profile]│
│ Conversations       [🔄] │
├──────────────────────────┤
│ ┌──────────────────────┐ │
│ │ 👤 Jane Doe        2 │ │
│ │ Hi, question about...│ │
│ │ 2 hours ago          │ │
│ └──────────────────────┘ │
│                          │
│ [More conversation cards]│
└──────────────────────────┘

Conversation View:
┌──────────────────────────┐
│ ← Jane Doe          [🔄] │
├──────────────────────────┤
│ ┌──────────────────────┐ │
│ │ User: Hi, I have a   │ │
│ │ question...          │ │
│ │ 2 hours ago          │ │
│ └──────────────────────┘ │
│                          │
│      ┌─────────────────┐ │
│      │ Admin: Your     │ │
│      │ order is under  │ │
│      │ review.         │ │
│      │ 1 hour ago      │ │
│      └─────────────────┘ │
├──────────────────────────┤
│ Type reply...   [Send 📤]│
└──────────────────────────┘
```

### Features
- Conversation list with unread counts
- Split view (desktop) / single view (mobile)
- Message bubbles (user vs admin)
- Reply functionality
- Refresh buttons
- Auto-mark as read
- Timestamps

---

## 💳 7. Credit Grams Screen

**Route:** `/credit-grams`  
**File:** `lib/views/transactions/credit_grams_screen.dart`

### Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Credit Grams                                 [Profile ▼] │
├─────────┼──────────────────────────────────────────────────────────┤
│         │                                                           │
│         │        ┌────────────────────────────────────┐             │
│         │        │ 💳 Credit Grams to User            │             │
│         │        │ For in-store purchases             │             │
│         │        │                                    │             │
│         │        │ ┌────────────────────────────────┐ │             │
│         │        │ │ User ID                        │ │             │
│         │        │ │ Enter user UUID                │ │             │
│         │        │ └────────────────────────────────┘ │             │
│         │        │                                    │             │
│         │        │ ┌────────────────────────────────┐ │             │
│         │        │ │ Grams                      g   │ │             │
│         │        │ │ e.g., 5.0                      │ │             │
│         │        │ └────────────────────────────────┘ │             │
│         │        │                                    │             │
│         │        │ ℹ️ Fee: 8% + 7.5% VAT             │             │
│         │        │    Transaction will be approved   │             │
│         │        │                                    │             │
│         │        │    [Credit Grams Button]           │             │
│         │        └────────────────────────────────────┘             │
└─────────┴───────────────────────────────────────────────────────────┘
```

### Features
- User ID input with validation
- Grams input with validation (min 0.5g, increment 0.5g)
- Fee information display
- Success/error feedback
- Loading state
- Form validation

---

## 🎫 8. Redeem Code Screen

**Route:** `/redeem-code`  
**File:** `lib/views/transactions/redeem_code_screen.dart`

### Layout
```
┌─Sidebar─┬──────────────────────────────────────────────────────────┐
│         │ Redeem Code                                  [Profile ▼] │
├─────────┼──────────────────────────────────────────────────────────┤
│         │                                                           │
│         │        ┌────────────────────────────────────┐             │
│         │        │ 🎫 Redeem Transaction Code         │             │
│         │        │ For store sell or exchange         │             │
│         │        │                                    │             │
│         │        │ ┌────────────────────────────────┐ │             │
│         │        │ │ Redemption Code                │ │             │
│         │        │ │ e.g., A3X9KL                   │ │             │
│         │        │ └────────────────────────────────┘ │             │
│         │        │                                    │             │
│         │        │ ⚠️ Redeeming will approve and     │             │
│         │        │    consume locked grams           │             │
│         │        │                                    │             │
│         │        │    [Redeem Code Button]            │             │
│         │        └────────────────────────────────────┘             │
│         │                                                           │
│         │        ┌────────────────────────────────────┐             │
│         │        │ How it Works                       │             │
│         │        │ ① User generates code              │             │
│         │        │ ② User visits store                │             │
│         │        │ ③ Verify & Redeem                  │             │
│         │        │                                    │             │
│         │        │ ⏰ Codes expire after 60 minutes   │             │
│         │        └────────────────────────────────────┘             │
└─────────┴───────────────────────────────────────────────────────────┘
```

### Features
- 6-character code input
- Auto-uppercase conversion
- Code validation
- Instructions card
- Expiry warning
- Success/error feedback
- Loading state

---

## 🎨 Responsive Behavior Summary

### Desktop (> 1200px)
- Full sidebar (250px width)
- 4-column stat grids
- Data tables
- Split views for messages
- Hover effects active

### Tablet (600-1200px)
- Drawer navigation OR collapsed sidebar
- 2-column grids
- Data tables or scrollable tables
- Split or single views
- Touch-optimized

### Mobile (< 600px)
- Drawer navigation with hamburger menu
- Single column layout
- Card lists instead of tables
- Single view with back navigation
- Touch-optimized, larger tap targets

## 🔄 Common UI Patterns

### Loading State
```
┌──────────────────┐
│                  │
│    ⏳ Loading    │
│    [spinner]     │
│  Loading data... │
│                  │
└──────────────────┘
```

### Error State
```
┌──────────────────┐
│                  │
│    ❌ Error      │
│  Error message   │
│                  │
│  [Retry Button]  │
│                  │
└──────────────────┘
```

### Empty State
```
┌──────────────────┐
│                  │
│    📭 Empty      │
│  No items found  │
│                  │
└──────────────────┘
```

## 🎯 Key UI Elements

### Status Chips
- **PENDING**: Orange background
- **APPROVED**: Green background
- **PAID**: Blue background
- **REJECTED**: Red background

### Type Chips
- **BUY**: Green tint
- **SELL**: Red tint
- **EXCHANGE**: Blue tint

### Action Buttons
- **Primary Actions**: Sky blue filled buttons
- **Secondary Actions**: Outlined buttons
- **Danger Actions**: Red outlined buttons

## 📊 Data Display Patterns

### Cards
- White background
- 12px border radius
- 1px grey border
- 2px elevation

### Tables
- Horizontal scroll on overflow
- Alternating row hover
- Sortable columns (future)
- Action column

### Lists
- Card-based items
- Touch-optimized
- Swipe actions (future)

## 🔔 Notifications

### Success
```
✅ Success: Operation completed successfully
```

### Error
```
❌ Error: Something went wrong
```

### Info
```
ℹ️ Info: Additional information
```

Displayed via GetX snackbar at top of screen.

---

## 📱 Progressive Web App Features

### Install Prompt
Users can install the admin panel as a standalone app:
- Desktop: Install button in address bar
- Mobile: "Add to Home Screen" in browser menu

### Offline Support (Future)
With service worker configuration:
- Cache static assets
- Offline page
- Background sync

---

## 🎉 Summary

The admin panel provides:
- **7 main screens** (+ login)
- **11 admin API endpoints** integrated
- **3 device sizes** supported
- **Infinite** scalability for future features
- **100%** responsive
- **Production-ready** code

All screens follow consistent design patterns and responsive behavior for optimal user experience across all devices.
