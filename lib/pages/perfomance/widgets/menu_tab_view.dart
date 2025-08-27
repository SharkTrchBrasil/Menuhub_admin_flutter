import 'package:flutter/material.dart';
import '../../../models/performance_data.dart';
import '../widgets/category_performance_list.dart';
import '../widgets/product_funnel_list.dart';
import '../widgets/top_addons_list.dart';
import '../widgets/top_selling_products_list.dart';

class MenuTabView extends StatelessWidget {
  final StorePerformance data;
  const MenuTabView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ListView(
      //  crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductFunnelList(funnelData: data.productFunnel),
          const SizedBox(height: 24),
          TopSellingProductsList(products: data.topSellingProducts),
          const SizedBox(height: 24),
          TopAddonsList(addons: data.topSellingAddons),
          const SizedBox(height: 24),
          CategoryPerformanceList(categories: data.categoryPerformance),
        ],
      ),
    );
  }
}