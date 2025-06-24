import 'package:flutter/material.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key, required this.storeId});
  final int storeId;
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
