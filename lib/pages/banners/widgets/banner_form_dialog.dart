import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/widgets/base_dialog.dart';


import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../models/banners.dart';

import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../repositories/banner_repository.dart';

import '../../../repositories/category_repository.dart';
import '../../../repositories/product_repository.dart';
import '../../../widgets/app_counter_form_field.dart';
import '../../../widgets/app_date_time_form_field.dart';
import '../../../widgets/app_image_form_field.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../widgets/app_selection_form_field.dart';
import '../../../widgets/app_table.dart';
import '../../../widgets/app_text_field.dart';
import 'banner_image_form_field.dart';


class EditBannerForm extends StatefulWidget {
  final int storeId;
  final int? id;
  final void Function(BannerModel)? onSaved;

  const EditBannerForm({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved,
  });

  @override
  State<EditBannerForm> createState() => _EditBannerFormState();
}

class _EditBannerFormState extends State<EditBannerForm> {
  final formKey = GlobalKey<FormState>();
  final repository = getIt<BannerRepository>();

  late final AppEditController<void, BannerModel> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getBanner(widget.storeId, id),
    save: (category) => repository.saveBanner(widget.storeId, category),
    empty: () => BannerModel(),
  );

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<BannerModel>(
          status: controller.status,
          successBuilder: (banner) {

            return BaseDialog(



              content: Container(
                // height: 200,
                width:
                MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width
                    : 500,
              //  padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [


                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 500,


                              child: BannerImageFormField(
                                initialValue: banner.image,
                                title: '',

                                validator: (image) {
                                  if (image == null) {
                                    return 'Selecione uma imagem';
                                  }
                                  return null;
                                },
                                onChanged: (image) {
                                  controller.onChanged(
                                    banner.copyWith(image: image),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                        Row(
                          children: [

                            Flexible(
                              child: AppSelectionFormField<Product>(
                                title: 'Produto',
                                fetch:
                                    () => getIt<ProductRepository>()
                                    .getProducts(widget.storeId),
                                columns: [
                                  AppTableColumnString(
                                    title: 'Nome',
                                    dataSelector: (p) => p.name,
                                  ),
                                ],
                                onChanged: (product) {
                                  controller.onChanged(
                                    banner.copyWith(product: product),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 20,),


                            Flexible(
                              child: AppSelectionFormField<Category>(
                                title: 'Categoria',

                                initialValue: banner.category,
                                fetch:
                                    () => getIt<CategoryRepository>()
                                    .getCategories(widget.storeId),

                                onChanged: (category) {
                                  controller.onChanged(
                                    banner.copyWith(category: category),
                                  );
                                },
                                columns: [
                                  AppTableColumnString(
                                    title: 'Nome',
                                    dataSelector: (c) => c.name,
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Flexible(
                              child: AppDateTimeFormField(
                                initialValue: banner.startDate,
                                title: 'Início do banner',

                                onChanged: (v) {
                                  controller.onChanged(
                                    banner.copyWith(startDate: v),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 20,),

                            Flexible(
                              child: AppDateTimeFormField(
                                initialValue: banner.endDate,
                                title: 'Fim do banner',

                                onChanged: (v) {
                                  controller.onChanged(
                                    banner.copyWith(endDate: v),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),



                        const SizedBox(height: 25),

                        AppTextField(
                          initialValue: banner.linkUrl,
                          title: 'Link externo',
                          hint: '',

                          onChanged: (name) {
                            controller.onChanged(
                              banner.copyWith(linkUrl: name),
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [

                            Flexible(
                              child: AppCounterFormField(
                                initialValue: banner.position,
                                minValue: 1,
                                maxValue: 10,
                                title: 'Prioridade',
                                validator: (priority) {
                                  if (priority! > 5) {
                                    return 'Prioridade muito alta!';
                                  }
                                  return null;
                                },
                                onChanged: (priority) {
                                  controller.onChanged(
                                    banner.copyWith(
                                        position: priority),
                                  );
                                },
                              ),
                            ),

                            Flexible(
                              child: Row(
                                children: [
                                  Flexible(child: Text('Banner ativo')),
                                  Switch(
                                    value: banner.isActive,
                                    onChanged: (value) {
                                      controller.onChanged(banner.copyWith(isActive: value));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),
              ),
              title: widget.id == null ? 'Criar banner' : 'Editar banner',
              onSave:     () async {

              if (formKey.currentState!.validate()) {
                final result = await controller.saveData();
                if (result.isRight && context.mounted) {
                  widget.onSaved?.call(result.right);
                  context.pop(); // fecha o dialog
                }
              }
            },
              saveText: 'Salvar',
            );

          },
        );
      },
    );








  }
}
