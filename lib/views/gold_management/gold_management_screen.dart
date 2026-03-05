import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gold_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;

class GoldManagementScreen extends StatelessWidget {
  const GoldManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GoldController>();

    return Obx(() {
      if (controller.isLoading.value && controller.currentPrice.value == null) {
        return LoadingWidget(message: 'Loading gold prices...');
      }

      if (controller.errorMessage.value.isNotEmpty && controller.currentPrice.value == null) {
        return custom_error.CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refresh,
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Prices Card
            _buildCurrentPricesCard(context, controller),
            SizedBox(height: 24),

            // Update Price Card
            _buildUpdatePriceCard(context, controller),
            SizedBox(height: 24),

            // Price Information
            _buildPriceInformation(context),
          ],
        ),
      );
    });
  }

  Widget _buildCurrentPricesCard(BuildContext context, GoldController controller) {
    final price = controller.currentPrice.value;

    if (price == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 48, color: AppColors.grey400),
                SizedBox(height: 16),
                Text(
                  'No price has been set yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    final columns = isMobile ? 1 : 2;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.diamond, color: Color(0xFFFFD700)),
                SizedBox(width: 8),
                Text(
                  'Current Gold Prices (24 Carat)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Spacer(),
                Text(
                  'Updated: ${Formatters.formatRelativeTime(price.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildPriceItem(
                  'Market Price',
                  Formatters.formatCurrency(price.price),
                  Icons.trending_up,
                  AppColors.primary,
                  'Per gram',
                ),
                _buildPriceItem(
                  'Bank Sell Price',
                  Formatters.formatCurrency(price.bankSellPrice),
                  Icons.account_balance,
                  AppColors.success,
                  '-2% fee',
                ),
                _buildPriceItem(
                  'Store Sell Price',
                  Formatters.formatCurrency(price.storeSellPrice),
                  Icons.store,
                  AppColors.error,
                  '-17% fee',
                ),
                _buildPriceItem(
                  'Exchange Price',
                  Formatters.formatCurrency(price.exchangePrice),
                  Icons.swap_horiz,
                  AppColors.info,
                  '-10% fee',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(
      String label, String value, IconData icon, Color color, String note) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePriceCard(BuildContext context, GoldController controller) {
    final priceController = TextEditingController();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Update Gold Price',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Set the new market price per gram (BDT). All other prices will be calculated automatically.',
              style: TextStyle(color: AppColors.grey600),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price per Gram (BDT)',
                      hintText: 'e.g., 5200.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Obx(() => ElevatedButton.icon(
                  onPressed: controller.isUpdatingPrice.value
                      ? null
                      : () {
                          final priceText = priceController.text.trim();
                          if (priceText.isEmpty) {
                            Get.snackbar('Error', 'Please enter a price');
                            return;
                          }

                          final price = double.tryParse(priceText);
                          if (price == null || price <= 0) {
                            Get.snackbar('Error', 'Please enter a valid price');
                            return;
                          }

                          controller.updatePrice(price).then((_) {
                            priceController.clear();
                          });
                        },
                  icon: controller.isUpdatingPrice.value
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.check),
                  label: Text('Update Price'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInformation(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 8),
                Text(
                  'Price Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Gold Type:', AppConstants.goldType),
            SizedBox(height: 8),
            _buildInfoRow('Minimum Trade:', '${AppConstants.minGrams} g'),
            SizedBox(height: 8),
            _buildInfoRow('Increment:', '${AppConstants.gramsIncrement} g'),
            SizedBox(height: 8),
            _buildInfoRow('Min Exchange:', '${AppConstants.minExchangeGrams} g'),
            Divider(height: 24),
            Text(
              'Fee Structure',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Buy Fee:', '${AppConstants.buyFeePercent}% + ${AppConstants.vatPercent}% VAT'),
            SizedBox(height: 8),
            _buildInfoRow('Bank Sell Fee:', '${AppConstants.bankSellFeePercent}%'),
            SizedBox(height: 8),
            _buildInfoRow('Store Sell Fee:', '${AppConstants.storeSellFeePercent}%'),
            SizedBox(height: 8),
            _buildInfoRow('Exchange Fee:', '${AppConstants.exchangeFeePercent}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey600,
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
