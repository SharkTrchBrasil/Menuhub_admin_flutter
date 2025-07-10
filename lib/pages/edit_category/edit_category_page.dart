import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/widgets/app_counter_form_field.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../ConstData/typography.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key, required this.storeId, this.id});

  final int storeId;
  final int? id;

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final CategoryRepository repository = getIt();

  late final AppEditController<void, Category> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getCategory(widget.storeId, id),
    save: (category) => repository.saveCategory(widget.storeId, category),
    empty: () => Category(),
  );

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return AppPageStatusBuilder<Category>(
              status: controller.status,
              successBuilder: (category) {
                return SafeArea(
                  child: Scaffold(

                    body: SingleChildScrollView(
                      //  padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Material(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: formKey,
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  child: Wrap(
                                    spacing: 24,
                                    runSpacing: 24,
                                    children: [
                                      // AppImageFormField(
                                      //   initialValue: category.image,
                                      //   title: 'Imagem',
                                      //   aspectRatio: 1,
                                      //   validator: (image) {
                                      //     if (image == null) {
                                      //       return 'Selecione uma imagem';
                                      //     }
                                      //     return null;
                                      //   },
                                      //   onChanged: (image) {
                                      //     controller.onChanged(
                                      //       category.copyWith(image: image),
                                      //     );
                                      //   },
                                      // ),
                                      SizedBox(
                                        width: 200,
                                        child: AppTextField(
                                          initialValue: category.name,
                                          title: 'Título da categoria',
                                          hint: 'Ex: Bebidas',
                                          validator: (title) {
                                            if (title == null ||
                                                title.isEmpty) {
                                              return 'Campo obrigatório';
                                            } else if (title.length < 3) {
                                              return 'Título muito curto';
                                            }
                                            return null;
                                          },
                                          onChanged: (name) {
                                            controller.onChanged(
                                              category.copyWith(name: name),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: AppCounterFormField(
                                          initialValue: category.priority,
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
                                              category.copyWith(
                                                  priority: priority),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )


                        ],
                      ),
                    ),


                    bottomSheet: Container(
                      padding: context.isSmallScreen
                          ? EdgeInsets.all(0)
                          : EdgeInsets
                          .all(24),
                     // color: notifire.getBgColor,
                      width: double.infinity,
                      child: Row(
                        children: [

                          Expanded(
                            child: AppPrimaryButton(
                              label: 'Salvar',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final result = await controller.saveData();
                                  if (result.isRight && context.mounted) {
                                    context.go(
                                        '/stores/${widget
                                            .storeId}/categories/${result
                                            .right.id}');
                                  }
                                }
                              },
                            ),
                          ),


                          context.isSmallScreen ? SizedBox.shrink() : SizedBox(
                              width: 16),
                          context.isSmallScreen ? SizedBox.shrink() :
                          Expanded(

                            child: AppSecondaryButton(
                              label: 'Descartar',
                              onPressed: () async {
                                context.pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),


                  ),
                );
              });
        }
    );

  }
}
