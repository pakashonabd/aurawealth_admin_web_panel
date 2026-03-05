import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

class CreditGramsScreen extends StatefulWidget {
  const CreditGramsScreen({Key? key}) : super(key: key);

  @override
  State<CreditGramsScreen> createState() => _CreditGramsScreenState();
}

class _CreditGramsScreenState extends State<CreditGramsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _gramsController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _creditGrams() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _userIdController.text.trim();
      final grams = double.parse(_gramsController.text.trim());

      await _apiService.creditGrams(userId, grams);

      Get.snackbar(
        'Success',
        'Successfully credited ${Formatters.formatGrams(grams)} to user',
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );

      _userIdController.clear();
      _gramsController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding * 2),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Row(
                            children: [
                              Icon(Icons.add_card, color: AppColors.primary, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Credit Grams to User',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    SizedBox(height: 4),
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
                            ],
                          ),
                          SizedBox(height: 32),

                          // User ID Field
                          TextFormField(
                            controller: _userIdController,
                            decoration: InputDecoration(
                              labelText: 'User ID',
                              hintText: 'Enter user UUID',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter user ID';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Grams Field
                          TextFormField(
                            controller: _gramsController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Grams',
                              hintText: 'e.g., 5.0',
                              prefixIcon: Icon(Icons.scale),
                              suffixText: 'g',
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
                          SizedBox(height: 24),

                          // Info Card
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fee: ${AppConstants.buyFeePercent}% + ${AppConstants.vatPercent}% VAT\nTransaction will be auto-approved',
                                    style: TextStyle(
                                      color: AppColors.info,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _creditGrams,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text('Credit Grams'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
