# Admin API Documentation

**Base URL:** `http://your-domain.com/admin`

**Authentication:** All endpoints except `/admin/login` require Bearer token authentication using admin JWT token.

---

## Table of Contents

1. [Authentication](#authentication)
2. [Price Management](#price-management)
3. [Transaction Management](#transaction-management)
4. [Buy In-Store](#buy-in-store)
5. [Messaging](#messaging)
6. [Error Responses](#error-responses)

---

## Authentication

### Login

Authenticate as admin to receive a JWT token.

**Endpoint:** `POST /admin/login`

**Authentication Required:** No

**Request Body (Form Data):**
```
username: salmanfarid43@gmail.com
password: salman12345
```

**Success Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Error Response (401):**
```json
{
  "detail": "Invalid admin credentials"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=salman12345"
```

---

## Price Management

### Set Gold Price

Set the current gold price per gram. Price is stored in database and cached in Redis.

**Endpoint:** `POST /admin/set-price`

**Authentication Required:** Yes (Admin JWT)

**Request Body:**
```json
{
  "price": 8500.00
}
```

**Success Response (200):**
```json
{
  "price": 8500.00,
  "bank_sell_price": 8245.00,
  "exchange_price": 6885.00,
  "store_sell_price": 7225.00,
  "created_at": "2026-03-05T10:00:00.000Z"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/set-price" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"price": 8500.00}'
```

---

### Get Current Gold Price

Retrieve the current gold price. Does not require Firebase token, only admin JWT.

**Endpoint:** `GET /admin/get-price`

**Authentication Required:** Yes (Admin JWT)

**Request Body:** None

**Success Response (200):**
```json
{
  "price": 8500.00,
  "bank_sell_price": 8245.00,
  "exchange_price": 6885.00,
  "store_sell_price": 7225.00,
  "created_at": "2026-03-05T10:00:00.000Z"
}
```

**Error Response (503):**
```json
{
  "detail": "Gold price has not been set yet. Contact admin."
}
```

**Usage:**
```bash
curl -X GET "http://localhost:8000/admin/get-price" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## Transaction Management

### Get All Transactions (Dashboard)

Retrieve all transactions with optional status filtering.

**Endpoint:** `GET /admin/dashboard`

**Authentication Required:** Yes (Admin JWT)

**Query Parameters:**
- `status` (optional): Filter by transaction status
  - `pending` - Transactions awaiting approval/rejection
  - `approved` - Transactions approved but not yet paid (need payment)
  - `paid` - Transactions that have been paid
  - `rejected` - Rejected transactions

**Request Body:** None

**Success Response (200):**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id": "123e4567-e89b-12d3-a456-426614174001",
    "type": "sell_to_bank",
    "grams": 10.00,
    "price_per_g_bdt": 8500.00,
    "deduction_rate": 0.0300,
    "amount_bdt": 82450.00,
    "status": "pending",
    "code": "ABC123",
    "code_generated_at": "2026-03-05T10:00:00.000Z",
    "code_expires_at": "2026-03-05T11:00:00.000Z",
    "created_at": "2026-03-05T10:00:00.000Z",
    "processed_at": null,
    "approved_at": null,
    "rejected_at": null,
    "rejected_by": null,
    "paid_at": null,
    "admin_note": null,
    "credited_by": null
  }
]
```

**Usage Examples:**

Get all transactions:
```bash
curl -X GET "http://localhost:8000/admin/dashboard" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Get pending transactions:
```bash
curl -X GET "http://localhost:8000/admin/dashboard?status=pending" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Get transactions needing payment:
```bash
curl -X GET "http://localhost:8000/admin/dashboard?status=approved" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Get paid transactions:
```bash
curl -X GET "http://localhost:8000/admin/dashboard?status=paid" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Approve Transaction

Approve a pending transaction. For sell/exchange transactions, this consumes the locked grams.

**Endpoint:** `POST /admin/{tx_id}/approve`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `tx_id` (required): Transaction ID (UUID)

**Request Body:**
```json
{
  "note": "Approved after verification"
}
```

Note: The `note` field is optional.

**Success Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "approved",
  "approved_at": "2026-03-05T10:30:00.000Z"
}
```

**Error Responses:**

404 - Transaction not found:
```json
{
  "detail": "Transaction not found"
}
```

400 - Invalid status:
```json
{
  "detail": "Only PENDING transactions can be approved"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/123e4567-e89b-12d3-a456-426614174000/approve" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"note": "Approved after verification"}'
```

---

### Reject Transaction

Reject a pending transaction. Locked grams are returned to user for sell/exchange transactions.

**Endpoint:** `POST /admin/{tx_id}/reject`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `tx_id` (required): Transaction ID (UUID)

**Request Body:**
```json
{
  "note": "Invalid bank account details"
}
```

Note: The `note` field is optional.

**Success Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "rejected",
  "rejected_at": "2026-03-05T10:30:00.000Z"
}
```

**Error Responses:**

404 - Transaction not found:
```json
{
  "detail": "Transaction not found"
}
```

400 - Invalid status:
```json
{
  "detail": "Only PENDING transactions can be rejected"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/123e4567-e89b-12d3-a456-426614174000/reject" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"note": "Invalid bank account details"}'
```

---

### Update Paid Status

Mark a transaction as paid or unpaid. This is bidirectional - can mark approved transactions as paid, or revert paid transactions back to approved.

**Endpoint:** `PUT /admin/{tx_id}/paid-status`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `tx_id` (required): Transaction ID (UUID)

**Request Body:**
```json
{
  "is_paid": true
}
```

- `is_paid: true` - Mark APPROVED transaction as PAID
- `is_paid: false` - Mark PAID transaction as APPROVED (unpaid)

**Success Response (200):**

When marking as paid:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "paid",
  "paid_at": "2026-03-05T10:45:00.000Z",
  "message": "Transaction marked as paid"
}
```

When marking as unpaid:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "approved",
  "paid_at": null,
  "message": "Transaction marked as unpaid"
}
```

**Error Responses:**

404 - Transaction not found:
```json
{
  "detail": "Transaction not found"
}
```

400 - Invalid status (when marking as paid):
```json
{
  "detail": "Only APPROVED transactions can be marked as paid"
}
```

400 - Invalid status (when marking as unpaid):
```json
{
  "detail": "Only PAID transactions can be marked as unpaid"
}
```

**Usage:**

Mark as paid:
```bash
curl -X PUT "http://localhost:8000/admin/123e4567-e89b-12d3-a456-426614174000/paid-status" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_paid": true}'
```

Mark as unpaid (revert):
```bash
curl -X PUT "http://localhost:8000/admin/123e4567-e89b-12d3-a456-426614174000/paid-status" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_paid": false}'
```

---

### Mark as Paid (Deprecated)

**[DEPRECATED]** Use `PUT /admin/{tx_id}/paid-status` instead for more flexibility.

Mark an approved transaction as paid (one-way only).

**Endpoint:** `POST /admin/{tx_id}/mark-as-paid`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `tx_id` (required): Transaction ID (UUID)

**Request Body:** None

**Success Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "paid",
  "paid_at": "2026-03-05T10:45:00.000Z"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/123e4567-e89b-12d3-a456-426614174000/mark-as-paid" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Redeem Transaction Code

Redeem a transaction code for store pickup. Auto-approves the transaction and consumes locked grams.

**Endpoint:** `POST /admin/redeem-code`

**Authentication Required:** Yes (Admin JWT)

**Query Parameters:**
- `code` (required): Transaction code (e.g., "ABC123")

**Request Body:** None

**Success Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "approved",
  "approved_at": "2026-03-05T10:30:00.000Z"
}
```

**Error Responses:**

404 - Code not found:
```json
{
  "detail": "Code not found"
}
```

400 - Transaction not pending:
```json
{
  "detail": "Transaction is not pending"
}
```

400 - Code expired:
```json
{
  "detail": "Code has expired"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/redeem-code?code=ABC123" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## Buy In-Store

### Credit User (In-Store Purchase)

Manually credit grams to user after verifying physical in-store purchase.

**Endpoint:** `POST /admin/buy/credit`

**Authentication Required:** Yes (Admin JWT)

**Request Body:**
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174001",
  "grams": 10.5
}
```

**Success Response (200):**
```json
{
  "tx_id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "approved",
  "user_id": "123e4567-e89b-12d3-a456-426614174001",
  "grams_credited": 10.5,
  "amount_charged_bdt": 96390.00,
  "fee_percent": 8.0,
  "fee_amount": 7140.00,
  "credited_by": "admin-uuid-here",
  "created_at": "2026-03-05T10:00:00.000Z"
}
```

**Response Fields:**
- `tx_id`: Created transaction ID
- `status`: Transaction status (always "approved" for in-store)
- `user_id`: User who received the credit
- `grams_credited`: Amount of gold grams credited
- `amount_charged_bdt`: Total amount charged including fees and VAT
- `fee_percent`: Fee percentage applied (8%)
- `fee_amount`: Fee amount in BDT
- `credited_by`: Admin user ID who performed the credit
- `created_at`: Transaction creation timestamp

**Error Responses:**

400 - Invalid grams amount:
```json
{
  "detail": "Minimum trade size is 0.5g"
}
```

400 - Invalid increment:
```json
{
  "detail": "Amount must be in 0.5g increments"
}
```

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/buy/credit" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "123e4567-e89b-12d3-a456-426614174001",
    "grams": 10.5
  }'
```

---

## Messaging

### Get Inbox Overview

Get overview of all user message threads with unread counts.

**Endpoint:** `GET /admin/messages`

**Authentication Required:** Yes (Admin JWT)

**Request Body:** None

**Success Response (200):**
```json
[
  {
    "user_id": "123e4567-e89b-12d3-a456-426614174001",
    "user_name": "John Doe",
    "last_message": "When will my transaction be approved?",
    "last_message_at": "2026-03-05T10:30:00.000Z",
    "unread_count": 2
  },
  {
    "user_id": "123e4567-e89b-12d3-a456-426614174002",
    "user_name": "Jane Smith",
    "last_message": "Thank you for the quick response",
    "last_message_at": "2026-03-05T09:15:00.000Z",
    "unread_count": 0
  }
]
```

**Response Fields:**
- `user_id`: User ID
- `user_name`: User's full name
- `last_message`: Text of the last message in thread
- `last_message_at`: Timestamp of last message
- `unread_count`: Number of unread messages from user to admin

**Usage:**
```bash
curl -X GET "http://localhost:8000/admin/messages" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Get User Message Thread

Retrieve all messages in a specific user's thread. Automatically marks user-to-admin messages as read.

**Endpoint:** `GET /admin/messages/{user_id}`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `user_id` (required): User ID (UUID)

**Query Parameters:**
- `limit` (optional, default: 50): Maximum number of messages to return (1-200)
- `offset` (optional, default: 0): Number of messages to skip (for pagination)

**Request Body:** None

**Success Response (200):**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174010",
    "direction": "user_to_admin",
    "body": "When will my transaction be approved?",
    "is_read": true,
    "created_at": "2026-03-05T10:30:00.000Z"
  },
  {
    "id": "123e4567-e89b-12d3-a456-426614174011",
    "direction": "admin_to_user",
    "body": "Your transaction will be processed within 24 hours.",
    "is_read": false,
    "created_at": "2026-03-05T10:35:00.000Z"
  }
]
```

**Response Fields:**
- `id`: Message ID
- `direction`: Message direction ("user_to_admin" or "admin_to_user")
- `body`: Message text content
- `is_read`: Whether message has been read
- `created_at`: Message creation timestamp

**Usage:**

Get first 50 messages:
```bash
curl -X GET "http://localhost:8000/admin/messages/123e4567-e89b-12d3-a456-426614174001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Get next 50 messages (pagination):
```bash
curl -X GET "http://localhost:8000/admin/messages/123e4567-e89b-12d3-a456-426614174001?limit=50&offset=50" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Send Message to User

Send a message from admin to a specific user.

**Endpoint:** `POST /admin/messages/{user_id}`

**Authentication Required:** Yes (Admin JWT)

**URL Parameters:**
- `user_id` (required): User ID (UUID)

**Request Body:**
```json
{
  "body": "Your transaction has been approved and will be processed shortly."
}
```

**Success Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174011",
  "direction": "admin_to_user",
  "body": "Your transaction has been approved and will be processed shortly.",
  "is_read": false,
  "created_at": "2026-03-05T10:35:00.000Z"
}
```

**Response Fields:**
- `id`: Created message ID
- `direction`: Always "admin_to_user"
- `body`: Message text content
- `is_read`: Always false initially (user hasn't read yet)
- `created_at`: Message creation timestamp

**Usage:**
```bash
curl -X POST "http://localhost:8000/admin/messages/123e4567-e89b-12d3-a456-426614174001" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Your transaction has been approved and will be processed shortly."
  }'
```

---

## Error Responses

### Common HTTP Status Codes

- **200 OK**: Request succeeded
- **400 Bad Request**: Invalid request parameters or business logic error
- **401 Unauthorized**: Missing or invalid authentication token
- **404 Not Found**: Resource not found
- **503 Service Unavailable**: Service temporarily unavailable

### Error Response Format

All errors follow this format:

```json
{
  "detail": "Error message describing what went wrong"
}
```

### Authentication Errors

**401 Unauthorized** - Missing token:
```json
{
  "detail": "Not authenticated"
}
```

**401 Unauthorized** - Invalid token:
```json
{
  "detail": "Invalid authentication credentials"
}
```

**401 Unauthorized** - Expired token:
```json
{
  "detail": "Token has expired"
}
```

### Validation Errors

**422 Unprocessable Entity** - Invalid request body:
```json
{
  "detail": [
    {
      "loc": ["body", "price"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## Complete Workflow Examples

### Example 1: Approve and Pay a Transaction

```bash
# Step 1: Login as admin
TOKEN=$(curl -X POST "http://localhost:8000/admin/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=salman12345" \
  | jq -r '.access_token')

# Step 2: Get pending transactions
curl -X GET "http://localhost:8000/admin/dashboard?status=pending" \
  -H "Authorization: Bearer $TOKEN"

# Step 3: Approve a transaction
TX_ID="123e4567-e89b-12d3-a456-426614174000"
curl -X POST "http://localhost:8000/admin/$TX_ID/approve" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"note": "Verified bank details"}'

# Step 4: Get approved transactions (need payment)
curl -X GET "http://localhost:8000/admin/dashboard?status=approved" \
  -H "Authorization: Bearer $TOKEN"

# Step 5: Mark transaction as paid after bank transfer
curl -X PUT "http://localhost:8000/admin/$TX_ID/paid-status" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_paid": true}'
```

---

### Example 2: Handle In-Store Purchase

```bash
# Step 1: Login as admin
TOKEN=$(curl -X POST "http://localhost:8000/admin/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=salman12345" \
  | jq -r '.access_token')

# Step 2: Credit user for in-store purchase
USER_ID="123e4567-e89b-12d3-a456-426614174001"
curl -X POST "http://localhost:8000/admin/buy/credit" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "'$USER_ID'",
    "grams": 10.5
  }'
```

---

### Example 3: Handle Customer Support Message

```bash
# Step 1: Login as admin
TOKEN=$(curl -X POST "http://localhost:8000/admin/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=salmanfarid43@gmail.com&password=salman12345" \
  | jq -r '.access_token')

# Step 2: Get inbox overview
curl -X GET "http://localhost:8000/admin/messages" \
  -H "Authorization: Bearer $TOKEN"

# Step 3: Read user's message thread
USER_ID="123e4567-e89b-12d3-a456-426614174001"
curl -X GET "http://localhost:8000/admin/messages/$USER_ID" \
  -H "Authorization: Bearer $TOKEN"

# Step 4: Reply to user
curl -X POST "http://localhost:8000/admin/messages/$USER_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Your transaction has been approved and will be processed shortly."
  }'
```

---

## Transaction Status Flow

```
PENDING ──┬──> APPROVED ──> PAID
          │         ↑         │
          │         └─────────┘ (can revert)
          │
          └──> REJECTED
```

### Status Transitions

| From | To | Endpoint | Admin Action |
|------|-----|----------|--------------|
| pending | approved | POST /{tx_id}/approve | Approve transaction |
| pending | rejected | POST /{tx_id}/reject | Reject transaction |
| approved | paid | PUT /{tx_id}/paid-status | Mark as paid |
| paid | approved | PUT /{tx_id}/paid-status | Mark as unpaid (revert) |

### Status Descriptions

- **pending**: Transaction created, awaiting admin approval/rejection
- **approved**: Transaction approved, awaiting payment
- **paid**: Transaction paid (bank transfer completed)
- **rejected**: Transaction rejected by admin

---

## Rate Limits

Currently, there are no rate limits enforced on admin endpoints. However, please use the API responsibly.

---

## Support

For technical support or API questions, contact the development team.

---

**Last Updated:** March 5, 2026

