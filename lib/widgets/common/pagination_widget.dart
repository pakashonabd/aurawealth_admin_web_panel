import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final Function(int) onPageChanged;
  final Function(int)? onItemsPerPageChanged;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page selector
          if (onItemsPerPageChanged != null)
            Row(
              children: [
                Text(
                  'Items per page:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: itemsPerPage,
                  items: [10, 20, 50, 100].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onItemsPerPageChanged!(value);
                    }
                  },
                ),
              ],
            ),

          // Page info
          Text(
            'Showing ${_getStartItem()} - ${_getEndItem()} of $totalItems',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),

          // Page navigation
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.first_page),
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                color: AppColors.primary,
                disabledColor: AppColors.grey400,
              ),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                color: AppColors.primary,
                disabledColor: AppColors.grey400,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                color: AppColors.primary,
                disabledColor: AppColors.grey400,
              ),
              IconButton(
                icon: Icon(Icons.last_page),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
                color: AppColors.primary,
                disabledColor: AppColors.grey400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getStartItem() {
    if (totalItems == 0) return 0;
    return (currentPage - 1) * itemsPerPage + 1;
  }

  int _getEndItem() {
    final end = currentPage * itemsPerPage;
    return end > totalItems ? totalItems : end;
  }
}
