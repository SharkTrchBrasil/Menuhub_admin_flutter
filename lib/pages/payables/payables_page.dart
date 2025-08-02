import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/store_payable.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/app_edit_controller.dart';
import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../core/helpers/mask.dart';
import '../../models/store_pix_config.dart';
import '../../repositories/store_repository.dart';
import '../../services/dialog_service.dart';
import '../../widgets/app_file_form_field.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toasts.dart';
import '../../widgets/fixed_header.dart';
import '../base/BasePage.dart';

class PayablePage extends StatefulWidget {
  const PayablePage({super.key, required this.storeId});

  final int storeId;

  @override
  State<PayablePage> createState() => _PayablePageState();
}

class _PayablePageState extends State<PayablePage> {
  final StoreRepository storeRepository = getIt();
//  final paymentRepository = GetIt.I<StorePaymentMethodRepository>();
  final formKey = GlobalKey<FormState>();

  late final AppListController<StorePayable> categoriesController =
      AppListController<StorePayable>(
        fetch: () => getIt<StoreRepository>().getPayables(widget.storeId),
      );

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Contas a pagar'),
      mobileBuilder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              firstcontain(size: MediaQuery.of(context).size.width),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
      desktopBuilder: (BuildContext context) {
        return Column(
          children: [
            FixedHeader(
              title: 'Contas a pagar',

              actions: [
                AppPrimaryButton(
                  label: 'Adicionar',
                  onPressed: () async {
                    DialogService.showPayableDialog(
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
            DialogService.showPayableDialog(
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Layout para mobile
                return AnimatedBuilder(
                  animation: categoriesController,
                  builder: (_, __) {
                    return AppPageStatusBuilder<List<StorePayable>>(
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisExtent: 180,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];
                              return cardss(coupon, widget.storeId);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget cardss(StorePayable payable, int storeId) {


    return Material(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ListTile com título, valor e opções
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  payable.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatCurrency(payable.amount),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(payable.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _statusLabel(payable.status),
                        style: TextStyle(
                          color: _statusColor(payable.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'editar') {
                    DialogService.showPayableDialog(
                      context,
                      widget.storeId,
                      paymentId: payable.id,
                      onSaved: (_) => categoriesController.refresh(),
                    );
                  } else if (value == 'excluir') {


                    _deletePayable(payable);

                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ),


            /// Datas
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text("Vencimento: ${dateFormat.format(DateTime.parse(payable.dueDate))}"),
              ],
            ),
            const SizedBox(height: 8),

            if ((payable.paymentDate ?? '').isNotEmpty)
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.grey[700]),
                if ((payable.paymentDate ?? '').isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text("Pago em: ${dateFormat.format(DateTime.parse(payable.paymentDate!))}"),
                ],
              ],
            ),

            const SizedBox(height: 12),

            /// Status

          ],
        ),
      ),

    );
  }


  Future<void> _deletePayable(StorePayable product) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content:
      'Tem certeza que deseja excluir o produto "${product.title}"?'.tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;

      try {
        await getIt<StoreRepository>().deletePayable(
          widget.storeId,
          product.id!,
        );

        // Atualiza a lista sem setState
        await categoriesController.refresh();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produto "${product.title}" excluído com sucesso.'.tr(),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir produto: ${e.toString()}'.tr()),
            ),
          );
        }
      }
    }

  }
  }

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return 'Pago';
    case 'pending':
      return 'Pendente';
    case 'overdue':
      return 'Vencido';
    default:
      return 'Desconhecido';
  }
}


Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

String _formatCurrency(int cents) {
  final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
  return formatter.format(cents / 100);
}
