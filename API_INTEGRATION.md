# API Integration Reference

This document details how each Admin API endpoint is integrated into the admin panel.

## 🔐 Authentication

### POST /admin/login

**Used in:** `AuthController.login()`  
**File:** `lib/controllers/auth_controller.dart`

```dart
Future<void> login(String email, String password) async {
  final response = await _apiService.adminLogin(email, password);
  final token = response['access_token'];
  await _storage.saveAuthToken(token);
  // Navigate to dashboard
}
```

**API Implementation:** `lib/services/api_service.dart`
```dart
Future<Map<String, dynamic>> adminLogin(String email, String password) async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/login');
  final body = 'username=$email&password=$password';  // OAuth2 format
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: body,
  );
  
  return _handleResponse(response);
}
```

**Request Format:**
```
POST /admin/login
Content-Type: application/x-www-form-urlencoded

username=admin@example.com&password=yourpassword
```

**Response:**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer"
}
```

**UI:** `lib/views/auth/login_screen.dart`

---

## 📊 Dashboard

### GET /admin/dashboard

**Used in:** `DashboardController.loadDashboardData()`  
**File:** `lib/controllers/dashboard_controller.dart`

```dart
Future<void> loadDashboardData() async {
  final allTransactionsData = await _apiService.getAdminDashboard();
  final allTransactions = allTransactionsData
      .map((json) => Transaction.fromJson(json))
      .toList();
  
  // Calculate statistics from transactions
  totalTransactions.value = allTransactions.length;
  totalBuyTransactions.value = allTransactions
      .where((t) => t.type.contains('BUY'))
      .length;
  // ... more calculations
}
```

**API Implementation:**
```dart
Future<List<dynamic>> getAdminDashboard({String? status}) async {
  var url = '${AppConstants.baseUrl}/admin/dashboard';
  if (status != null && status.isNotEmpty) {
    url += '?status=$status';
  }
  
  final response = await http.get(
    Uri.parse(url),
    headers: _getHeaders(),  // Includes Bearer token
  );
  
  return await _handleResponse(response) as List<dynamic>;
}
```

**Query Parameters:**
- `status` (optional): `pending`, `approved`, `paid`, `rejected`

**Response:** Array of Transaction objects

**UI:** `lib/views/dashboard/dashboard_screen.dart`

---

## 💰 Gold Price Management

### GET /prices

**Used in:** `GoldController.loadCurrentPrice()`  
**File:** `lib/controllers/gold_controller.dart`

```dart
Future<void> loadCurrentPrice() async {
  final data = await _apiService.getGoldPrice();
  currentPrice.value = GoldPrice.fromJson(data);
}
```

**Response:**
```json
{
  "price": 5200.00,
  "bank_sell_price": 5096.00,
  "exchange_price": 4680.00,
  "store_sell_price": 4316.00,
  "created_at": "2026-03-02T08:00:00Z"
}
```

**UI:** `lib/views/gold_management/gold_management_screen.dart`

### POST /admin/set-price

**Used in:** `GoldController.updatePrice()`  
**File:** `lib/controllers/gold_controller.dart`

```dart
Future<void> updatePrice(double newPrice) async {
  final data = await _apiService.setGoldPrice(newPrice);
  currentPrice.value = GoldPrice.fromJson(data);
  Get.snackbar('Success', 'Gold price updated successfully');
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> setGoldPrice(double price) async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/set-price');
  final body = json.encode({'price': price});
  
  final response = await http.post(
    url,
    headers: _getHeaders(),  // Includes Bearer token
    body: body,
  );
  
  return _handleResponse(response);
}
```

**Request:**
```json
POST /admin/set-price
Authorization: Bearer <token>
Content-Type: application/json

{
  "price": 5200.00
}
```

**Response:** Same as GET /prices

**UI:** `lib/views/gold_management/gold_management_screen.dart`

---

## 💳 Transaction Actions

### POST /admin/buy/credit

**Used in:** `CreditGramsScreen._creditGrams()`  
**File:** `lib/views/transactions/credit_grams_screen.dart`

```dart
Future<void> _creditGrams() async {
  final userId = _userIdController.text.trim();
  final grams = double.parse(_gramsController.text.trim());
  
  final response = await _apiService.creditGrams(userId, grams);
  
  Get.snackbar('Success', 'Successfully credited grams');
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> creditGrams(String userId, double grams) async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/buy/credit');
  final body = json.encode({
    'user_id': userId,
    'grams': grams,
  });
  
  final response = await http.post(url, headers: _getHeaders(), body: body);
  return _handleResponse(response);
}
```

**Request:**
```json
POST /admin/buy/credit
Authorization: Bearer <token>

