import 'package:flutter/material.dart';
import 'dart:convert';

class GatewayJsonViewer extends StatelessWidget {
  final Map<String, dynamic>? data;
  const GatewayJsonViewer({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const Text('No data');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Text(
          const JsonEncoder.withIndent('  ').convert(data),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
