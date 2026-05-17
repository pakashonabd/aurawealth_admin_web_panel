import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user.dart';
import '../../../widgets/common/user_avatar_image.dart';
import 'quick_tips.dart';

class CreditGramsPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController gramsController;
  final TextEditingController userSearchController;
  final bool isLoading;
  final List<User> filteredUsers;
  final String? selectedUserId;
  final User? selectedUser;
  final UserController userController;
  final VoidCallback onCreditGrams;
  final Function(String) onFilterUsers;
  final Function(User) onSelectUser;
  final String? Function(String?) gramsValidator;

  const CreditGramsPanel({
    super.key,
    required this.formKey,
    required this.gramsController,
    required this.userSearchController,
    required this.isLoading,
    required this.filteredUsers,
    required this.selectedUserId,
    required this.selectedUser,
    required this.userController,
    required this.onCreditGrams,
    required this.onFilterUsers,
    required this.onSelectUser,
    required this.gramsValidator,
  });

  String _backendDisplayId(User user) {
    final backendId = user.backendId?.trim();
    if (backendId != null && backendId.isNotEmpty) return backendId;
    return user.id;
  }

  String _shorten(String value) {
    if (value.length <= 20) return value;
    return '${value.substring(0, 20)}...';
  }

  @override
  Widget build(BuildContext context) {
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
            key: formKey,
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
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                        border: Border.all(color: AppColors.grey200, width: 1),
                      ),
                      child: PopupMenuButton<Map<String, dynamic>>(
                        offset: const Offset(0, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
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
                                    controller: userSearchController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: 'Search users...',
                                      prefixIcon: const Icon(Icons.search),
                                      filled: true,
                                      fillColor: AppColors.grey100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                    onChanged: onFilterUsers,
                                  ),
                                  const Divider(),
                                  Obx(
                                    () => userController.isLoading.value
                                        ? const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          )
                                        : filteredUsers.isEmpty
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
                                            constraints: const BoxConstraints(
                                              maxHeight: 250,
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: filteredUsers.map((
                                                  user,
                                                ) {
                                                  final displayId =
                                                      _backendDisplayId(user);
                                                  return InkWell(
                                                    onTap: () {
                                                      onSelectUser(user);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            selectedUserId ==
                                                                user.id
                                                            ? AppColors.primary
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  )
                                                            : Colors
                                                                  .transparent,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          UserAvatarImage(
                                                            user: user,
                                                            radius: 18,
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  user.displayName,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColors
                                                                        .textPrimary,
                                                                  ),
                                                                ),
                                                                if (user.phoneNumber !=
                                                                    null)
                                                                  Text(
                                                                    user.phoneNumber!,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: AppColors
                                                                          .grey600,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                if (user.email !=
                                                                    null)
                                                                  Text(
                                                                    user.email!,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: AppColors
                                                                          .grey600,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                Text(
                                                                  'Backend ID: ${_shorten(displayId)}',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: AppColors
                                                                        .grey600,
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
                              selectedUser != null
                                  ? UserAvatarImage(
                                      user: selectedUser!,
                                      radius: 18,
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      color: AppColors.grey600,
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: selectedUser != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            selectedUser!.displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (selectedUser!.email != null &&
                                              selectedUser!.name != null)
                                            Text(
                                              selectedUser!.email!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.grey600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          Text(
                                            'Backend ID: ${_shorten(_backendDisplayId(selectedUser!))}',
                                            style: TextStyle(
                                              fontSize: 11,
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
                  controller: gramsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Grams',
                    hintText: 'e.g., 5.0',
                    prefixIcon: const Icon(Icons.scale),
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
                  validator: gramsValidator,
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
                      Icon(Icons.info_outline, color: AppColors.info, size: 24),
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
                  onPressed: isLoading ? null : onCreditGrams,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isLoading ? 0 : 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
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
                QuickTips(
                  tips: const [
                    'Verify user identity before crediting',
                    'Double-check gram amount',
                    'Transaction is irreversible',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
