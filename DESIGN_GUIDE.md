# 🎨 Visual Design Guide

## Color Palette

### Primary Colors (Strict 3-Color Scheme)

```
╔════════════════════════════════════════════════════════════╗
║                     PRIMARY PALETTE                         ║
╚════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────┐
│  PRIMARY COLOR - Sky Blue                                    │
│  ████████████████████████████████████████                    │
│  Hex: #2196F3                                                │
│  RGB: (33, 150, 243)                                         │
│  Usage: Buttons, links, active states, highlights           │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  BACKGROUND COLOR - White                                    │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░                    │
│  Hex: #FFFFFF                                                │
│  RGB: (255, 255, 255)                                        │
│  Usage: All backgrounds (app, cards, buttons, tables)       │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  TEXT COLOR - Black                                          │
│  ████████████████████████████████████████                    │
│  Hex: #000000                                                │
│  RGB: (0, 0, 0)                                              │
│  Usage: All text content throughout the app                 │
└──────────────────────────────────────────────────────────────┘
```

### Contextual Colors (Icons Only)

```
╔════════════════════════════════════════════════════════════╗
║                   CONTEXTUAL COLORS                         ║
║              (For Icons and Status Only)                    ║
╚════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────┐
│  SUCCESS - Green                                             │
│  ████████████████████████████████████████                    │
│  Hex: #4CAF50                                                │
│  Usage: Success icons, completed states, buy transactions   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  ERROR - Red                                                 │
│  ████████████████████████████████████████                    │
│  Hex: #F44336                                                │
│  Usage: Error icons, rejected states, sell transactions     │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  WARNING - Orange                                            │
│  ████████████████████████████████████████                    │
│  Hex: #FF9800                                                │
│  Usage: Warning icons, pending states, alerts               │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  INFO - Blue                                                 │
│  ████████████████████████████████████████                    │
│  Hex: #2196F3                                                │
│  Usage: Info icons, exchange transactions, notifications    │
└──────────────────────────────────────────────────────────────┘
```

---

## Typography

### Font Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  HEADING 1 - Display Large                                  │
│  Size: 24px | Weight: Bold (700) | Color: Black            │
│  Usage: Page titles, main headings                          │
│  Example: "Dashboard", "Transactions"                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  HEADING 2 - Display Medium                                 │
│  Size: 20px | Weight: SemiBold (600) | Color: Black        │
│  Usage: Section titles, card headers                        │
│  Example: "Pending Transactions", "Recent Activity"         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  HEADING 3 - Display Small                                  │
│  Size: 18px | Weight: SemiBold (600) | Color: Black        │
│  Usage: Subsection titles                                   │
│  Example: "User Details", "Transaction Info"                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  BODY - Regular                                              │
│  Size: 14px | Weight: Regular (400) | Color: Black         │
│  Usage: Body text, form labels, general content            │
│  Example: Most text content throughout the app              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  CAPTION - Small                                             │
│  Size: 12px | Weight: Regular (400) | Color: Grey (600)    │
│  Usage: Timestamps, helper text, meta information           │
│  Example: "2 hours ago", "Updated: Mar 2, 2026"             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  BUTTON TEXT                                                 │
│  Size: 14px | Weight: Medium (500) | Color: White/Primary  │
│  Usage: Button labels                                       │
│  Example: "Sign In", "Update Price", "Send"                │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Styling

### Cards

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  Background:    White                                        │
│  Border:        1px solid Grey 200                          │
│  Border Radius: 12px                                        │
│  Elevation:     2px (subtle shadow)                         │
│  Padding:       16px                                        │
│                                                              │
│  Example:                                                    │
│  ┌────────────────────────────────────────────────┐         │
│  │                                                │         │
│  │  📊 Total Transactions                         │         │
│  │                                                │         │
│  │       247                                      │         │
│  │                                                │         │
│  └────────────────────────────────────────────────┘         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Buttons

```
PRIMARY BUTTON (Sky Blue):
  ┌────────────────────┐
  │   Update Price     │  Background: #2196F3
  └────────────────────┘  Text: White
                          Border Radius: 12px
                          Padding: 12px 24px

OUTLINED BUTTON (Secondary):
  ┌────────────────────┐
  │   Clear Filters    │  Background: Transparent
  └────────────────────┘  Border: 1px solid #2196F3
                          Text: #2196F3
                          Border Radius: 12px

DANGER BUTTON (Destructive):
  ┌────────────────────┐
  │      Reject        │  Background: Transparent
  └────────────────────┘  Border: 1px solid #F44336
                          Text: #F44336
                          Border Radius: 12px
```