{
  "user_id": "uuid",
  "grams": 5.0
}
```

**Response:**
```json
{
  "tx_id": "uuid",
  "status": "APPROVED",
  "grams_credited": 5.0,
  "amount_charged_bdt": 28080.00,
  "fee_percent": 8.0,
  "fee_amount": 2080.00,
  "created_at": "2026-03-02T08:00:00Z"
}
```

**UI:** `lib/views/transactions/credit_grams_screen.dart`

### POST /admin/redeem-code

**Used in:** `RedeemCodeScreen._redeemCode()`  
**File:** `lib/views/transactions/redeem_code_screen.dart`

```dart
Future<void> _redeemCode() async {
  final code = _codeController.text.trim().toUpperCase();
  final response = await _apiService.redeemCode(code);
  Get.snackbar('Success', 'Code redeemed successfully!');
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> redeemCode(String code) async {
  final url = Uri.parse(
    '${AppConstants.baseUrl}/admin/redeem-code?code=$code'
  );
  
  final response = await http.post(url, headers: _getHeaders());
  return _handleResponse(response);
}
```

**Request:**
```
POST /admin/redeem-code?code=A3X9KL
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "uuid",
  "status": "APPROVED",
  "approved_at": "2026-03-02T10:00:00Z"
}
```

**UI:** `lib/views/transactions/redeem_code_screen.dart`

### POST /admin/{tx_id}/mark-as-paid

**Used in:** `TransactionController.markAsPaid()`  
**File:** `lib/controllers/transaction_controller.dart`

```dart
Future<void> markAsPaid(String txId) async {
  await _apiService.markAsPaid(txId);
  Get.snackbar('Success', 'Transaction marked as paid');
  loadTransactions();  // Refresh list
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> markAsPaid(String txId) async {
  final url = Uri.parse(
    '${AppConstants.baseUrl}/admin/$txId/mark-as-paid'
  );
  
  final response = await http.post(url, headers: _getHeaders());
  return _handleResponse(response);
}
```

**Request:**
```
POST /admin/abc123-uuid/mark-as-paid
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "uuid",
  "status": "PAID",
  "paid_at": "2026-03-05T10:00:00Z"
}
```

**UI:** `lib/views/transactions/transactions_screen.dart` - Action button in transaction list

### POST /admin/{tx_id}/reject

**Used in:** `TransactionController.rejectTransaction()`  
**File:** `lib/controllers/transaction_controller.dart`

```dart
Future<void> rejectTransaction(String txId, {String? note}) async {
  await _apiService.rejectTransaction(txId, note: note);
  Get.snackbar('Success', 'Transaction rejected');
  loadTransactions();
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> rejectTransaction(
    String txId, {String? note}) async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/$txId/reject');
  final body = note != null ? json.encode({'note': note}) : '';
  
  final response = await http.post(url, headers: _getHeaders(), body: body);
  return _handleResponse(response);
}
```

**Request:**
```json
POST /admin/abc123-uuid/reject
Authorization: Bearer <token>

