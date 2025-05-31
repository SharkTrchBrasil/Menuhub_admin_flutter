import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/app_edit_controller.dart';
import '../../core/app_list_controller.dart';
import '../../core/di.dart';
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
                AppPrimaryButton(label: 'Adicionar', onPressed: () async {

                  DialogService.showPaymentDialog(
                    context,
                    widget.storeId,

                    onSaved: (coupon) {
                      categoriesController.refresh();
                    },
                  );


                }),
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
                    return AppPageStatusBuilder<List<StorePaymentMethod>>(
                      tryAgain: categoriesController.refresh,
                      status: categoriesController.status,
                      successBuilder: (coupons) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: coupons.length,
                          itemBuilder: (context, index) {
                            final method = coupons[index];
        
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Ícone baseado no tipo
                                    CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      child: Icon(
                                        _getPaymentIcon(method.paymentType),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
        
                                    // Nome e info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            method.customName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (method.taxRate != 0)
                                            Text(
                                              '${method.taxRate.toStringAsFixed(2) }%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          if (method.pixKey != null &&
                                              method.pixKey!.isNotEmpty &&
                                              method.customName.toLowerCase() ==
                                                  "pix")
                                            Text(
                                              'Chave Pix: ${method.pixKey}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.teal,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                   if (method.paymentType != 'Cash')
                                    Row(
                                      children: [

                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            final result = await paymentRepository.deletePaymentMethod(widget.storeId, method.id!);

                                            result.fold(
                                                  (left) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Erro ao deletar')),
                                                );
                                              },
                                                  (right) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Deletado com sucesso')),
                                                );
                                               categoriesController.refresh();
                                              },
                                            );
                                          },
                                        ),


                                        SizedBox(width: 25),
                                        IconButton(
                                          icon:  Icon(
                                            Icons.edit,
                                            color: Theme.of(context).primaryColor
                                          ),
                                          onPressed: () {

                                            DialogService.showPaymentDialog(
                                              context,
                                              paymentId: method.id!,
                                              widget.storeId,
                                              onSaved: (coupon) {
                                                categoriesController.refresh();
                                              },
                                            );


                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
        return Icons.account_balance_wallet_outlined ;
    }
  }
}
