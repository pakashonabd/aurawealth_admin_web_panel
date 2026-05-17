import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import 'widgets/info_banner.dart';
import 'widgets/credit_grams_panel.dart';
import 'widgets/redeem_code_panel.dart';
import 'widgets/desktop_layout.dart';
import 'widgets/mobile_layout.dart';
import 'widgets/success_dialog.dart';

class StoreOperationsScreen extends StatefulWidget {
  const StoreOperationsScreen({super.key});

  @override
  State<StoreOperationsScreen> createState() => _StoreOperationsScreenState();
}

class _StoreOperationsScreenState extends State<StoreOperationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();
  final _userController = Get.put(UserController());

  // Credit Grams Form
  final _creditFormKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _gramsController = TextEditingController();
  final _userSearchController = TextEditingController();
  bool _isCreditLoading = false;
  List<User> _filteredUsers = [];
  String? _selectedUserId;
  User? _selectedUser;

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

    _filteredUsers = _userController.users;

    // Listen to user changes
    ever(_userController.users, (users) {
      setState(() {
        _filteredUsers = users;
      });
    });
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

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _userController.users;
      } else {
        _filteredUsers = _userController.users.where((user) {
          final searchQuery = query.toLowerCase();
          final fields = [
            user.id,
            user.backendId,
            user.firebaseUid,
            user.name,
            user.email,
            user.phoneNumber,
            user.bankName,
            user.accountNumber,
            user.nationalId,
          ];
          return fields.any(
            (field) => field?.toLowerCase().contains(searchQuery) ?? false,
          );
        }).toList();
      }
    });
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUserId = user.id;
      _selectedUser = user;
    });
    _userSearchController.clear();
    _filteredUsers = _userController.users;
  }

  String? _validateGrams(String? value) {
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
  }

  String _creditTargetBackendUserId() {
    final backendId = _selectedUser?.backendId?.trim();
    if (backendId != null && backendId.isNotEmpty) return backendId;

    final selectedId = _selectedUserId?.trim() ?? '';
    if (_looksLikeUuid(selectedId)) return selectedId;

    return '';
  }

  bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
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

    final targetUserId = _creditTargetBackendUserId();
    if (targetUserId.isEmpty) {
      Get.snackbar(
        'Error',
        'Selected user does not have a backend/PostgreSQL user UUID. Please refresh users and try again.',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        icon: Icon(Icons.error, color: AppColors.error),
      );
      return;
    }

    setState(() => _isCreditLoading = true);

    try {
      final grams = double.parse(_gramsController.text.trim());
      await _apiService.creditGrams(targetUserId, grams);

      if (mounted) {
        _showSuccessAnimation();
        Get.snackbar(
          'Success',
          'Successfully credited ${Formatters.formatGrams(grams)} to ${_selectedUser?.name ?? _selectedUser?.email ?? "user"}',
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          icon: Icon(Icons.check_circle, color: AppColors.success),
        );

        setState(() {
          _selectedUserId = null;
          _selectedUser = null;
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
      builder: (context) => const SuccessDialog(),
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

    final creditPanel = CreditGramsPanel(
      formKey: _creditFormKey,
      gramsController: _gramsController,
      userSearchController: _userSearchController,
      isLoading: _isCreditLoading,
      filteredUsers: _filteredUsers,
      selectedUserId: _selectedUserId,
      selectedUser: _selectedUser,
      userController: _userController,
      onCreditGrams: _creditGrams,
      onFilterUsers: _filterUsers,
      onSelectUser: _selectUser,
      gramsValidator: _validateGrams,
    );

    final redeemPanel = RedeemCodePanel(
      formKey: _redeemFormKey,
      codeController: _codeController,
      isLoading: _isRedeemLoading,
      onRedeemCode: _redeemCode,
    );

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Animated Banner
          InfoBanner(tips: _tips, currentTipIndex: _currentTipIndex)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0, duration: 600.ms),

          // Main Content
          Expanded(
            child: isDesktop
                ? DesktopLayout(
                    creditGramsPanel: creditPanel,
                    redeemCodePanel: redeemPanel,
                  )
                : MobileLayout(
                    tabController: _tabController,
                    creditGramsPanel: creditPanel,
                    redeemCodePanel: redeemPanel,
                  ),
          ),
        ],
      ),
    );
  }
}