{
  "note": "Insufficient documentation"  // Optional
}
```

**Response:**
```json
{
  "id": "uuid",
  "status": "REJECTED",
  "rejected_at": "2026-03-02T09:30:00Z"
}
```

**UI:** `lib/views/transactions/transactions_screen.dart` - Reject button with dialog

---

## 💬 Messaging

### GET /admin/messages

**Used in:** `MessageController.loadMessageThreads()`  
**File:** `lib/controllers/message_controller.dart`

```dart
Future<void> loadMessageThreads() async {
  final data = await _apiService.getMessageThreads();
  messageThreads.value = data
      .map((json) => MessageThread.fromJson(json))
      .toList();
}
```

**API Implementation:**
```dart
Future<List<dynamic>> getMessageThreads() async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/messages');
  final response = await http.get(url, headers: _getHeaders());
  return await _handleResponse(response) as List<dynamic>;
}
```

**Response:**
```json
[
  {
    "user_id": "uuid",
    "user_name": "Jane Doe",
    "last_message": "Hi, question about my order.",
    "last_message_at": "2026-03-02T08:00:00Z",
    "unread_count": 2
  }
]
```

**UI:** `lib/views/messages/messages_screen.dart` - Inbox list

### GET /admin/messages/{user_id}

**Used in:** `MessageController.loadUserMessages()`  
**File:** `lib/controllers/message_controller.dart`

```dart
Future<void> loadUserMessages(String userId) async {
  final data = await _apiService.getUserMessages(userId);
  currentThreadMessages.value = data
      .map((json) => Message.fromJson(json))
      .toList();
}
```

**API Implementation:**
```dart
Future<List<dynamic>> getUserMessages(
    String userId, {int? limit, int? offset}) async {
  var url = '${AppConstants.baseUrl}/admin/messages/$userId';
  final params = <String>[];
  if (limit != null) params.add('limit=$limit');
  if (offset != null) params.add('offset=$offset');
  if (params.isNotEmpty) url += '?${params.join('&')}';
  
  final response = await http.get(Uri.parse(url), headers: _getHeaders());
  return await _handleResponse(response) as List<dynamic>;
}
```

**Request:**
```
GET /admin/messages/user-uuid-123?limit=50&offset=0
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "msg-uuid",
    "direction": "user_to_admin",
    "body": "Hello, I need help",
    "is_read": true,
    "created_at": "2026-03-02T08:00:00Z"
  },
  {
    "id": "msg-uuid-2",
    "direction": "admin_to_user",
    "body": "How can I help you?",
    "is_read": true,
    "created_at": "2026-03-02T08:05:00Z"
  }
]
```

**UI:** `lib/views/messages/messages_screen.dart` - Conversation view

### POST /admin/messages/{user_id}

**Used in:** `MessageController.sendReply()`  
**File:** `lib/controllers/message_controller.dart`

```dart
Future<void> sendReply(String userId, String message) async {
  await _apiService.replyToUser(userId, message);
  await loadUserMessages(userId);  // Refresh to show new message
  Get.snackbar('Success', 'Reply sent successfully');
}
```

**API Implementation:**
```dart
Future<Map<String, dynamic>> replyToUser(
    String userId, String message) async {
  final url = Uri.parse('${AppConstants.baseUrl}/admin/messages/$userId');
  final body = json.encode({'body': message});
  
  final response = await http.post(url, headers: _getHeaders(), body: body);
  return _handleResponse(response);
}
```

**Request:**
```json
POST /admin/messages/user-uuid-123
Authorization: Bearer <token>

{
  "body": "Your order is under review."
}
```

**Response:**
```json
{
  "id": "msg-uuid",
  "direction": "admin_to_user",
  "body": "Your order is under review.",
  "is_read": false,
  "created_at": "2026-03-02T08:10:00Z"
}
```

**UI:** `lib/views/messages/messages_screen.dart` - Reply box

---

## 🔧 API Service Architecture

### Base Configuration

**File:** `lib/core/constants/app_constants.dart`
```dart
static const String baseUrl = 'https://api.aurawealth.com';
static const int apiTimeout = 30; // seconds
```

### Headers Management

All authenticated requests include:
```dart
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer <token>'
}
```

For form data (login only):
```dart
{
  'Content-Type': 'application/x-www-form-urlencoded'
}
```

### Error Handling

**Standard Error Response:**
```json
{
  "detail": "Error message here"
}
```

**Handled in `_handleResponse()`:**
```dart
Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return json.decode(response.body);
  } else {
    String errorMessage = 'An error occurred';
    try {
      final errorBody = json.decode(response.body);
      errorMessage = errorBody['detail'] ?? errorMessage;
    } catch (e) {
      errorMessage = response.body.isNotEmpty 
          ? response.body 
          : 'HTTP ${response.statusCode}';
    }
    throw Exception(errorMessage);
  }
}
```

### Timeout Handling

All requests have a 30-second timeout:
```dart
final response = await http.post(url, headers: headers, body: body)
    .timeout(Duration(seconds: AppConstants.apiTimeout));