### Input Fields

```
TEXT INPUT:
  ┌────────────────────────────────────┐
  │  Email                             │
  │  user@example.com                  │
  └────────────────────────────────────┘
  
  Border: 1px solid Grey 300
  Border Radius: 8px
  Padding: 12px
  Focus Border: 2px solid #2196F3

DROPDOWN:
  ┌────────────────────────────────────┐
  │  Status: All                    ▼ │
  └────────────────────────────────────┘
  
  Border: 1px solid Grey 300
  Border Radius: 8px
  Padding: 12px
```

### Status Chips

```
PENDING:
  ┌─────────────┐
  │  PENDING   │  Background: Orange 50
  └─────────────┘  Text: Orange 900
                   Border Radius: 20px

APPROVED:
  ┌─────────────┐
  │  APPROVED  │  Background: Green 50
  └─────────────┘  Text: Green 900

PAID:
  ┌─────────────┐
  │    PAID    │  Background: Blue 50
  └─────────────┘  Text: Blue 900

REJECTED:
  ┌─────────────┐
  │  REJECTED  │  Background: Red 50
  └─────────────┘  Text: Red 900
```

---

## Layout Specifications

### Spacing System

```
Base Unit: 16px

Micro:    4px   ▪
Small:    8px   ▪▪
Base:     16px  ▪▪▪▪
Medium:   24px  ▪▪▪▪▪▪
Large:    32px  ▪▪▪▪▪▪▪▪
XLarge:   48px  ▪▪▪▪▪▪▪▪▪▪▪▪
```

### Grid System

```
DESKTOP (>1200px):
┌──────┬──────┬──────┬──────┐
│  1   │  2   │  3   │  4   │  4-column grid
└──────┴──────┴──────┴──────┘

TABLET (600-1200px):
┌─────────────┬─────────────┐
│      1      │      2      │  2-column grid
└─────────────┴─────────────┘

MOBILE (<600px):
┌───────────────────────────┐
│             1             │  1-column stack
├───────────────────────────┤
│             2             │
├───────────────────────────┤
│             3             │
└───────────────────────────┘
```

### Sidebar Dimensions

```
DESKTOP (Full Sidebar):
  Width: 250px
  Always visible
  
TABLET (Collapsible):
  Expanded: 250px
  Collapsed: 70px (icons only)
  Toggle button
  
MOBILE (Drawer):
  Width: 280px
  Overlay mode
  Hamburger menu
```

---

## Screen Layouts

### Login Screen

```
┌─────────────────────────────────────┐
│                                     │
│           💎                        │
│      AURAWEALTH                     │
│      Admin Panel                    │
│                                     │
│  Sign in to your account            │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📧 Email                      │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🔒 Password                   │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│    ┌───────────────────────┐       │
│    │     Sign In           │       │
│    └───────────────────────┘       │
│                                     │
│         Version 1.0.0               │
│                                     │
└─────────────────────────────────────┘

Center-aligned, max-width: 400px
```

### Dashboard Layout (Desktop)

```
┌─Sidebar──┬────────────────────────────────────────────────────────────┐
│          │  📊 Dashboard                            [Profile Menu ▼]  │
│  [LOGO]  ├────────────────────────────────────────────────────────────┤
│  AURA    │                                                             │
│  WEALTH  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│          │  │   247   │  │   12    │  │ 125.5g  │  │ ৳45,280 │       │
│  ▸ Dashb │  │  Total  │  │ Pending │  │  Gold   │  │ Revenue │       │
│  Trans   │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│  Users   │                                                             │
│  Gold    │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  Message │  │   180   │  │   57    │  │   10    │  │   24    │       │
│  Credit  │  │   Buy   │  │  Sell   │  │Exchange │  │  Carat  │       │
│  Redeem  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│          │                                                             │
│ v1.0.0   │  ┌─────────────────────────────────────────────────────┐   │
└──────────┤  │ ⚠ Pending Transactions                    12 items  │   │
           │  │ ┌───────────────────────────────────────────────────┤   │
           │  │ │ ID    │Type│Status │Grams│Amount │Actions      │   │
           │  │ ├───────────────────────────────────────────────────┤   │
           │  │ │abc123 │BUY │PENDING│5.0g │৳28,080│[Reject]     │   │
           │  │ └───────────────────────────────────────────────────┘   │
           │  └─────────────────────────────────────────────────────┘   │
           │                                                             │
           │  ┌─────────────────────────────────────────────────────┐   │
           │  │ 🕐 Recent Transactions             [View All →]     │   │
           │  │ [Transaction table...]                              │   │
           │  └─────────────────────────────────────────────────────┘   │
           └─────────────────────────────────────────────────────────────┘

Sidebar Width: 250px
Content Area: Flexible (fills remaining space)
Stats Grid: 4 columns on desktop
```

