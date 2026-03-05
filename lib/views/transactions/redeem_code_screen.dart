import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/layout/main_layout.dart';

class RedeemCodeScreen extends StatefulWidget {
  const RedeemCodeScreen({Key? key}) : super(key: key);

  @override
  State<RedeemCodeScreen> createState() => _RedeemCodeScreenState();
}

class _RedeemCodeScreenState extends State<RedeemCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeemCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim().toUpperCase();
      final response = await _apiService.redeemCode(code);

      Get.snackbar(
        'Success',
        'Code redeemed successfully! Transaction approved.',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );

      _codeController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error.withOpacity(0.1),
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
                              Icon(Icons.qr_code_scanner, 
                                color: AppColors.primary, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Redeem Transaction Code',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'For store sell or exchange transactions',
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

                          // Code Field
                          TextFormField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: 'Redemption Code',
                              hintText: 'e.g., A3X9KL',
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                            ),
                            textCapitalization: TextCapitalization.characters,
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
                          SizedBox(height: 24),

                          // Info Card
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, 
                                  color: AppColors.warning, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Redeeming a code will approve the transaction and consume locked grams',
                                    style: TextStyle(
                                      color: AppColors.warning,
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
                            onPressed: _isLoading ? null : _redeemCode,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text('Redeem Code'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Instructions Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it Works',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        _buildInstructionStep(
                          '1',
                          'User generates code',
                          'Customer creates a SELL_TO_STORE or EXCHANGE transaction in the app',
                        ),
                        SizedBox(height: 12),
                        _buildInstructionStep(
                          '2',
                          'User visits store',
                          'Customer shows the 6-character code at your physical location',
                        ),
                        SizedBox(height: 12),
                        _buildInstructionStep(
                          '3',
                          'Verify & Redeem',
                          'Enter the code here to approve the transaction and complete the exchange',
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, 
                                color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Codes expire after 60 minutes',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
