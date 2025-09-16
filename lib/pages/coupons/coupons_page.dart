import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/coupon.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';


import '../../widgets/ds_primary_button.dart';
import '../base/BasePage.dart';


class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();



    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {

      }
    });
  }


  @override
  void dispose() {



    super.dispose();
  }

  void _onAddOrEdit({Coupon? coupon}) {



    final route = coupon == null
        ? '/stores/${widget.storeId}/coupons/new'
        : '/stores/${widget.storeId}/coupons/${coupon.id}';

    // ✅ ADICIONE ESTE PRINT
    if (coupon != null) {
      print('--- 3. Navegando para a tela de edição ---');
      print('Passando cupom via extra com ${coupon.rules.length} regras.');
      // print('Dados completos do cupom: ${coupon.toJson()}'); // Descomente para ver tudo
    }

    context.go(route, extra: coupon);
  }


  @override
  Widget build(BuildContext context) {
    // ✅ PASSO 4: O build agora retorna apenas o conteúdo, sem BasePage/Scaffold
    return ResponsiveBuilder(
      mobileBuilder: (context, constraints) => _buildCouponsGrid(context, crossAxisCount: 1),
     // tabletBuilder: (context, constraints) => _buildDesktopLayout(context, 2),
      desktopBuilder: (context, constraints) => _buildDesktopLayout(context, 3),
    );
  }

  // Layout do Desktop: inclui o FixedHeader
  Widget _buildDesktopLayout(BuildContext context, int crossAxisCount) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
      ),
      child: Column(
        children: [
          FixedHeader(
            title: 'Minhas promoções',
            subtitle: 'Gerencie suas promoções e crie novas campanhas',
            actions: [
              DsButton(
                label: 'Criar Promoção',
                onPressed: _onAddOrEdit,
              ),
            ],
          ),
          Expanded(
            child: _buildCouponsGrid(context, crossAxisCount: crossAxisCount),
          ),
        ],
      ),
    );
  }

  // A grade de cupons, que é o conteúdo principal e comum
  Widget _buildCouponsGrid(BuildContext context, {required int crossAxisCount}) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is StoresManagerInitial || state is StoresManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StoresManagerError) {
          return Center(child: Text(state.message));
        }
        if (state is StoresManagerLoaded) {
          // Acessa os cupons do estado
          final coupons = state.activeStore?.relations.coupons ?? [];

          if (coupons.isEmpty) {
            return const Center(child: Text('Nenhum cupom cadastrado.'));
          }
          // ✅ ADICIONE ESTE PRINT
          print('--- 2. Dentro do BlocBuilder da CouponsPage ---');
          print('O build recebeu ${coupons.length} cupons do estado do Cubit.');





          return GridView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: coupons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 200,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _CouponCard(
                coupon: coupon,
                dateFormat: _dateFormat, storeId: state.activeStoreId,
                onEdit: (coupon) {
                print(coupon);
                  _onAddOrEdit(coupon: coupon);
                },

              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget para o card individual do cupom.
class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.storeId,
    required this.dateFormat,
    required this.onEdit,
  });

  final Coupon coupon;
  final int storeId;
  final DateFormat dateFormat;
  final void Function(Coupon) onEdit;

  String _formatDiscount(Coupon coupon) {
    if (coupon.discountType == 'PERCENTAGE') {
      return '${coupon.discountValue.toInt()}% OFF';
    }
    if (coupon.discountType == 'FIXED_AMOUNT') {
      return 'R\$ ${(coupon.discountValue / 100).toStringAsFixed(2)} OFF';
    }
    if (coupon.discountType == 'FREE_DELIVERY') {
      return 'Frete Grátis';
    }
    return '';
  }

  Color _generateCouponBackground(int id, bool isDark) {
    final colors = isDark
        ? [
      Color(0xFF004D40),
      Color(0xFF3E2723),
      Color(0xFF1A237E),
      Color(0xFF4A148C),
      Color(0xFF880E4F)
    ]
        : [
      Color(0xFFE0F7FA),
      Color(0xFFFFF9C4),
      Color(0xFFD1C4E9),
      Color(0xFFE1F5FE),
      Color(0xFFFFCDD2)
    ];
    return colors[id % colors.length];
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final backgroundColor = coupon.isActive
        ? _generateCouponBackground(coupon.id!, isDark)
        : (isDark ? Color(0xFF7F1D1D) : Color(0xFFFEE2E2));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDiscount(coupon),
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Editar cupom',
                onPressed: () => onEdit(coupon),
              ),
            ],
          ),
          Text(
            coupon.description,
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    coupon.code,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5
                    ),
                  ),
                  if(coupon.isActive)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: coupon.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado!')),
                        );
                      },
                    ),
                ],
              ),
              if (coupon.endDate != null)
                Text(
                  'Válido até: ${dateFormat.format(coupon.endDate!)}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall,
                ),
            ],
          ),
          Text(
            coupon.isActive ? 'ATIVO' : 'INATIVO',
            style: TextStyle(
              color: coupon.isActive ? Colors.green.shade700 : Colors.red
                  .shade700,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}