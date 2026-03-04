# Pakashona — API Backend Documentation

**Digital Gold Investment Platform** · FastAPI · PostgreSQL · Redis · Firebase Auth  
_Last updated: 2026-03-04_

> 24K gold only · Minimum trade: **0.5 g increments** · Minimum physical pickup: **5.0 g**

---

## Table of Contents

1. [Overview](#1-overview)
2. [Quick Reference — All Endpoints](#2-quick-reference)
3. [Business Rules & Fees](#3-business-rules--fees)
4. [Authentication](#4-authentication)
5. [User Endpoints](#5-user-endpoints)
6. [Admin Endpoints](#6-admin-endpoints)
7. [Wallet Endpoints](#7-wallet-endpoints)
8. [Pricing Endpoints](#8-pricing-endpoints)
9. [Error Reference](#9-error-reference)
10. [Data Shapes](#10-data-shapes)
11. [Setup & Installation](#11-setup--installation)
12. [Environment Variables](#12-environment-variables)
13. [Database Migrations](#13-database-migrations)
14. [Deployment (Heroku)](#14-deployment-heroku)
15. [Tech Stack](#15-tech-stack)

---

## 1. Overview

Pakashona is a RESTful JSON API for managing 24K digital gold accounts.

- Users authenticate via **Firebase** (phone OTP / Google).
- All gold amounts are stored and validated to **0.5 g precision**.
- Prices are set **manually by admins** (no live feed in MVP).
- Sell/exchange transactions go through an **admin approval** flow.
- Buy transactions are **auto-approved** on receipt of payment confirmation.
- Admin and user can exchange support messages through a simple **inbox**.

---

## 2. Quick Reference

### User Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/firebase-login` | Public | Login / register via Firebase token |
| `GET` | `/user/dashboard` | User | Wallet balance, price, gamification level |
| `GET` | `/user/pending-transactions` | User | All your PENDING transactions |
| `POST` | `/user/buy/online?grams=` | User | Buy gold online — auto-credited immediately |
| `POST` | `/user/sell/bank?grams=` | User | Sell to bank (2 % fee, 3–5 day settlement) |
| `POST` | `/user/sell/store?grams=` | User | Sell at store (17 % fee, generates code) |
| `POST` | `/user/exchange?grams=` | User | Exchange for jewellery (10 % fee, generates code, min 5 g) |
| `GET` | `/user/transactions/buy` | User | Buy history (paginated, filterable) |
| `GET` | `/user/transactions/sell` | User | Sell history |
| `GET` | `/user/transactions/exchange` | User | Exchange history |
| `GET` | `/user/transactions/{tx_id}` | User | Single transaction detail |
| `POST` | `/user/{tx_id}/cancel` | User | Cancel SELL_TO_STORE or EXCHANGE (PENDING only) |
| `POST` | `/user/messages` | User | Send message to admin support |
| `GET` | `/user/messages` | User | Read your full conversation thread |

### Admin Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/admin/login` | **Public** | Login with email + password → returns Bearer token |
| `POST` | `/admin/set-price` | Admin | Set gold price per gram |
| `GET` | `/admin/dashboard` | Admin | All transactions (filterable by status) |
| `POST` | `/admin/buy/credit` | Admin | Credit grams after in-store purchase |
| `POST` | `/admin/redeem-code?code=` | Admin | Approve store/exchange by redemption code |
| `GET` | `/admin/messages` | Admin | Inbox overview — all user threads + unread counts |
| `GET` | `/admin/messages/{user_id}` | Admin | Read a user's thread |
| `POST` | `/admin/messages/{user_id}` | Admin | Reply to a user |
| `POST` | `/admin/{tx_id}/mark-as-paid` | Admin | Mark APPROVED bank-sell as PAID |
| `POST` | `/admin/{tx_id}/reject` | Admin | Reject a PENDING transaction |

### Wallet & Pricing
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/prices` | User | Current gold price |
| `POST` | `/wallet/lock` | User | Lock grams (internal use) |
| `POST` | `/wallet/release` | User | Release locked grams |
| `POST` | `/wallet/consume` | User | Consume locked grams |

---

## 3. Business Rules & Fees

### Validation Rules (all enforced server-side)
| Rule | Detail |
|------|--------|
| Gold type | 24K only |
| Minimum trade unit | **0.5 g** — amount must be a multiple of 0.5, else `400` |
| Minimum trade size | **0.5 g** |
| Minimum physical pickup | **5.0 g** for `exchange` — else `400` |
| Sufficient balance | `available_grams >= grams` for any sell/exchange — else `400` |
| Pending bank-sell block | Only **one** pending `SELL_TO_BANK` at a time. A pending bank-sell blocks new `SELL_TO_BANK`, `SELL_TO_STORE`, and `EXCHANGE` until cancelled or approved |

### Fee Table
| Action | Fee | Settlement | How approved |
|--------|-----|------------|--------------|
| Buy Online | 8 % of gold value + 7.5 % VAT on that fee | Instant | Auto on payment gateway callback |
| Buy In-Store | Same 8 % + VAT | Instant | Admin calls `POST /admin/buy/credit` |
| Sell to Bank | 2 % deducted from payout | 3–5 business days | Admin calls `mark-as-paid` |
| Sell to Store | 17 % deducted | At store | Admin redeems code |
| Exchange (Jewellery) | 10 % deducted | At store | Admin redeems code |

**Buy fee formula:**
```
raw_cost   = price_per_g × grams
fee        = raw_cost × 0.08
vat        = fee × 0.075
total_paid = raw_cost + fee + vat
```

### Transaction Status Flow
```
PENDING  ──(admin approves / code redeemed)──▶  APPROVED  ──(admin marks paid)──▶  PAID
PENDING  ──(admin or user cancels)───────────▶  REJECTED
```

| Status | Meaning |
|--------|---------|
| `PENDING` | Awaiting admin action; grams are locked |
| `APPROVED` | Approved by admin / code redeemed |
| `PAID` | Bank payment sent |
| `REJECTED` | Cancelled by admin or user; locked grams returned |

### Transaction Types
| Type | Triggered by |
|------|-------------|
| `BUY_IN_APP` | `POST /user/buy/online` |
| `BUY_IN_STORE` | `POST /admin/buy/credit` |
| `SELL_TO_BANK` | `POST /user/sell/bank` |
| `SELL_TO_STORE` | `POST /user/sell/store` |
| `EXCHANGE_TO_JEWELLERY` | `POST /user/exchange` |

---

## 4. Authentication

### User Authentication (Firebase)

All **user** endpoints except `/auth/firebase-login` require:
```
Authorization: Bearer <firebase_id_token>
```

---

### Admin Authentication (Email + Password)

Admin endpoints use a **separate, simple login** — no Firebase involved.

#### Step 1 — Login

```
POST /admin/login
Content-Type: application/x-www-form-urlencoded

username=salmanfarid43@gmail.com&password=salman12345
```

> ⚠️ This is a standard OAuth2 password form — use `username` field for the email address.

**Response `200`:**
```json
{
  "access_token": "<jwt_token>",
  "token_type": "bearer"
}
```

Token is valid for **12 hours**.

#### Step 2 — Use the token on all admin endpoints

```
Authorization: Bearer <jwt_token>
```

All `POST /admin/*` and `GET /admin/*` routes require this header.

---

### `POST /auth/firebase-login`

Verify a Firebase ID token. Creates the user + wallet on first call.

**Request body:**
```json
{ "firebase_token": "<firebase_id_token>" }
```

**Response `200`:**
```json
{
  "user_id": "9906ee14-a591-4d00-b75f-9d535db60588",
  "firebase_uid": "abc123uid",
  "email": "user@example.com",
  "created_at": "2026-03-02T08:00:00+00:00",
  "phone_verified": true,
  "kyc_status": "pending"
}
```

---

## 5. User Endpoints

All require `Authorization: Bearer <firebase_id_token>`.

---

### `GET /user/dashboard`

Returns wallet state, live gold price, and gamification level.

**Response `200`:**
```json
{
  "wallet": {
    "total_grams": 25.5,
    "locked_grams": 5.0,
    "available_grams": 20.5
  },
  "current_gold_price": 5200.00,
  "level": {
    "name": "Necklace",
    "min_grams": 10,
    "next_level_at_grams": 20
  }
}
```

> `current_gold_price` is `null` if admin has not set a price yet. All buy/sell/exchange endpoints return `503` in that case.

**Errors:** `404` wallet not found (should never happen for a valid user)

---

### `GET /user/pending-transactions`

All PENDING transactions for the logged-in user across all types.

**Response `200`:** Array of [Transaction List Items](#transaction-list-item).

---

### `POST /user/buy/online?grams={g}`

Call this **after** your payment gateway confirms the charge. Grams are credited instantly.

| Param | Type | Validation |
|-------|------|------------|
| `grams` | float (query) | ≥ 0.5, multiple of 0.5 |

**Response `200`:**
```json
{
  "tx_id": "a1b2c3d4-e5f6-...",
  "status": "APPROVED",
  "grams_credited": 5.0,
  "amount_paid_bdt": 28080.00,
  "fee_percent": 8.0,
  "fee_amount": 2080.00,
  "created_at": "2026-03-02T08:00:00Z"
}
```

**Errors:** `400` bad grams · `503` no price set

---

### `POST /user/sell/bank?grams={g}`

Sell gold to bank. Grams are locked. Admin pays out in 3–5 days. **2 % fee** deducted.

| Param | Type | Validation |
|-------|------|------------|
| `grams` | float (query) | ≥ 0.5, multiple of 0.5, ≤ available balance |

**Response `200`:**
```json
{
  "tx_id": "uuid",
  "status": "PENDING",
  "grams_locked": 5.0,
  "tx_amount_to_be_received": 25480.00,
  "expiry_time": null
}
```

**Errors:** `400` insufficient grams · `400` pending bank-sell already exists

---

### `POST /user/sell/store?grams={g}`

Sell at physical store. Returns a **6-character redemption code** (expires in 60 min). **17 % fee** deducted.

**Response `200`:**
```json
{
  "tx_id": "uuid",
  "status": "PENDING",
  "grams_locked": 5.0,
  "tx_amount_to_be_received": 21580.00,
  "expiry_time": "2026-03-02T09:00:00Z",
  "code": "A3X9KL"
}
```

---

### `POST /user/exchange?grams={g}`

Exchange digital gold for physical jewellery. Returns a redemption code. **10 % fee** deducted. Minimum **5.0 g**.

**Response `200`:**
```json
{
  "tx_id": "uuid",
  "status": "PENDING",
  "grams_locked": 10.0,
  "tx_amount_to_be_received": 46800.00,
  "expiry_time": "2026-03-02T09:00:00Z",
  "code": "B7M2QP"
}
```

**Errors:** `400` below 5 g minimum · `400` pending bank-sell blocks request

---

### `GET /user/transactions/buy`
### `GET /user/transactions/sell`
### `GET /user/transactions/exchange`

Paginated transaction history by type group.

| Query param | Default | Description |
|-------------|---------|-------------|
| `status` | (all) | Filter: `pending` `approved` `paid` `rejected` |
| `limit` | `20` | 1–100 |
| `offset` | `0` | Pagination |

**Response `200`:** Array of [Transaction List Items](#transaction-list-item).

---

### `GET /user/transactions/{tx_id}`

Full detail for a single transaction owned by the current user.

**Response `200`:** [Transaction Detail](#transaction-detail).

**Errors:** `404` not found or not yours

---

### `POST /user/{tx_id}/cancel`

Cancel a **PENDING** `SELL_TO_STORE` or `EXCHANGE_TO_JEWELLERY`. Locked grams are returned immediately.

> `SELL_TO_BANK` cannot be cancelled by the user — contact admin.

**Response `200`:**
```json
{
  "id": "uuid",
  "status": "REJECTED",
  "released_grams": 5.0
}
```

**Errors:** `403` not your transaction · `400` wrong type · `400` not pending

---

### `POST /user/messages`

Send a support message to admin.

**Request body:**
```json
{ "body": "Hi, I have a question about my pending order." }
```

**Response `200`:** [Message Object](#message-object).

---

### `GET /user/messages?limit=50&offset=0`

Fetch the full conversation thread (both directions), ordered oldest-first.  
Admin-to-user messages are automatically marked as read.

**Response `200`:** Array of [Message Objects](#message-object).

---

## 6. Admin Endpoints

All require `Authorization: Bearer <token>` from a user with `is_admin = true`.

---

### `POST /admin/set-price`

Set the gold market price per gram (BDT). Stored in DB, cached in Redis.

**Request body:**
```json
{ "price": 5200.00 }
```

**Response `200`:**
```json
{
  "price": 5200.00,
  "bank_sell_price": 5096.00,
  "exchange_price": 4680.00,
  "store_sell_price": 4316.00,
  "created_at": "2026-03-02T08:00:00Z"
}
```

> **Calculated prices:**
> - `bank_sell_price`: market price - 2% (for SELL_TO_BANK)
> - `exchange_price`: market price - 10% (for EXCHANGE_TO_JEWELLERY)
> - `store_sell_price`: market price - 17% (for SELL_TO_STORE)

---

### `GET /admin/dashboard?status=`

All transactions across all users. Optional `status` filter.

| Query param | Values |
|-------------|--------|
| `status` | `pending` `approved` `paid` `rejected` (omit for all) |

**Response `200`:** Array of [Transaction Detail](#transaction-detail) objects.

---

### `POST /admin/buy/credit`

Manually credit grams to a user after verifying an in-store purchase. Instantly creates an `APPROVED` `BUY_IN_STORE` transaction and adds grams to the user's wallet.

**Request body:**
```json
{
  "user_id": "9906ee14-a591-4d00-b75f-9d535db60588",
  "grams": 5.0
}
```

**Response `200`:**
```json
{
  "tx_id": "uuid",
  "status": "APPROVED",
  "user_id": "uuid",
  "grams_credited": 5.0,
  "amount_charged_bdt": 28080.00,
  "fee_percent": 8.0,
  "fee_amount": 2080.00,
  "credited_by": "admin-uuid",
  "created_at": "2026-03-02T08:00:00Z"
}
```

---

### `POST /admin/redeem-code?code={code}`

Approve a `SELL_TO_STORE` or `EXCHANGE_TO_JEWELLERY` by its redemption code.  
Consumes locked grams and marks transaction `APPROVED`.

**Response `200`:**
```json
{
  "id": "uuid",
  "status": "APPROVED",
  "approved_at": "2026-03-02T10:00:00Z"
}
```

**Errors:** `404` code not found · `400` not pending · `400` code expired

---

### `GET /admin/messages`

Inbox overview — all users with unread counts, sorted by last activity.

**Response `200`:**
```json
[
  {
    "user_id": "uuid",
    "user_name": "Jane Doe",
    "last_message": "Hi, question about my sell order.",
    "last_message_at": "2026-03-02T08:00:00Z",
    "unread_count": 2
  }
]
```

---

### `GET /admin/messages/{user_id}?limit=50&offset=0`

Read a user's full thread. Marks all `user_to_admin` messages as read.

**Response `200`:** Array of [Message Objects](#message-object).

---

### `POST /admin/messages/{user_id}`

Reply to a user.

**Request body:**
```json
{ "body": "Hello! Your order is under review." }
```

**Response `200`:** [Message Object](#message-object).

---

### `POST /admin/{tx_id}/mark-as-paid`

Mark an `APPROVED` `SELL_TO_BANK` transaction as `PAID` (bank transfer sent).

**Response `200`:**
```json
{
  "id": "uuid",
  "status": "PAID",
  "paid_at": "2026-03-05T10:00:00Z"
}
```

**Errors:** `404` not found · `400` not in APPROVED status

---

### `POST /admin/{tx_id}/reject`

Reject a `PENDING` transaction. Locked grams are returned to the user's available balance (for sell/exchange). Optional admin note.

**Request body (optional):**
```json
{ "note": "Insufficient documentation." }
```

**Response `200`:**
```json
{
  "id": "uuid",
  "status": "REJECTED",
  "rejected_at": "2026-03-02T09:30:00Z"
}
```

**Errors:** `404` not found · `400` not in PENDING status

---

## 7. Wallet Endpoints

Direct wallet manipulation. These are called internally by buy/sell/exchange routes and are also exposed for direct use.

All require `Authorization: Bearer <token>`.

### `POST /wallet/lock`
Lock grams (reserve for a pending transaction).

**Body:** `{ "grams": 5.0 }`  
**Response:** `{ "total_grams": 25.0, "locked_grams": 10.0 }`

### `POST /wallet/release`
Release previously locked grams back to available balance.

**Body:** `{ "grams": 5.0 }`  
**Response:** `{ "total_grams": 25.0, "locked_grams": 5.0 }`

### `POST /wallet/consume`
Consume locked grams — subtracts from both `locked_grams` and `total_grams`.

**Body:** `{ "grams": 5.0 }`  
**Response:** `{ "total_grams": 20.0, "locked_grams": 0.0 }`

---

## 8. Pricing Endpoints

### `GET /prices`

**Response `200`:**
```json
{
  "price": 5200.00,
  "bank_sell_price": 5096.00,
  "exchange_price": 4680.00,
  "store_sell_price": 4316.00,
  "created_at": "2026-03-02T08:00:00Z"
}
```

**Errors:** `503` price not yet configured by admin

> Price is set manually by admin via `POST /admin/set-price`. Cached in Redis.
> 
> **Calculated prices:**
> - `bank_sell_price`: market price - 2% (what users receive for SELL_TO_BANK)
> - `exchange_price`: market price - 10% (what users receive for EXCHANGE_TO_JEWELLERY)
> - `store_sell_price`: market price - 17% (what users receive for SELL_TO_STORE)

---

## 9. Error Reference

| HTTP Code | Meaning |
|-----------|---------|
| `400` | Validation error (bad grams, insufficient balance, wrong state) |
| `401` | Missing or invalid Firebase token |
| `403` | Authenticated but not authorized (e.g. non-admin on admin route) |
| `404` | Resource not found |
| `503` | Gold price not configured (set it via `POST /admin/set-price`) |

All errors return:
```json
{ "detail": "Human-readable error message" }
```

---

## 10. Data Shapes

### Transaction List Item
```json
{
  "id": "uuid",
  "type": "BUY_IN_APP | BUY_IN_STORE | SELL_TO_BANK | SELL_TO_STORE | EXCHANGE_TO_JEWELLERY",
  "status": "PENDING | APPROVED | PAID | REJECTED",
  "grams": 5.0,
  "amount_bdt": 28080.00,
  "fee_percent": 8.6,
  "fee_amount": 2080.00,
  "code": null,
  "expiry_time": null,
  "created_at": "2026-03-02T08:00:00Z"
}
```

### Transaction Detail
_(everything above, plus:)_
```json
{
  "approved_at": "2026-03-02T08:00:01Z",
  "paid_at": null,
  "rejected_at": null,
  "admin_note": null
}
```

### Message Object
```json
{
  "id": "uuid",
  "direction": "user_to_admin | admin_to_user",
  "body": "string",
  "is_read": false,
  "created_at": "2026-03-02T08:00:00Z"
}
```

### Wallet Object
```json
{
  "total_grams": 25.5,
  "locked_grams": 5.0,
  "available_grams": 20.5
}
```

### Gamification Levels
| Level Name | Minimum grams |
|-----------|--------------|
| Nosepin | 0 g |
| Ring | 1 g |
| Bangle | 5 g |
| Necklace | 10 g |
| Chain | 20 g |

---

## 11. Setup & Installation

### Prerequisites
- Python 3.10+
- PostgreSQL 12+
- Redis 6+
- Firebase project with a service account key

### Steps

```bash
# 1. Clone and enter
git clone <repo-url>
cd backend-system

# 2. Virtual environment
python -m venv venv
source venv/bin/activate      # macOS / Linux
# venv\Scripts\activate       # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Copy and fill in .env  (see §12)
cp .env.example .env

# 5. Apply database migrations
alembic upgrade head

# 6. Start Redis
redis-server

# 7. Run dev server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Docs:** http://localhost:8000/docs · http://localhost:8000/redoc  
**Health:** http://localhost:8000/health

---

## 12. Environment Variables

Create `.env` in the project root:

```env
# ── Database ──────────────────────────────────────────────────────────────────
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/pakashona

# ── Firebase ──────────────────────────────────────────────────────────────────
FIREBASE_PROJECT_ID=your-firebase-project-id

# Local dev: path to downloaded service-account JSON
FIREBASE_SERVICE_ACCOUNT_PATH=assets/your-firebase-adminsdk.json

# Heroku / production: paste the entire JSON as a single-line string
# FIREBASE_CREDENTIALS_JSON={"type":"service_account","project_id":"..."}

# ── JWT (internal) ────────────────────────────────────────────────────────────
JWT_SECRET=change-me-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080   # 7 days

# ── CORS ──────────────────────────────────────────────────────────────────────
ALLOWED_ORIGINS=http://localhost:3000,https://yourapp.com
```

> Business rule constants (fee rates, minimum grams) live in `app/core/config.py` and **do not** need env vars.

---

## 13. Database Migrations

```bash
# Apply all pending migrations (run on every deploy)
alembic upgrade head

# Auto-generate a new migration after model changes
alembic revision --autogenerate -m "describe change"

# Rollback one step
alembic downgrade -1

# View full history
alembic history --verbose
```

### Migration History
| Revision | Description |
|----------|-------------|
| `a00adea975a0` | Initial schema |
| `587f8ff16d4b` | Create core tables |
| `37a6a4fcbf5e` | Add admin fields to users |
| `7127b624909e` | Rename wallet fields |
| `7c5ebdb91e62` | Update transactions table |
| `50a251a38b31` | Add `rejected_by` to transactions |
| `d6676fdf58d4` | Add `firebase_uid` to users |
| `e8a3f2c91b05` | Add `messages` table; add `admin_note`, `credited_by` to transactions ← **HEAD** |

---

## 14. Deployment (Heroku)

### Live URLs
| | URL |
|---|---|
| **API Base** | `https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com` |
| **Swagger UI** | `https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/docs` |
| **Health** | `https://aurawelath-fast-api-backend-576ef7ef3e27.herokuapp.com/health` |
min 
### App Info
| | |
|---|---|
| **Heroku app** | `aurawelath-fast-api-backend` |
| **Region** | us |
| **Stack** | heroku-24 |
| **Add-ons** | heroku-postgresql:essential-0, heroku-redis:mini |
| **Current release** | v27 (2026-03-02) |

### Deploy a new version
```bash
# Stage and commit your changes
git add -A
git commit -m "your message"

# Push to Heroku (migrations run automatically via release phase)
git push heroku main

# Also push to GitHub
git push origin main
```

Migrations run automatically on every deploy via `release.sh` (`alembic upgrade head`).

### One-time setup (new environment)
```bash
heroku login
heroku create your-app-name
heroku addons:create heroku-postgresql:essential-0
heroku addons:create heroku-redis:mini
heroku config:set FIREBASE_PROJECT_ID=your-project-id
heroku config:set JWT_SECRET=your-secret
heroku config:set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'
heroku config:set ALLOWED_ORIGINS=https://yourfrontend.com
git push heroku main
```

Or use the included interactive script:
```bash
chmod +x deploy.sh && ./deploy.sh
```

---

## 15. Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Python 3.10+ |
| Framework | FastAPI 0.100+ |
| Database | PostgreSQL 12+ — async via `asyncpg` |
| ORM | SQLAlchemy 2.0 (async) |
| Migrations | Alembic |
| Cache | Redis 6+ |
| Auth | Firebase Admin SDK |
| ASGI server | Uvicorn |
| Deployment | Heroku |

---

_© Pakashona — Proprietary. All rights reserved._
