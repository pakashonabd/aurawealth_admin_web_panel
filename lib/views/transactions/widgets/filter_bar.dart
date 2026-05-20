import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/constants/app_colors.dart';
import './transaction_constants.dart';

class FilterBar extends StatelessWidget {
  final TransactionController ctrl;
  const FilterBar({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) => Obx(() {
    final statusVal = ctrl.selectedStatus.value.isEmpty
        ? null
        : ctrl.selectedStatus.value;
    final typeVal =
        ctrl.selectedType.value.isEmpty ? null : ctrl.selectedType.value;
    final hasFilter = ctrl.selectedStatus.value.isNotEmpty ||
        ctrl.selectedType.value.isNotEmpty ||
        ctrl.searchQuery.value.isNotEmpty;

    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextField(
              controller: ctrl.searchCtrl,
              onChanged: ctrl.setSearchQuery,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search ID, user, phone, type…',
                hintStyle: const TextStyle(fontSize: 12, color: textMuted),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 16, color: textSec),
                filled: true,
                fillColor: bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radiusSm),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _DropdownFilter(
          label: 'Status',
          value: statusVal,
          items: const ['PENDING', 'APPROVED', 'PAID', 'REJECTED'],
          itemLabels: const ['Pending', 'Approved', 'Paid', 'Rejected'],
          onChanged: ctrl.setStatusFilter,
        ),
        const SizedBox(width: 6),
        _DropdownFilter(
          label: 'Type',
          value: typeVal,
          items: const [
            'BUY_IN_APP',
            'BUY_IN_STORE',
            'SELL_TO_BANK',
            'SELL_TO_STORE',
            'EXCHANGE_TO_JEWELLERY',
          ],
          itemLabels: const [
            'Buy In App',
            'Buy In Store',
            'Sell to Bank',
            'Sell to Store',
            'Exchange',
          ],
          onChanged: ctrl.setTypeFilter,
        ),
        if (hasFilter) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: ctrl.clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: colRejected.withOpacity(0.08),
                borderRadius: BorderRadius.circular(radiusSm),
                border: Border.all(color: colRejected.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.close_rounded, size: 12, color: colRejected),
                SizedBox(width: 4),
                Text('Clear',
                    style: TextStyle(
                        fontSize: 11,
                        color: colRejected,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ]),
    );
  });
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final List<String>? itemLabels;
  final void Function(String?) onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabels,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.06) : bg,
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.4) : border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label,
              style: const TextStyle(fontSize: 11, color: textSec)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 14, color: textSec),
          style: TextStyle(
              fontSize: 11,
              color: active ? AppColors.primary : textPri,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal),
          isDense: true,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All $label',
                  style: const TextStyle(fontSize: 11, color: textSec)),
            ),
            ...items.asMap().entries.map((e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(itemLabels?[e.key] ?? e.value,
                      style: const TextStyle(fontSize: 11)),
                )),
          ],
        ),
      ),
    );
  }
}