### Dashboard Layout (Mobile)

```
┌─────────────────────────────────────┐
│  ☰  Dashboard            [Profile]  │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │         Total Trans           │ │
│  │            247                │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │      Pending Trans            │ │
│  │            12                 │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Stats cards stacked vertically]  │
│                                     │
│  ⚠ Pending (12)                    │
│  ┌───────────────────────────────┐ │
│  │ 🛒 BUY IN APP                │ │
│  │ Jane Doe                      │ │
│  │ 5.0g • ৳28,080               │ │
│  │ [PENDING]         [Reject]   │ │
│  └───────────────────────────────┘ │
│                                     │
│  [More transaction cards...]       │
│                                     │
└─────────────────────────────────────┘

Full width, single column
Hamburger menu reveals drawer
```

---

## Component Specifications

### Stats Card

```
┌──────────────────────────┐
│                          │
│  📊 Card Icon           │  Size: 40px
│                          │  Color: Primary (Sky Blue)
│  TITLE TEXT              │  14px, Grey 600
│                          │
│       VALUE              │  32px, Bold, Black
│                          │
│  Caption (optional)      │  12px, Grey 600
│                          │
└──────────────────────────┘

Dimensions:
  Min Width: 200px
  Height: Auto (min 120px)
  Padding: 20px
  Border Radius: 12px
  Background: White
  Border: 1px solid Grey 200
  Elevation: 2px
```

### Data Table

```
┌────────────────────────────────────────────────────────────────┐
│  COLUMN 1  │  COLUMN 2  │  COLUMN 3  │  COLUMN 4  │  ACTIONS │
├────────────────────────────────────────────────────────────────┤
│  Value 1   │  Value 2   │  Value 3   │  Value 4   │  [Btns]  │  Row 1
├────────────────────────────────────────────────────────────────┤
│  Value 1   │  Value 2   │  Value 3   │  Value 4   │  [Btns]  │  Row 2 (Hover)
├────────────────────────────────────────────────────────────────┤
│  Value 1   │  Value 2   │  Value 3   │  Value 4   │  [Btns]  │  Row 3
└────────────────────────────────────────────────────────────────┘

Specifications:
  Header:
    - Background: Grey 50
    - Text: 14px, Bold, Black
    - Padding: 16px
  
  Rows:
    - Background: White
    - Hover: Grey 50
    - Text: 14px, Regular, Black
    - Padding: 12px 16px
    - Border Bottom: 1px solid Grey 200
  
  Mobile Conversion:
    - Becomes vertical card list
    - Each row = 1 card
```

### Navigation Sidebar

```
┌────────────────────────┐
│                        │
│    [LOGO]              │  Height: 64px
│    AURAWEALTH         │  Padding: 16px
│                        │
├────────────────────────┤
│                        │
│  ▸ Dashboard          │  Item height: 48px
│    Transactions       │  Padding: 12px 16px
│    Users              │  Hover: Grey 100
│    Gold Management    │  Active: Sky Blue 50
│    Messages           │  Active text: Primary
│    Credit Grams       │
│    Redeem Code        │
│                        │
├────────────────────────┤
│                        │
│    v1.0.0              │  Footer
│                        │  12px, Grey 600
└────────────────────────┘

Width: 250px (desktop)
Background: White
Border Right: 1px solid Grey 200
```

### Top App Bar

```
┌────────────────────────────────────────────────────────────────┐
│  Page Title                                [Admin Name ▼]      │
└────────────────────────────────────────────────────────────────┘

Height: 64px
Background: White
Border Bottom: 1px solid Grey 200
Elevation: 1px

Left: Page title (24px, Bold)
Right: Profile menu (dropdown)
```

---

## Responsive Transformations

### Navigation

```
DESKTOP (>1200px):
  ┌─────┬──────────┐
  │ SB  │ Content  │
  │     │          │
  │     │          │
  └─────┴──────────┘
  SB = Full Sidebar (250px)

TABLET (600-1200px):
  ┌──┬─────────────┐
  │SB│   Content   │
  │  │             │
  │  │             │
  └──┴─────────────┘
  SB = Collapsed (70px) or Drawer

MOBILE (<600px):
  ┌───────────────┐
  │☰  Content    │
  │              │
  │              │
  └──────────────┘
  ☰ = Drawer overlay
```