```

---

## 📋 Data Models Mapping

### Transaction Model

**API Response Fields → Model Properties:**

| API Field | Model Property | Type | Notes |
|-----------|----------------|------|-------|
| `id` | `id` | String | UUID |
| `type` | `type` | String | Transaction type enum |
| `status` | `status` | String | Status enum |
| `grams` | `grams` | double | Gold amount |
| `amount_bdt` | `amountBdt` | double | BDT amount |
| `fee_percent` | `feePercent` | double | Fee percentage |
| `fee_amount` | `feeAmount` | double | Fee in BDT |
| `code` | `code` | String? | Redemption code |
| `expiry_time` | `expiryTime` | DateTime? | Code expiry |
| `created_at` | `createdAt` | DateTime | Creation time |
| `approved_at` | `approvedAt` | DateTime? | Approval time |
| `paid_at` | `paidAt` | DateTime? | Payment time |
| `rejected_at` | `rejectedAt` | DateTime? | Rejection time |
| `admin_note` | `adminNote` | String? | Admin note |
| `user_id` | `userId` | String? | User UUID |
| `user_name` | `userName` | String? | User name |
| `user_email` | `userEmail` | String? | User email |

**File:** `lib/models/transaction.dart`

### Message Model

**API Response Fields → Model Properties:**

| API Field | Model Property | Type |
|-----------|----------------|------|
| `id` | `id` | String |
| `direction` | `direction` | String |
| `body` | `body` | String |
| `is_read` | `isRead` | bool |
| `created_at` | `createdAt` | DateTime |

**File:** `lib/models/message.dart`

### GoldPrice Model

**API Response Fields → Model Properties:**

| API Field | Model Property | Type |
|-----------|----------------|------|
| `price` | `price` | double |
| `bank_sell_price` | `bankSellPrice` | double |
| `exchange_price` | `exchangePrice` | double |
| `store_sell_price` | `storeSellPrice` | double |
| `created_at` | `createdAt` | DateTime |

**File:** `lib/models/gold_price.dart`

---

## 🔄 State Flow Examples

### Example 1: Login Flow

```
User enters credentials
    ↓
LoginScreen.onPressed()
    ↓
AuthController.login(email, password)
    ↓
ApiService.adminLogin(email, password)
    ↓
HTTP POST /admin/login
    ↓
Response: { access_token, token_type }
    ↓
StorageService.saveAuthToken(token)
    ↓
AuthController.isAuthenticated = true
    ↓
Navigate to Dashboard
    ↓
AuthMiddleware checks auth ✓
    ↓
DashboardScreen loads
    ↓
DashboardController.loadDashboardData()
    ↓
HTTP GET /admin/dashboard (with Bearer token)
    ↓
Parse transactions and calculate stats
    ↓
Update observable state
    ↓
UI rebuilds automatically
```

### Example 2: Mark Transaction as Paid

```
User clicks "Mark as Paid" button
    ↓
Confirmation dialog shown
    ↓
User confirms
    ↓
TransactionController.markAsPaid(txId)
    ↓
ApiService.markAsPaid(txId)
    ↓
HTTP POST /admin/{txId}/mark-as-paid (with Bearer token)
    ↓
Response: { id, status: "PAID", paid_at }
    ↓
TransactionController.loadTransactions()
    ↓
HTTP GET /admin/dashboard
    ↓
Update transactions list
    ↓
UI rebuilds with updated status
    ↓
Success snackbar shown
```

### Example 3: Send Message Reply

```
Admin types message and clicks send
    ↓
MessageController.sendReply(userId, message)
    ↓
ApiService.replyToUser(userId, message)
    ↓
HTTP POST /admin/messages/{userId} (with Bearer token)
Body: { "body": "message text" }
    ↓
Response: Message object
    ↓
MessageController.loadUserMessages(userId)
    ↓
HTTP GET /admin/messages/{userId}
    ↓
Update message list
    ↓
UI rebuilds with new message
    ↓
Also update threads list (unread counts)
    ↓
