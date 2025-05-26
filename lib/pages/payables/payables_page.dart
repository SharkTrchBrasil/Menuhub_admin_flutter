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
  final paymentRepository = GetIt.I<StorePaymentMethodRepository>();
  final formKey = GlobalKey<FormState>();

  late final AppListController<StorePayable> categoriesController =
      AppListController<StorePayable>(
        fetch:
            () => getIt<StoreRepository>().getPayables(
              widget.storeId,
            ),
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
                AppPrimaryButton(label: 'Adicionar', onPressed: () async {

                  DialogService.showPayableDialog(
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
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: coupons.length,
                          itemBuilder: (context, index) {
                            final method = coupons[index];
        
                            return Container(child: Text(method.title),);
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


}
