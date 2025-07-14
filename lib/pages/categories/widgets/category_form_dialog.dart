import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/widgets/base_dialog.dart';


import '../../../ConstData/typography.dart';
import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../models/category.dart';
import '../../../repositories/category_repository.dart';
import '../../../widgets/app_counter_form_field.dart';
import '../../../widgets/app_image_form_field.dart';
import '../../../widgets/app_image_form_field_category.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../widgets/app_primary_button.dart';
import '../../../widgets/app_text_field.dart';

class EditCategoryForm extends StatefulWidget {
  final int storeId;
  final int? id;
  final void Function(Category)? onSaved;

  const EditCategoryForm({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved,
  });

  @override
  State<EditCategoryForm> createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends State<EditCategoryForm> {
  final formKey = GlobalKey<FormState>();
  final repository = getIt<CategoryRepository>();

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

            return BaseDialog(



              content: Container(
                // height: 200,
                width:
                MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width
                    : 300,
              //  padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                  children: [
                    SingleChildScrollView(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [


                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 160,

                                child: AppImageFormField(
                                  initialValue: category.image,
                                  title: '',
                                  aspectRatio: 1,
                                  validator: (image) {
                                    if (image == null) {
                                      return 'Selecione uma imagem';
                                    }
                                    return null;
                                  },
                                  onChanged: (image) {
                                    controller.onChanged(
                                      category.copyWith(image: image),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),


                          const SizedBox(height: 25),

                          AppTextField(
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
                          const SizedBox(height: 25),

                          AppCounterFormField(
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




                          const SizedBox(height: 25),


                        ],
                      ),
                    ),
                  ],


                  ),
                ),
              ),
              title: widget.id == null ? 'Criar categoria' : 'Editar categoria',
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
