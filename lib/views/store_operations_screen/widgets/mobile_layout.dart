import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'credit_grams_panel.dart';
import 'redeem_code_panel.dart';

class MobileLayout extends StatelessWidget {
  final TabController tabController;
  final CreditGramsPanel creditGramsPanel;
  final RedeemCodePanel redeemCodePanel;

  const MobileLayout({
    super.key,
    required this.tabController,
    required this.creditGramsPanel,
    required this.redeemCodePanel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.grey100.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey500,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.add_card, size: 18),
                text: 'Credit Grams',
              ),
              Tab(
                icon: Icon(Icons.qr_code_scanner, size: 18),
                text: 'Redeem Code',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: creditGramsPanel,
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: redeemCodePanel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
