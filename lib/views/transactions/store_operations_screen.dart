import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';

class StoreOperationsScreen extends StatefulWidget {
  const StoreOperationsScreen({Key? key}) : super(key: key);

  @override
  State<StoreOperationsScreen> createState() => _StoreOperationsScreenState();
}

class _StoreOperationsScreenState extends State<StoreOperationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();

  // Credit Grams Form
  final _creditFormKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _gramsController = TextEditingController();
  final _userSearchController = TextEditingController();
  bool _isCreditLoading = false;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoadingUsers = false;
  String? _selectedUserId;
  String? _selectedUserName;

  // Redeem Code Form
  final _redeemFormKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isRedeemLoading = false;

  // Banner tips
  final List<String> _tips = [
    '💡 Verify user identity before processing transactions',
    '⚡ Codes expire after 60 minutes for security',
    '✅ All transactions are logged and auditable',
    '🔒 Use secure channels for customer verification',
  ];
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startTipRotation();
    _loadUsers();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _startTipRotation();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    _gramsController.dispose();
    _codeController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final users = await _apiService.getAllUsers();
      setState(() {
        _allUsers = users.map((user) => {
          'id': user['id'] ?? user['user_id'] ?? '',
          'name': user['name'] ?? user['username'] ?? user['email'] ?? 'Unknown User',
        }).toList();
        _filteredUsers = _allUsers;
      });
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = user['name'].toString().toLowerCase();
          final id = user['id'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || id.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _creditGrams() async {
    if (!_creditFormKey.currentState!.validate()) return;
    
    if (_selectedUserId == null || _selectedUserId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a user',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        icon: Icon(Icons.error, color: AppColors.error),
      );
      return;
    }

    setState(() => _isCreditLoading = true);

    try {
      final grams = double.parse(_gramsController.text.trim());

      await _apiService.creditGrams(_selectedUserId!, grams);

      if (mounted) {
        _showSuccessAnimation();
        Get.snackbar(
          'Success',
          'Successfully credited ${Formatters.formatGrams(grams)} to $_selectedUserName',
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          icon: Icon(Icons.check_circle, color: AppColors.success),
        );

        setState(() {
          _selectedUserId = null;
          _selectedUserName = null;
          _userSearchController.clear();
        });
        _gramsController.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        icon: Icon(Icons.error, color: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreditLoading = false);
      }
    }
  }

  Future<void> _redeemCode() async {
    if (!_redeemFormKey.currentState!.validate()) return;

    setState(() => _isRedeemLoading = true);

    try {
      final code = _codeController.text.trim().toUpperCase();
      await _apiService.redeemCode(code);

      if (mounted) {
        _showSuccessAnimation();
        Get.snackbar(
          'Success',
          'Code redeemed successfully! Transaction approved.',
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          icon: Icon(Icons.check_circle, color: AppColors.success),
        );

        _codeController.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        icon: Icon(Icons.error, color: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isRedeemLoading = false);
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/Admin Panel.json',
                width: 250,
                height: 250,
                repeat: false,
              ),
              const SizedBox(height: 16),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 300.ms)
            .fadeIn(duration: 300.ms),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = !isMobile && !isTablet;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Animated Banner
          _buildInfoBanner()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0, duration: 600.ms),

          // Main Content
          Expanded(
            child: isDesktop
                ? _buildSplitScreenLayout()
                : _buildTabLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.store,
              color: AppColors.primary,
              size: 28,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Operations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _tips[_currentTipIndex],
                    key: ValueKey(_currentTipIndex),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 1000.ms)
              .then()
              .fadeOut(duration: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildSplitScreenLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Grams Panel
          Expanded(
            child: SingleChildScrollView(
              child: _buildCreditGramsPanel()
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 600.ms)
                  .slideX(begin: -0.1, end: 0, duration: 600.ms),
            ),
          ),
          const SizedBox(width: 16),
          // Redeem Code Panel
          Expanded(
            child: SingleChildScrollView(
              child: _buildRedeemCodePanel()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: 0.1, end: 0, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLayout() {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.grey600,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.add_card),
                text: 'Credit Grams',
              ),
              Tab(
                icon: Icon(Icons.qr_code_scanner),
                text: 'Redeem Code',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCreditGramsPanel(),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildRedeemCodePanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditGramsPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _creditFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_card,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit Grams to User',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For in-store purchases',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lottie Animation
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Lottie.asset(
                        'assets/lottie/website building of shopping sale.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // User Selection Dropdown with Search
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select User',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                      child: PopupMenuButton<Map<String, dynamic>>(
                        offset: const Offset(0, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: 500,
                          maxHeight: 400,
                        ),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<Map<String, dynamic>>(
                              enabled: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _userSearchController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Search users...',
                                      prefixIcon: Icon(Icons.search),
                                      filled: true,
                                      fillColor: AppColors.grey100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    onChanged: _filterUsers,
                                  ),
                                  const Divider(),
                                  _isLoadingUsers
                                      ? const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        )
                                      : _filteredUsers.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                'No users found',
                                                style: TextStyle(
                                                  color: AppColors.grey600,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              constraints: BoxConstraints(maxHeight: 250),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: _filteredUsers.map((user) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedUserId = user['id'];
                                                          _selectedUserName = user['name'];
                                                        });
                                                        Navigator.pop(context);
                                                        _userSearchController.clear();
                                                        _filteredUsers = _allUsers;
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 12,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _selectedUserId == user['id']
                                                              ? AppColors.primary.withValues(alpha: 0.1)
                                                              : Colors.transparent,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.person,
                                                              color: AppColors.primary,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    user['name'],
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.w500,
                                                                      color: AppColors.textPrimary,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'ID: ${user['id']}',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      color: AppColors.grey600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                ],
                              ),
                            ),
                          ];
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: _selectedUserId != null
                                    ? AppColors.primary
                                    : AppColors.grey600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedUserId != null
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedUserName ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'ID: $_selectedUserId',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Select a user',
                                        style: TextStyle(
                                          color: AppColors.grey600,
                                        ),
                                      ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.grey600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grams Field
                TextFormField(
                  controller: _gramsController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Grams',
                    hintText: 'e.g., 5.0',
                    prefixIcon: Icon(Icons.scale),
                    suffixText: 'g',
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.grey200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter grams';
                    }
                    final grams = double.tryParse(value);
                    if (grams == null) {
                      return 'Please enter a valid number';
                    }
                    if (grams < AppConstants.minGrams) {
                      return 'Minimum ${AppConstants.minGrams} grams';
                    }
                    if (grams % AppConstants.gramsIncrement != 0) {
                      return 'Must be in ${AppConstants.gramsIncrement}g increments';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.info, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fee: ${AppConstants.buyFeePercent}% + ${AppConstants.vatPercent}% VAT\nTransaction will be auto-approved',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isCreditLoading ? null : _creditGrams,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isCreditLoading ? 0 : 2,
                  ),
                  child: _isCreditLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Credit Grams',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Quick Tips
                _buildQuickTips([
                  'Verify user identity before crediting',
                  'Double-check gram amount',
                  'Transaction is irreversible',
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRedeemCodePanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _redeemFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeem Transaction Code',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For store sell or exchange',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lottie Animation
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        'assets/lottie/Transaction Confirmation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Code Field
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Redemption Code',
                    hintText: 'A3X9KL',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.grey200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.warning,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter redemption code';
                    }
                    if (value.length != 6) {
                      return 'Code must be 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _codeController.value = _codeController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(
                        offset: value.length,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Warning Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Redeeming will approve the transaction and consume locked grams',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isRedeemLoading ? null : _redeemCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isRedeemLoading ? 0 : 2,
                  ),
                  child: _isRedeemLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Redeem Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Expiry Warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Codes expire after 60 minutes',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                _buildInstructions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTips(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'How it Works',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'User generates code in app'),
          _buildInstructionStep('2', 'Customer shows code at store'),
          _buildInstructionStep('3', 'Enter code here to complete'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
