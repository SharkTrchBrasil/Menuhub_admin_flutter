












import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/app_list_controller.dart';
import '../../core/di.dart';

import '../../repositories/store_repository.dart';
import '../../services/dialog_service.dart';

import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';

import '../../widgets/fixed_header.dart';
import '../base/BasePage.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final StoreRepository storeRepository = getIt();
  final paymentRepository = GetIt.I<StorePaymentMethodRepository>();
  final formKey = GlobalKey<FormState>();

  late final AppListController<StorePaymentMethod> categoriesController =
      AppListController<StorePaymentMethod>(
        fetch:
            () => getIt<StorePaymentMethodRepository>().getPaymentMethods(
              widget.storeId,
            ),
      );

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Métodos de pagamento'),
      mobileBuilder: (BuildContext context) {
        return Column(
          children: [
            firstcontain(size: MediaQuery.of(context).size.width),
            const SizedBox(height: 70),
          ],
        );
      },
      desktopBuilder: (BuildContext context) {
        return Column(
          children: [
            FixedHeader(
              title: 'Pagamentos manuais',

              actions: [
                AppPrimaryButton(
                  label: 'Adicionar',
                  onPressed: () async {
                    DialogService.showPaymentDialog(
                      context,
                      widget.storeId,

                      onSaved: (coupon) {
                        categoriesController.refresh();
                      },
                    );
                  },
                ),
              ],
            ),

            Expanded(
              child: firstcontain(size: MediaQuery.of(context).size.width),
            ),
          ],
        );
      },

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showPaymentDialog(
              context,
              widget.storeId,

              onSaved: (coupon) {
                categoriesController.refresh();
              },
            );
          },
          tooltip: 'Novo',
          elevation: 0,

          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget firstcontain({required double size}) {
    int crossAxisCount = 1;
    if (MediaQuery.of(context).size.width >= 1200) {
      crossAxisCount = 3;
    } else if (MediaQuery.of(context).size.width >= 800) {
      crossAxisCount = 2;
    } else if (MediaQuery.of(context).size.width >= 600) {
      crossAxisCount = 1;
    } else {
      crossAxisCount = 1;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10),
      child: AnimatedBuilder(
        animation: categoriesController,
        builder: (_, __) {
          return AppPageStatusBuilder<List<StorePaymentMethod>>(
            tryAgain: categoriesController.refresh,
            status: categoriesController.status,
            successBuilder: (coupons) {
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: coupons.length,
                  physics: NeverScrollableScrollPhysics(),

                  // evita conflito de rolagem
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 96,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final method = coupons[index];
                    final color = _generateColorFromId(method.id.toString());

                    return Container(
                      height: 96,
                    //  margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08), // Borda sutil
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ListTile(
                          dense: true,

                          leading: CircleAvatar(
                            backgroundColor:  Theme.of(context).colorScheme.onSurface,
                            radius: 24,

                            child: Icon(
                              _getPaymentIcon(method.paymentType),
                              color: color,
                            ),
                          ),
                          title: Text(
                            method.customName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (method.taxRate != 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Taxa: ${method.taxRate.toStringAsFixed(2)}%',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              if (method.paymentType.toLowerCase() == 'pix' &&
                                  method.pixKey != null &&
                                  method.pixKey!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Chave Pix: ${method.pixKey}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //
                              //     Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 8,
                              //         vertical: 4,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color:
                              //         method.isActive
                              //             ? Colors.green[100]
                              //             : Colors.red[100],
                              //         borderRadius: BorderRadius.circular(8),
                              //       ),
                              //       child: Text(
                              //         method.isActive ? 'Ativo' : 'Inativo',
                              //         style: TextStyle(
                              //           color:
                              //           method.isActive
                              //               ? Colors.green[800]
                              //               : Colors.red[800],
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                          trailing:
                              method.paymentType != 'Cash'
                                  ? PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        DialogService.showPaymentDialog(
                                          context,
                                          paymentId: method.id!,
                                          widget.storeId,
                                          onSaved:
                                              (coupon) =>
                                                  categoriesController
                                                      .refresh(),
                                        );
                                      } else if (value == 'delete') {
                                        final result = await paymentRepository
                                            .deletePaymentMethod(
                                              widget.storeId,
                                              method.id!,
                                            );

                                        result.fold(
                                          (left) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Erro ao deletar',
                                                ),
                                              ),
                                            );
                                          },
                                          (right) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Deletado com sucesso',
                                                ),
                                              ),
                                            );
                                            categoriesController.refresh();
                                          },
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Editar'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Excluir'),
                                              ),
                                            ],
                                    icon: const Icon(Icons.more_vert),
                                  )
                                  : Text('Padrão'),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _generateColorFromId(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];

    final hash = id.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }


  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'pix':
        return Icons.qr_code;
      case 'other':
        return Icons.currency_bitcoin;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
