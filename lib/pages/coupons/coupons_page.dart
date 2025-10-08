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
        // Initialization code if needed
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

    if (coupon != null) {
      print('--- 3. Navegando para a tela de edição ---');
      print('Passando cupom via extra com ${coupon.rules.length} regras.');
    }

    context.go(route, extra: coupon);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobileBuilder: (context, constraints) => _buildMobileLayout(context),
      desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
    );
  }

  // Layout Mobile: Lista vertical simples
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        children: [
          // Header para mobile
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FixedHeader(
              showActionsOnMobile: true,
              title: 'Minhas promoções',
              subtitle: 'Gerencie suas promoções.',
              actions: [
                DsButton(
                  label: 'Criar cupom',
                  style: DsButtonStyle.secondary,
                  onPressed: () => _onAddOrEdit,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildCouponsList(context),
          ),
        ],
      ),
    );
  }

  // Layout do Desktop: inclui o FixedHeader completo
  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            child: _buildCouponsList(context),
          ),
        ],
      ),
    );
  }

  // Lista de cupons (comum para mobile e desktop)
  Widget _buildCouponsList(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is StoresManagerInitial || state is StoresManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StoresManagerError) {
          return Center(child: Text(state.message));
        }
        if (state is StoresManagerLoaded) {
          final coupons = state.activeStore?.relations.coupons ?? [];

          if (coupons.isEmpty) {
            return const Center(child: Text('Nenhum cupom cadastrado.'));
          }

          return ListView.builder(
          //  padding: const EdgeInsets.all(16.0),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 12),
                child: _CouponListItem(
                  coupon: coupon,
                  dateFormat: _dateFormat,
                  storeId: state.activeStoreId,
                  onEdit: (coupon) {
                    print(coupon);
                    _onAddOrEdit(coupon: coupon);
                  },
                  isMobile: ResponsiveBuilder.isMobile(context),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget para o item individual da lista de cupons
class _CouponListItem extends StatelessWidget {
  const _CouponListItem({
    required this.coupon,
    required this.storeId,
    required this.dateFormat,
    required this.onEdit,
    required this.isMobile,
  });

  final Coupon coupon;
  final int storeId;
  final DateFormat dateFormat;
  final void Function(Coupon) onEdit;
  final bool isMobile;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: isMobile ? _buildMobileItem(context) : _buildDesktopItem(context),
    );
  }

  // Layout para mobile - mais compacto
  Widget _buildMobileItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com código e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      coupon.code,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (coupon.isActive)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        padding: const EdgeInsets.only(left: 8.0),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: coupon.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        },
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: coupon.isActive ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: coupon.isActive ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  coupon.isActive ? 'ATIVO' : 'INATIVO',
                  style: TextStyle(
                    color: coupon.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Desconto e descrição
          Text(
            _formatDiscount(coupon),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coupon.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Data e botão de editar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (coupon.endDate != null)
                Text(
                  'Válido até: ${dateFormat.format(coupon.endDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => onEdit(coupon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Layout para desktop - mais detalhado
  Widget _buildDesktopItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Informações principais
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coupon.code,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (coupon.isActive)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        padding: const EdgeInsets.only(left: 8.0),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: coupon.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  coupon.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Tipo de desconto
          Expanded(
            flex: 1,
            child: Text(
              _formatDiscount(coupon),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
          // Data de validade
          Expanded(
            flex: 1,
            child: coupon.endDate != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Válido até:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  dateFormat.format(coupon.endDate!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
                : const Text('Sem data limite'),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: coupon.isActive ? Colors.green.shade50 : Colors.red.shade50,
                border: Border.all(
                  color: coupon.isActive ? Colors.green.shade200 : Colors.red.shade200,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                coupon.isActive ? 'ATIVO' : 'INATIVO',
                style: TextStyle(
                  color: coupon.isActive ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Ações
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Editar cupom',
            onPressed: () => onEdit(coupon),
          ),
        ],
      ),
    );
  }
}