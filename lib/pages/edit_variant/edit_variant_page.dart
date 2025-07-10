import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/app_counter_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_switch.dart';
import 'package:totem_pro_admin/widgets/app_switch_form_field.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../widgets/fixed_header.dart';
import '../edit_variant_option/edit_variant_option_page.dart';
import 'widgets/variant_option_list_item.dart';

class EditVariantPage extends StatefulWidget {
  const EditVariantPage({super.key, required this.storeId, this.id});

  final int storeId;

  final int? id;

  @override
  State<EditVariantPage> createState() => _EditVariantPageState();
}

class _EditVariantPageState extends State<EditVariantPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ProductRepository repository = getIt();

  late final AppEditController<void, Variant> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getVariant(widget.storeId, id),
    save: (variant) => repository.saveVariant(widget.storeId, variant),
    empty: () => Variant(),
  );

  Future<void> save() async {
    final result = await controller.saveData();
    if (result.isRight && mounted) {
      context.go('/stores/${widget.storeId}/variants/${result.right.id}');
    }
  }


  // Função para abrir o dialog de adição/edição de opção
  Future<void> _showOptionDialog({int? optionId}) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditVariantOptionPage(
          storeId: widget.storeId,
          variantId: widget.id!, // variantId deve ser não nulo aqui
          id: optionId, // Passa o ID da opção se estiver editando
        );
      },
    );

    // Se o dialog foi fechado com sucesso (result == true), recarrega a variante
    if (result == true) {
      await controller.refresh(); // Recarrega a variante para atualizar a lista de opções
    }
  }



  bool showUnpublished = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<Variant>(
          status: controller.status,
          successBuilder: (variant) {
            return Form(
              key: formKey,
              child: BasePage(
                mobileAppBar: AppBarCustom(title: 'Variantes'),

                mobileBuilder: (BuildContext context) {
                  return


                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 40,),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Column(
                              children: [

                                AppTextField(
                                  initialValue: variant.name,
                                  title: 'Título da variante',
                                  hint: 'Ex: Sabor',
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
                                      variant.copyWith(name: name),
                                    );
                                  },
                                ),

                                SizedBox(height: 25,),

                                AppTextField(
                                  initialValue: variant.description,
                                  title: 'Descrição da variante',
                                  hint: 'Ex: Sabor do produto',
                                  validator: (title) {
                                    if (title == null ||
                                        title.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if (title.length < 10) {
                                      return 'Descrição muito curta';
                                    }
                                    return null;
                                  },
                                  onChanged: (desc) {
                                    controller.onChanged(
                                      variant.copyWith(
                                        description: desc,
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: 25,),
                                Row(
                                  children: [


                                    Flexible(
                                      flex:2,
                                      child: AppCounterFormField(
                                        initialValue: variant.minQuantity,
                                        minValue: 1,
                                        maxValue: 100,
                                        title: 'Mínimo',
                                        validator: (quantity) {
                                          return null;
                                        },
                                        onChanged: (quantity) {
                                          controller.onChanged(
                                            variant.copyWith(
                                              minQuantity: quantity,
                                            ),
                                          );
                                        },
                                      ),
                                    ),


                                    Flexible(
                                      flex:2,
                                      child: AppCounterFormField(
                                        initialValue: variant.maxQuantity,
                                        minValue: 1,
                                        maxValue: 100,
                                        title: 'Máximo',
                                        validator: (quantity) {
                                          final variant =
                                              (controller.status
                                              as PageStatusSuccess<
                                                  Variant
                                              >)
                                                  .data;

                                          if (variant.minQuantity >
                                              quantity!) {
                                            return 'Máximo deve ser maior que o mínimo';
                                          }
                                          return null;
                                        },
                                        onChanged: (quantity) {
                                          controller.onChanged(
                                            variant.copyWith(
                                              maxQuantity: quantity,
                                            ),
                                          );
                                        },
                                      ),
                                    ),





                                  ],
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: AppSwitchFormField(
                                        title: 'Pode repetir?',
                                        initialValue: variant.repeatable,
                                        onChanged:
                                            (value) => controller.onChanged(
                                          variant.copyWith(
                                            repeatable: value,
                                          ),
                                        ),
                                        validator: (value) {
                                          final variant =
                                              (controller.status
                                              as PageStatusSuccess<
                                                  Variant
                                              >)
                                                  .data;
                                    
                                          if (value != null &&
                                              value &&
                                              variant.maxQuantity == 1) {
                                            return 'Repetível só pode ser selecionado se o máximo for maior que 1';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 40,),

                              ],
                            ),
                          ),




                          if (widget.id != null) ...[
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Opções',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Exibir\ndespublicados',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppSwitch(
                                    value: showUnpublished,
                                    onChanged: (v) {
                                      setState(() {
                                        showUnpublished = v;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Material(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        for (final o in variant.options!
                                            .where(
                                              (v) =>
                                          showUnpublished ||
                                              v.available,
                                        ))
                                          VariantOptionListItem(
                                            option: o,
                                            storeId: widget.storeId,

                                            variantId: widget.id!, onSaved: null,
                                          ),
                                        AppPrimaryButton(
                                          label: 'Adicionar opção',

                                          onPressed:
                                              () =>   _showOptionDialog(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );



                },
                desktopBuilder: (BuildContext context) {
                  return Column(
                    children: [
                      FixedHeader(
                        title: 'Modificadores',

                        actions: [
                          AppPrimaryButton(
                            label: 'Salvar',

                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await controller.saveData();
                              }
                            },
                          ),
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40,),

                              Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: AppTextField(
                                      initialValue: variant.name,
                                      title: 'Título da variante',
                                      hint: 'Ex: Sabor',
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
                                          variant.copyWith(name: name),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    child: AppTextField(
                                      initialValue: variant.description,
                                      title: 'Descrição da variante',
                                      hint: 'Ex: Sabor do produto',
                                      validator: (title) {
                                        if (title == null ||
                                            title.isEmpty) {
                                          return 'Campo obrigatório';
                                        } else if (title.length < 10) {
                                          return 'Descrição muito curta';
                                        }
                                        return null;
                                      },
                                      onChanged: (desc) {
                                        controller.onChanged(
                                          variant.copyWith(
                                            description: desc,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: AppCounterFormField(
                                      initialValue: variant.minQuantity,
                                      minValue: 1,
                                      maxValue: 100,
                                      title: 'Mínimo',
                                      validator: (quantity) {
                                        return null;
                                      },
                                      onChanged: (quantity) {
                                        controller.onChanged(
                                          variant.copyWith(
                                            minQuantity: quantity,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: AppCounterFormField(
                                      initialValue: variant.maxQuantity,
                                      minValue: 1,
                                      maxValue: 100,
                                      title: 'Máximo',
                                      validator: (quantity) {
                                        final variant =
                                            (controller.status
                                                    as PageStatusSuccess<
                                                      Variant
                                                    >)
                                                .data;

                                        if (variant.minQuantity >
                                            quantity!) {
                                          return 'Máximo deve ser maior que o mínimo';
                                        }
                                        return null;
                                      },
                                      onChanged: (quantity) {
                                        controller.onChanged(
                                          variant.copyWith(
                                            maxQuantity: quantity,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: AppSwitchFormField(
                                      title: 'Pode repetir?',
                                      initialValue: variant.repeatable,
                                      onChanged:
                                          (value) => controller.onChanged(
                                            variant.copyWith(
                                              repeatable: value,
                                            ),
                                          ),
                                      validator: (value) {
                                        final variant =
                                            (controller.status
                                                    as PageStatusSuccess<
                                                      Variant
                                                    >)
                                                .data;

                                        if (value != null &&
                                            value &&
                                            variant.maxQuantity == 1) {
                                          return 'Repetível só pode ser selecionado se o máximo for maior que 1';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  // opções
                                ],
                              ),

                              if (widget.id != null) ...[
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Opções',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Exibir\ndespublicados',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AppSwitch(
                                        value: showUnpublished,
                                        onChanged: (v) {
                                          setState(() {
                                            showUnpublished = v;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Material(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final o in variant.options!
                                                .where(
                                                  (v) =>
                                                      showUnpublished ||
                                                      v.available,
                                                ))
                                              VariantOptionListItem(
                                                option: o,
                                                storeId: widget.storeId,

                                                variantId: widget.id!, onSaved: null,
                                              ),
                                            AppPrimaryButton(
                                              label: 'Adicionar opção',
                                              onPressed:
                                                  () => context.go(
                                                    '/stores/${widget.storeId}/variants/${widget.id}/options/new',
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                mobileBottomNavigationBar: AppPrimaryButton(
                  label: 'Salvar',

                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await controller.saveData();
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}







































// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:totem_pro_admin/core/app_edit_controller.dart';
// import 'package:totem_pro_admin/core/di.dart';
// import 'package:totem_pro_admin/models/page_status.dart';
// import 'package:totem_pro_admin/models/variant.dart';
// import 'package:totem_pro_admin/repositories/product_repository.dart';
// import 'package:totem_pro_admin/widgets/app_counter_form_field.dart';
// import 'package:totem_pro_admin/widgets/app_page_header.dart';
// import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
// import 'package:totem_pro_admin/widgets/app_primary_button.dart';
// import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
// import 'package:totem_pro_admin/widgets/app_switch.dart';
// import 'package:totem_pro_admin/widgets/app_switch_form_field.dart';
// import 'package:totem_pro_admin/widgets/app_text_field.dart';
//
// import 'widgets/variant_option_list_item.dart';
//
// class EditProductVariantPage extends StatefulWidget {
//   const EditProductVariantPage({
//     super.key,
//     required this.storeId,
//     this.id,
//     required this.productId,
//   });
//
//   final int storeId;
//   final int productId;
//   final int? id;
//
//   @override
//   State<EditProductVariantPage> createState() => _EditProductVariantPageState();
// }
//
// class _EditProductVariantPageState extends State<EditProductVariantPage> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   final ProductRepository repository = getIt();
//
//   late final AppEditController<void,ProductVariant> controller = AppEditController(
//     id: widget.id,
//     fetch: (id) => repository.getProductVariant(widget.storeId, widget.productId, id),
//     save: (variant) => repository.saveProductVariant(widget.storeId, widget.productId, variant),
//     empty: () => ProductVariant(),
//   );
//
//   Future<void> save() async {
//     final result = await controller.saveData();
//     if (result.isRight && mounted) {
//       context.go(
//         '/stores/${widget.storeId}/products/${widget.productId}/variants/${result.right.id}',
//       );
//     }
//   }
//
//   bool showUnpublished = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (_, __) {
//           return AppPageStatusBuilder<ProductVariant>(
//             status: controller.status,
//             successBuilder: (variant) {
//               return Column(
//                 children: [
//                   AppPageHeader(
//                     title: 'Editar Variante de Produto',
//                     actions: [
//                       AppSecondaryButton(
//                         label:
//                             'Salvar e ${variant.available ? 'Despublicar' : 'Publicar'}',
//                         onPressed: () async {
//                           if (formKey.currentState!.validate()) {
//                             controller.onChanged(
//                               variant.copyWith(available: !variant.available),
//                             );
//                             save();
//                           }
//                         },
//                       ),
//                       AppPrimaryButton(
//                         label: 'Salvar',
//                         onPressed: () async {
//                           if (formKey.currentState!.validate()) {
//                             save();
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Material(
//                         color: Colors.white,
//                         child: Padding(
//                           padding: const EdgeInsets.all(24),
//                           child: Form(
//                             key: formKey,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             child: Wrap(
//                               spacing: 24,
//                               runSpacing: 24,
//                               children: [
//                                 SizedBox(
//                                   width: 200,
//                                   child: AppTextField(
//                                     initialValue: variant.name,
//                                     title: 'Título da variante',
//                                     hint: 'Ex: Sabor',
//                                     validator: (title) {
//                                       if (title == null || title.isEmpty) {
//                                         return 'Campo obrigatório';
//                                       } else if (title.length < 3) {
//                                         return 'Título muito curto';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: (name) {
//                                       controller.onChanged(
//                                         variant.copyWith(name: name),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 400,
//                                   child: AppTextField(
//                                     initialValue: variant.description,
//                                     title: 'Descrição da variante',
//                                     hint: 'Ex: Sabor do produto',
//                                     validator: (title) {
//                                       if (title == null || title.isEmpty) {
//                                         return 'Campo obrigatório';
//                                       } else if (title.length < 10) {
//                                         return 'Descrição muito curta';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: (desc) {
//                                       controller.onChanged(
//                                         variant.copyWith(description: desc),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 200,
//                                   child: AppCounterFormField(
//                                     initialValue: variant.minQuantity,
//                                     minValue: 1,
//                                     maxValue: 100,
//                                     title: 'Mínimo',
//                                     validator: (quantity) {
//                                       return null;
//                                     },
//                                     onChanged: (quantity) {
//                                       controller.onChanged(
//                                         variant.copyWith(minQuantity: quantity),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 200,
//                                   child: AppCounterFormField(
//                                     initialValue: variant.maxQuantity,
//                                     minValue: 1,
//                                     maxValue: 100,
//                                     title: 'Máximo',
//                                     validator: (quantity) {
//                                       final variant = (controller.status as PageStatusSuccess<ProductVariant>).data;
//
//                                       if (variant.minQuantity > quantity!) {
//                                         return 'Máximo deve ser maior que o mínimo';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: (quantity) {
//                                       controller.onChanged(
//                                         variant.copyWith(maxQuantity: quantity),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 200,
//                                   child: AppSwitchFormField(
//                                     title: 'Pode repetir?',
//                                     initialValue: variant.repeatable,
//                                     onChanged:
//                                         (value) => controller.onChanged(
//                                           variant.copyWith(repeatable: value),
//                                         ),
//                                     validator: (value) {
//                                       final variant = (controller.status as PageStatusSuccess<ProductVariant>).data;
//
//                                       if(value != null && value && variant.maxQuantity == 1) {
//                                         return 'Repetível só pode ser selecionado se o máximo for maior que 1';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (widget.id != null) ...[
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Opções',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           const Text(
//                             'Exibir\ndespublicados',
//                             textAlign: TextAlign.end,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           AppSwitch(
//                             value: showUnpublished,
//                             onChanged: (v) {
//                               setState(() {
//                                 showUnpublished = v;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.topLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 24),
//                         child: Material(
//                           color: Colors.white,
//                           child: Padding(
//                             padding: const EdgeInsets.all(24),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 for (final o in variant.options!.where(
//                                         (v) => showUnpublished || v.available))
//                                   VariantOptionListItem(
//                                     option: o,
//                                     storeId: widget.storeId,
//                                     productId: widget.productId,
//                                     variantId: widget.id!,
//                                   ),
//                                 AppPrimaryButton(
//                                   label: 'Adicionar opção',
//                                   onPressed: () => context.go(
//                                       '/stores/${widget.storeId}/products/${widget.productId}/variants/${widget.id}/options/new'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