### Grid Transformations

```
DESKTOP (4 columns):
  ┌───┬───┬───┬───┐
  │ 1 │ 2 │ 3 │ 4 │
  └───┴───┴───┴───┘

TABLET (2 columns):
  ┌─────┬─────┐
  │  1  │  2  │
  ├─────┼─────┤
  │  3  │  4  │
  └─────┴─────┘

MOBILE (1 column):
  ┌───────────┐
  │     1     │
  ├───────────┤
  │     2     │
  ├───────────┤
  │     3     │
  ├───────────┤
  │     4     │
  └───────────┘
```

### Table Transformations

```
DESKTOP:
  ┌─────────────────────────────────────────────────┐
  │ Col1 │ Col2 │ Col3 │ Col4 │ Col5 │ Actions    │
  ├─────────────────────────────────────────────────┤
  │ Val1 │ Val2 │ Val3 │ Val4 │ Val5 │ [Buttons]  │
  └─────────────────────────────────────────────────┘
  Horizontal scroll if needed

MOBILE:
  ┌─────────────────────────────┐
  │  Type Chip    [Status Chip] │
  │  Name                       │
  │  ID: abc123...              │
  │  ─────────────────────────  │
  │  5.0g • ৳28,080 • ৳2,080   │
  │  02 Mar 2026                │
  │            [Action Buttons] │
  └─────────────────────────────┘
  Vertical card layout
```

---

## Interaction States

### Button States

```
NORMAL:
  ┌────────────┐
  │   Sign In  │  Background: #2196F3
  └────────────┘  Opacity: 100%

HOVER:
  ┌────────────┐
  │   Sign In  │  Background: #1976D2 (darker)
  └────────────┘  Cursor: pointer
                  Transition: 200ms

PRESSED:
  ┌────────────┐
  │   Sign In  │  Background: #1565C0 (even darker)
  └────────────┘  Transform: scale(0.98)

DISABLED:
  ┌────────────┐
  │   Sign In  │  Background: Grey 300
  └────────────┘  Cursor: not-allowed
                  Opacity: 50%

LOADING:
  ┌────────────┐
  │  ⏳ ...    │  Shows spinner
  └────────────┘  Disabled state
```

### Card States

```
NORMAL:
  ┌──────────────┐
  │  Card        │  Background: White
  │  Content     │  Border: 1px Grey 200
  └──────────────┘  Elevation: 2px

HOVER (if clickable):
  ┌──────────────┐
  │  Card        │  Border: 1px Primary
  │  Content     │  Elevation: 4px
  └──────────────┘  Transition: 200ms
                    Cursor: pointer

LOADING:
  ┌──────────────┐
  │    ⏳        │  Center spinner
  │   Loading    │  Message below
  └──────────────┘  Grey 400 text

ERROR:
  ┌──────────────┐
  │    ❌        │  Error icon
  │ Error msg    │  Red text
  │  [Retry]     │  Retry button
  └──────────────┘
```

---

## Animation Specifications

### Page Transitions

```
Duration: 300ms
Curve: ease-in-out
Effect: Fade + slide
```

### Button Interactions

```
Duration: 200ms
Hover: Scale 1.02
Press: Scale 0.98
```

### Loading States

```
Spinner: Circular
Color: Primary (Sky Blue)
Size: 24px (small), 40px (large)
```

### Snackbar Notifications

```
┌──────────────────────────────────┐
│  ✅ Success: Operation complete  │
└──────────────────────────────────┘

Position: Top center
Duration: 3 seconds
Background: White
Border: 1px solid (Green/Red/Blue)
Elevation: 6px
Animation: Slide down + fade in
```

---

## Iconography

### Icon Sizes

```
Small:  16px - Used in buttons, chips
Medium: 24px - Used in menu items, actions
Large:  40px - Used in stats cards, headers
XLarge: 64px - Used in empty states, errors
```

### Icon Usage

```
Navigation Menu:
  Dashboard     → 📊 dashboard
  Transactions  → 💳 receipt_long
  Users         → 👥 people
  Gold          → 💰 attach_money
  Messages      → 💬 message
  Credit        → ➕ add_card
  Redeem        → 🎫 confirmation_number

Actions:
  Edit          → ✏️ edit
  Delete        → 🗑️ delete
  View          → 👁️ visibility
  Refresh       → 🔄 refresh
  Search        → 🔍 search
  Filter        → 🔽 filter_list
  Close         → ❌ close
  Check         → ✅ check
  Payment       → 💳 payment

Status:
  Pending       → ⏳ pending
  Approved      → ✅ check_circle
  Paid          → 💰 paid
  Rejected      → ❌ cancel
```

