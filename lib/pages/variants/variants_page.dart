import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/page_status.dart';
import '../../models/variant.dart';
import '../../repositories/product_repository.dart';
import '../../services/dialog_service.dart';
import '../../widgets/app_counter_form_field.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_switch_form_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fixed_header.dart';
import '../../widgets/mobileappbar.dart';
import '../base/BasePage.dart';
import '../edit_variant/widgets/variant_option_list_item.dart';

class VariantsPage extends StatefulWidget {
  const VariantsPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {
  late final AppListController<Variant> variantsController = AppListController<
    Variant
  >(fetch: () => getIt<ProductRepository>().getVariantsByStore(widget.storeId));

  bool showUnpublished = false;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Adicionais'),
      mobileBuilder: (_) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _variantsGrid(size: MediaQuery.of(context).size.width),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
      desktopBuilder: (_) {
        return Column(
          children: [
            FixedHeader(
              title: 'Adicionais',
              actions: [
                AppPrimaryButton(
                  label: 'Adicionar',
                  onPressed: () {
                    DialogService.showVariantsDialog(
                      context,
                      widget.storeId,
                      onSaved: (_) => variantsController.refresh(),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _variantsGrid(size: MediaQuery.of(context).size.width),
              ),
            ),
          ],
        );
      },
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showVariantsDialog(
              context,
              widget.storeId,
              onSaved: (_) => variantsController.refresh(),
            );
          },
          tooltip: 'Novo adicional',
          elevation: 0,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _variantsGrid({required double size}) {
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
                  animation: variantsController,
                  builder: (_, __) {
                    return AppPageStatusBuilder<List<Variant>>(
                      tryAgain: variantsController.refresh,
                      status: variantsController.status,
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
                              return _variantCard(coupon);
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

  Widget _variantCard(Variant variant) {




    return Material(
      elevation: 1,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          variant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: const Text(
                        'Exibir inativos',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),

                    Switch(
                      value: showUnpublished,
                      onChanged: (v) {
                        setState(() {
                          showUnpublished = v;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                for (final o in variant.options!.where(
                  (v) => showUnpublished || v.available,
                ))
                  VariantOptionListItem(
                    option: o,
                    storeId: widget.storeId,
                    //  productId: widget.productId,
                    variantId: variant.id!,

                    onSaved: () => variantsController.refresh(),
                  ),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,

                  title: Row(
                    children: const [
                      Icon(Icons.add, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Nova opção', overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  onTap: () {
                    DialogService.showVariantsOptionsDialog(
                      context,
                      widget.storeId,
                      variant.id!,
                      onSaved: () async {
                        await variantsController.refresh();
                      },
                    );
                  },
                ),
              ),

              Expanded(
                child: ListTile(

                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Editar adicional', overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  onTap: () {
                    DialogService.showVariantsDialog(
                      context,
                      variantId: variant.id,
                      widget.storeId,
                      onSaved: (_) => variantsController.refresh(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
