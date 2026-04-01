#!/bin/bash
sed -i '' 's/gradient: LinearGradient(/color: AppColors.primary, \/\/ Removed LinearGradient/g' lib/views/users/users_screen.dart
sed -i '' 's/colors: ChartHelpers.primaryGradient,/ /g' lib/views/users/users_screen.dart