---

## Loading & Empty States

### Loading State

```
┌─────────────────────────────────────┐
│                                     │
│              ⏳                     │
│           Loading                   │
│      Please wait...                 │
│                                     │
└─────────────────────────────────────┘

Spinner: 40px, Primary color
Text: 14px, Grey 600
Center-aligned, vertical layout
```

### Empty State

```
┌─────────────────────────────────────┐
│                                     │
│              📭                     │
│       No Items Found                │
│   No data available to display      │
│                                     │
└─────────────────────────────────────┘

Icon: 64px, Grey 400
Title: 18px, Bold, Grey 700
Message: 14px, Regular, Grey 600
Center-aligned
```

### Error State

```
┌─────────────────────────────────────┐
│                                     │
│              ❌                     │
│        Something Went Wrong         │
│      Error message details here    │
│                                     │
│      ┌──────────────────┐          │
│      │   Retry          │          │
│      └──────────────────┘          │
│                                     │
└─────────────────────────────────────┘

Icon: 64px, Red
Title: 18px, Bold, Red 700
Message: 14px, Regular, Grey 700
Retry button: Primary style
Center-aligned
```

---

## Design Tokens

### Border Radius

```
Small:    8px   - Inputs, small buttons
Medium:   12px  - Cards, primary buttons
Large:    20px  - Chips, tags
Circular: 50%   - Avatar, icon buttons
```

### Elevation/Shadows

```
Level 1:  0px 1px 2px rgba(0,0,0,0.1)  - Subtle
Level 2:  0px 2px 4px rgba(0,0,0,0.1)  - Cards (default)
Level 3:  0px 4px 8px rgba(0,0,0,0.1)  - Hover states
Level 4:  0px 8px 16px rgba(0,0,0,0.1) - Modals, dropdowns
```

### Transitions

```
Fast:     150ms - Micro-interactions
Normal:   200ms - Button states
Standard: 300ms - Page transitions
Slow:     400ms - Modal animations
```

---

## Accessibility

### Color Contrast

```
✅ Primary on White:  4.5:1 (WCAG AA compliant)
✅ Black on White:    21:1 (WCAG AAA compliant)
✅ Status colors:     Sufficient contrast
```

### Focus States

```
Focused Element:
  ┌────────────────────────┐
  │   [Focused Input]      │  Border: 2px solid Primary
  └────────────────────────┘  Outline: 2px solid Primary (lighter)
                              Transition: 150ms
```

### Touch Targets

```
Mobile Minimum: 44x44px (iOS guidelines)
Desktop Minimum: 32x32px
Recommended: 48x48px for all platforms
```

---

## Implementation Notes

### CSS Classes (Auto-generated by Flutter)

Flutter generates optimized CSS automatically. No manual CSS required.

### Performance

- Use `const` constructors wherever possible
- Lazy load controllers with GetX
- Optimize image assets
- Enable code splitting (automatic)
- Use ListView.builder for long lists

### Browser Support

```
✅ Chrome (91+)
✅ Firefox (90+)
✅ Safari (14+)
✅ Edge (91+)

Requires:
  - Modern browser (2020+)
  - JavaScript enabled
  - Local storage enabled
  - Cookies enabled
```

---

## Design Checklist

When adding new screens/features:

- [ ] Use only 3-color palette (Sky Blue, White, Black)
- [ ] Add contextual icon colors only (Green/Red/Orange)
- [ ] Use 12px border radius for cards/buttons
- [ ] Use 2px elevation for cards
- [ ] Implement loading state
- [ ] Implement error state
- [ ] Implement empty state
- [ ] Make responsive (mobile/tablet/desktop)
- [ ] Add hover effects (desktop)
- [ ] Use consistent spacing (16px base)
- [ ] Follow typography hierarchy
- [ ] Ensure 44px minimum touch targets (mobile)

---

## 🎨 Design Philosophy

### Principles

1. **Simplicity**: Minimal 3-color palette
2. **Clarity**: Clear visual hierarchy
3. **Consistency**: Same patterns throughout
4. **Responsiveness**: Works on all devices
5. **Performance**: Fast and smooth
6. **Accessibility**: Usable by everyone

### Goals

- Create a premium, professional appearance
- Ensure intuitive user experience
- Maintain consistency across all screens
- Optimize for web performance
- Support all device types

---

**Design Status: ✅ Complete & Implemented**

All visual specifications have been implemented in the codebase following Flutter/Material Design guidelines with the custom AuraWealth theme.
