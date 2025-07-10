import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/models/store_customer.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import '../base/BasePage.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late final AppListController<StoreCustomer> customersController =
  AppListController<StoreCustomer>(
    fetch: () => getIt<StoreRepository>().getStoreCustomers(widget.storeId),
  );

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBar(title: const Text('Clientes')),
      mobileBuilder: (context) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _buildContent(MediaQuery.of(context).size.width),
            const SizedBox(height: 70),
          ],
        ),
      ),
      desktopBuilder: (context) => Column(
        children: [
          FixedHeader(
            title: 'Clientes',
            actions: [
              AppPrimaryButton(
                label: 'Atualizar',
                onPressed: customersController.refresh,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildContent(MediaQuery.of(context).size.width),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double width) {
    int crossAxisCount = 1;
    if (width >= 1200) {
      crossAxisCount = 3;
    } else if (width >= 800) {
      crossAxisCount = 2;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedBuilder(
        animation: customersController,
        builder: (_, __) {
          return AppPageStatusBuilder<List<StoreCustomer>>(
            tryAgain: customersController.refresh,
            status: customersController.status,
            successBuilder: (customers) {
              return GridView.builder(
                shrinkWrap: true,
                itemCount: customers.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 180,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return _buildCard(customer);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(StoreCustomer customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? const Color(0xFF1F2937)
        : const Color(0xFFF9FAFB);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (customer.phone != null)
            Text('📞 ${customer.phone}', style: const TextStyle(fontSize: 14)),
          if (customer.email != null)
            Text('✉️ ${customer.email}', style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            'Pedidos: ${customer.totalOrders}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            'Gasto total: R\$ ${(customer.totalSpent / 100).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
          if (customer.lastOrderAt != null)
            Text(
              'Última compra: ${_formatDate(customer.lastOrderAt!)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
