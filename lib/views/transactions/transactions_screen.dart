import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import 'widgets/desktop_layout.dart';
import 'widgets/mobile_layout.dart';
import 'widgets/loading_view.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.transactions.isEmpty) {
          return const LoadingView();
        }
        if (ctrl.errorMessage.value.isNotEmpty && ctrl.transactions.isEmpty) {
          return custom_error.CustomErrorWidget(
            message: ctrl.errorMessage.value,
            onRetry: ctrl.refresh,
          );
        }

        final all      = ctrl.transactions.toList();
        final filtered = ctrl.filteredTransactions.toList();
        final pending  = all.where((t) => t.status.toLowerCase() == 'pending').length;
        final approved = all.where((t) => t.status.toLowerCase() == 'approved').length;
        final rejected = all.where((t) => t.status.toLowerCase() == 'rejected').length;
        final paid     = all.where((t) => t.status.toLowerCase() == 'paid').length;

        return Responsive.isMobile(context)
            ? MobileLayout(
                all: all,
                filtered: filtered,
                pending: pending,
                approved: approved,
                rejected: rejected,
                paid: paid,
                ctrl: ctrl,
              )
            : DesktopLayout(
                all: all,
                filtered: filtered,
                pending: pending,
                approved: approved,
                rejected: rejected,
                paid: paid,
                ctrl: ctrl,
              );
      }),
    );
  }
}