Success snackbar shown
```

---

## 🛡️ Authentication Flow

### Token Storage

**Save Token:**
```dart
await StorageService().saveAuthToken(token);
```

Stored in SharedPreferences with key: `'auth_token'`

**Retrieve Token:**
```dart
final token = StorageService().getAuthToken();
```

**Check Authentication:**
```dart
final isAuth = StorageService().isAuthenticated;  // Returns bool
```

### Token Usage

Every API request (except login) automatically includes:
```
Authorization: Bearer <token>
```

Implemented in `ApiService._getHeaders()`:
```dart
Map<String, String> _getHeaders({bool isFormData = false}) {
  final headers = <String, String>{};
  headers['Content-Type'] = isFormData 
      ? 'application/x-www-form-urlencoded' 
      : 'application/json';
  
  final token = _storage.getAuthToken();
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }
  
  return headers;
}
```

### Token Expiry

**Token Lifetime:** 12 hours (configured in backend)

**Handling Expired Tokens:**
- API returns 401 Unauthorized
- User redirected to login
- Token cleared from storage
- User must login again

---

## 📊 Data Aggregation

### Dashboard Statistics

**Calculated from transaction data:**

```dart
// Total gold holdings = Sum(Buy) - Sum(Sell/Exchange)
final totalBuyGrams = transactions
    .where((t) => t.type.contains('BUY') && t.status != 'REJECTED')
    .fold(0.0, (sum, t) => sum + t.grams);

final totalSellGrams = transactions
    .where((t) => (t.type.contains('SELL') || t.type.contains('EXCHANGE')) 
        && t.status != 'REJECTED' && t.status != 'PENDING')
    .fold(0.0, (sum, t) => sum + t.grams);

totalGoldHoldings = totalBuyGrams - totalSellGrams;

// Total revenue = Sum of all fee amounts
totalRevenue = transactions
    .where((t) => t.status != 'REJECTED')
    .fold(0.0, (sum, t) => sum + t.feeAmount);
```

### User Management

**Users extracted from transactions:**

Since there's no dedicated user API, users are aggregated from transaction data:

```dart
final userMap = <String, User>{};
for (var tx in transactions) {
  if (tx.userId != null && !userMap.containsKey(tx.userId)) {
    userMap[tx.userId!] = User(
      id: tx.userId!,
      email: tx.userEmail,
      // ... other fields
    );
  }
}
users = userMap.values.toList();
```

---

## 🔍 Filtering & Search

### Transaction Filters

**Implementation in `TransactionController`:**

```dart
void applyFilters() {
  var filtered = transactions.toList();
  
  // Status filter
  if (selectedStatus.value.isNotEmpty) {
    filtered = filtered.where((t) => 
        t.status.toLowerCase() == selectedStatus.value.toLowerCase()
    ).toList();
  }
  
  // Type filter
  if (selectedType.value.isNotEmpty) {
    filtered = filtered.where((t) => 
        t.type == selectedType.value
    ).toList();
  }
  
  // Date range filter
  if (startDate.value != null) {
    filtered = filtered.where((t) => 
        t.createdAt.isAfter(startDate.value!)
    ).toList();
  }
  
  // Search query
  if (searchQuery.value.isNotEmpty) {
    final query = searchQuery.value.toLowerCase();
    filtered = filtered.where((t) => 
        t.id.toLowerCase().contains(query) ||
        t.type.toLowerCase().contains(query) ||
        (t.code?.toLowerCase().contains(query) ?? false)
    ).toList();
  }
  
  filteredTransactions.value = filtered;
}
```

---

## 🎯 Best Practices

### API Calls
1. Always wrap in try-catch
2. Show loading state before call
3. Handle errors gracefully
4. Provide user feedback
5. Clear loading state in finally block

### State Updates
1. Use `.value =` for observable updates
2. Updates trigger automatic UI rebuild
3. No manual setState() needed
4. Leverage GetX reactivity

### Error Display
1. Extract user-friendly message
2. Show in snackbar or error widget
3. Provide retry option
4. Log technical details (dev only)

---

## 📚 Further Reading

- [API Documentation](../assets/api_documentation/README.md)
- [Architecture Overview](ARCHITECTURE.md)
- [Features Documentation](FEATURES.md)
- [GetX Documentation](https://pub.dev/packages/get)
- [HTTP Package](https://pub.dev/packages/http)
