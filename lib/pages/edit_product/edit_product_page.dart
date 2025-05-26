import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:either_dart/either.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/constdata/typography.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/models/product.dart';

import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/pages/edit_product/widgets/product_variant_list_item.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';



import '../../models/category.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/fixed_header.dart';
import '../../widgets/mobileappbar.dart';
//import 'package:bs_flutter_selectbox/bs_flutter_selectbox.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key, required this.storeId, this.id});

  final int storeId;
  final int? id;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ProductRepository repository = getIt();

  late final AppEditController<void, Product> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getProduct(widget.storeId, id),
    save: (product) => repository.saveProduct(widget.storeId, product),
    empty: () => Product(),
  );

  Future<void> save() async {
    final result = await controller.saveData();
    if (result.isRight && widget.id == null && mounted) {
      context.replace('/stores/${widget.storeId}/products/${result.right.id}');
    }
  }


  bool light0 = false; // valor inicial padrão

  bool light1 = false;
  bool light2 = true;






  bool showUnpublished = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<Product>(
          status: controller.status,
          successBuilder: (product) {

            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              child:  SizedBox(
                width:
                MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width * 0.7,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: BasePage(

                    mobileAppBar: AppBarCustom( title:  widget.id == null ? 'Criar produto' : 'Editar produto',),

                    mobileBuilder: (BuildContext context) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    // width: 400,
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Geral',
                                                style: TextStyle(
                                                  // color:
                                                  //  notifire.textcolore,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          // titulo
                                          AppTextField(
                                            initialValue: product.name,
                                            title: 'Nome',
                                            hint: 'Nome do produto',
                                            validator: (title) {
                                              if (title == null ||
                                                  title.isEmpty) {
                                                return 'Campo obrigatório';
                                              } else if (title.length <
                                                  3) {
                                                return 'Título muito curto';
                                              }
                                              return null;
                                            },
                                            onChanged: (name) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  name: name,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          AppTextField(
                                            initialValue:
                                            product.description,
                                            title: 'Descrição',
                                            hint: 'Descreva seu produto',
                                            validator: (title) {
                                              if (title == null ||
                                                  title.isEmpty) {
                                                return 'Campo obrigatório';
                                              } else if (title.length <
                                                  10) {
                                                return 'Descrição muito curta';
                                              }
                                              return null;
                                            },
                                            onChanged: (desc) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  description: desc,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          //categoria
                                          Row(
                                            children: [
                                              // Flexible(
                                              //   child: AppSelectionFormField<
                                              //       Category
                                              //   >(
                                              //     title: 'Categoria',
                                              //
                                              //     initialValue:
                                              //     product.category,
                                              //     fetch:
                                              //         () => getIt<
                                              //         CategoryRepository
                                              //     >()
                                              //         .getCategories(
                                              //       widget
                                              //           .storeId,
                                              //     ),
                                              //     validator: (category) {
                                              //       if (category ==
                                              //           null) {
                                              //         return 'Campo obrigatório';
                                              //       }
                                              //       return null;
                                              //     },
                                              //     onChanged: (category) {
                                              //       controller.onChanged(
                                              //         product.copyWith(
                                              //           category:
                                              //               () =>
                                              //           category,
                                              //         ),
                                              //       );
                                              //     },
                                              //     columns: [
                                              //       AppTableColumnString(
                                              //         title: 'Nome',
                                              //         dataSelector:
                                              //             (c) => c.name,
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                            ],
                                          ),

                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),
                            Container(
                              // width: 400,
                              decoration: BoxDecoration(
                              //  color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Preço',
                                          style: TextStyle(
                                            //  color: notifire.textcolore,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: AppTextField(
                                            initialValue:
                                            product.basePrice != null
                                                ? UtilBrasilFields.obterReal(
                                              product.basePrice! /
                                                  100,
                                            )
                                                : '',
                                            title: 'Preço',
                                            hint: 'Ex: R\$ 5,00',
                                            formatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CentavosInputFormatter(
                                                moeda: true,
                                              ),
                                            ],
                                            onChanged: (value) {
                                              final money =
                                              UtilBrasilFields.converterMoedaParaDouble(
                                                value ?? '',
                                              );

                                              controller.onChanged(
                                                product.copyWith(
                                                  basePrice:
                                                  (money * 100)
                                                      .floor(),
                                                ),
                                              );
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.length < 7) {
                                                return 'Campo obrigatório';
                                              }

                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 20),

                                        Flexible(
                                          child: AppTextField(
                                            initialValue:
                                            product.costPrice != null
                                                ? UtilBrasilFields.obterReal(
                                              product.costPrice! /
                                                  100,
                                            )
                                                : '',
                                            title: 'Custo do produto',
                                            hint: 'Ex: R\$ 1,00',
                                            formatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CentavosInputFormatter(
                                                moeda: true,
                                              ),
                                            ],
                                            onChanged: (value) {
                                              final money =
                                              UtilBrasilFields.converterMoedaParaDouble(
                                                value ?? '',
                                              );

                                              controller.onChanged(
                                                product.copyWith(
                                                  costPrice:
                                                  (money * 100)
                                                      .floor(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Flexible(
                                          child: AppTextField(
                                            initialValue:
                                            product.costPrice != null
                                                ? UtilBrasilFields.obterReal(
                                              product.costPrice! /
                                                  100,
                                            )
                                                : '',
                                            title: 'Peço com desconto',
                                            hint: 'Ex: R\$ 1,00',
                                            formatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CentavosInputFormatter(
                                                moeda: true,
                                              ),
                                            ],
                                            onChanged: (value) {
                                              final money =
                                              UtilBrasilFields.converterMoedaParaDouble(
                                                value ?? '',
                                              );

                                              controller.onChanged(
                                                product.copyWith(
                                                  costPrice:
                                                  (money * 100)
                                                      .floor(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        // Flexible(
                                        //   child: AppSelectionFormField<
                                        //       UnitOption
                                        //   >(
                                        //     title: 'Unidade medida',
                                        //
                                        //     initialValue: unitOptions
                                        //         .firstWhereOrNull(
                                        //           (e) =>
                                        //       e.value ==
                                        //           selectedUnitOption,
                                        //     ),
                                        //     fetch: fetchUnitOptions,
                                        //     columns: [
                                        //       AppTableColumnString<
                                        //           UnitOption
                                        //       >(
                                        //         title: 'Unidade',
                                        //         dataSelector:
                                        //             (item) => item.label,
                                        //       ),
                                        //     ],
                                        //     validator: (item) {
                                        //       if (item == null)
                                        //         return 'Campo obrigatório';
                                        //       return null;
                                        //     },
                                        //     onChanged: (item) {
                                        //       setState(() {
                                        //         selectedUnitOption =
                                        //             item?.value;
                                        //       });
                                        //     },
                                        //   ),
                                        // ),
                                      ],
                                    ),

                                    //   Row(children: [Expanded(child: apk())]),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),
                            Container(
                              // width: 400,
                              decoration: BoxDecoration(
                               // color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Estoque',
                                          style: TextStyle(
                                            //  color: notifire.textcolore,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Controlar estoque',
                                              style: TextStyle(
                                                // color:
                                                //     notifire.textcolore,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Switch(
                                              value: product.controlStock,
                                              onChanged: (bool value) {
                                                controller.onChanged(
                                                  product.copyWith(
                                                    controlStock: value,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),

                                        // Mostra os dois TextFormField se o switch estiver ativo
                                        if (product.controlStock) ...[
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            title: 'Estoque',
                                            hint: '0',
                                            initialValue:
                                            product.stockQuantity
                                                .toString(),

                                            keyboardType:
                                            TextInputType.number,
                                            onChanged: (ean) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  stockQuantity:
                                                  int.tryParse(ean!),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          AppTextField(
                                            initialValue:
                                            product.minStock
                                                .toString(),

                                            title: 'Estoque mín.',
                                            hint: 'Digite o mínimo',
                                            keyboardType:
                                            TextInputType.number,
                                            onChanged: (ean) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  minStock: int.tryParse(
                                                    ean!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 20),
                                    //   Row(children: [Expanded(child: apk())]),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                // height: Get.height,
                                // width: 400,
                                decoration: BoxDecoration(
                               //   color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [secoundecontain(product)],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                // height: Get.height,
                                // width: 400,
                                decoration: BoxDecoration(
                               //   color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 8,
                                      ),
                                      child: Text(
                                        'Opções',
                                        style: TextStyle(
                                          // color: notifire.textcolore,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Produto disponível ?',
                                              style: TextStyle(
                                                // color:
                                                // notifire.textcolore,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(width: 5),
                                          Switch(
                                            value: product.available,

                                            onChanged: (bool value) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  available: value,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // identificação do produto
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                // height: Get.height,
                                // width: 400,
                                decoration: BoxDecoration(
                                //  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 8,
                                      ),
                                      child: Text(
                                        'Identificação do Produto',
                                        style: TextStyle(
                                          //    color: notifire.textcolore,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: AppTextField(
                                              title: 'EAN/GTIN',
                                              hint: '',
                                              initialValue: product.ean,
                                              // validator: (title) {
                                              //   if (title == null ||
                                              //       title.isEmpty) {
                                              //     return 'Campo obrigatório';
                                              //   } else if (title.length <
                                              //       3) {
                                              //     return 'Título muito curto';
                                              //   }
                                              //   return null;
                                              // },
                                              formatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],

                                              onChanged: (ean) {
                                                controller.onChanged(
                                                  product.copyWith(
                                                    ean: ean,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    desktopBuilder: (BuildContext context) {
                      return Column(
                        children: [

                          FixedHeader(title: 'Produtos',

                            actions: [
                              AppPrimaryButton(label: 'Salvar',

                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await controller.saveData();
                                  }
                                },

                              )
                            ],

                          ),

                          Expanded(
                            child: SingleChildScrollView(

                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 30,
                                    ),
                                    child: Container(
                                      // height: 1500,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                            child: Container(
                                                              // width: 400,
                                                              decoration: BoxDecoration(
                                                                // color:
                                                                // notifire
                                                                //   .containcolore1,
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                      height: 20,
                                                                    ),
                                                                    // titulo
                                                                    AppTextField(
                                                                      initialValue:
                                                                      product
                                                                          .name,
                                                                      title: 'Nome',
                                                                      hint:
                                                                      'Ex: Guaraná',
                                                                      validator: (
                                                                          title,
                                                                          ) {
                                                                        if (title ==
                                                                            null ||
                                                                            title
                                                                                .isEmpty) {
                                                                          return 'Campo obrigatório';
                                                                        } else if (title
                                                                            .length <
                                                                            3) {
                                                                          return 'Título muito curto';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      onChanged: (
                                                                          name,
                                                                          ) {
                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            name:
                                                                            name,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 20,
                                                                    ),
                                                                    //descrição
                                                                    AppTextField(
                                                                      initialValue:
                                                                      product
                                                                          .description,
                                                                      title:
                                                                      'Descrição',
                                                                      hint:
                                                                      'Descreva seu produto',
                                                                      validator: (
                                                                          title,
                                                                          ) {
                                                                        if (title ==
                                                                            null ||
                                                                            title
                                                                                .isEmpty) {
                                                                          return 'Campo obrigatório';
                                                                        } else if (title
                                                                            .length <
                                                                            10) {
                                                                          return 'Descrição muito curta';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      onChanged: (
                                                                          desc,
                                                                          ) {
                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            description:
                                                                            desc,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),

                                                                    const SizedBox(
                                                                      height: 20,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        AppSelectionFormField<Category>(
                                                                          title: 'Categoria',
                                                                          initialValue: product.category,
                                                                          fetch:
                                                                              () => getIt<CategoryRepository>()
                                                                              .getCategories(widget.storeId),
                                                                          validator: (category) {
                                                                            if (category == null) {
                                                                              return 'Campo obrigatório';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          onChanged:
                                                                              (category) => controller.onChanged(
                                                                            product.copyWith(
                                                                              category: () => category,
                                                                            ),
                                                                          ),
                                                                          columns: [
                                                                            AppTableColumnString(
                                                                              title: 'Nome',
                                                                              dataSelector: (c) => c.name,
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 20,
                                                      ),
                                                      child: Container(
                                                        // width: 400,
                                                        decoration: BoxDecoration(
                                                          //  color:
                                                          //     notifire
                                                          //  .containcolore1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'Preço',
                                                                    style: TextStyle(
                                                                      // color:
                                                                      //  notifire
                                                                      //     .textcolore,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: AppTextField(
                                                                      initialValue:
                                                                      product.basePrice !=
                                                                          null
                                                                          ? UtilBrasilFields.obterReal(
                                                                        product.basePrice! /
                                                                            100,
                                                                      )
                                                                          : '',
                                                                      title:
                                                                      'Preço',
                                                                      hint:
                                                                      'Ex: R\$ 5,00',
                                                                      formatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly,
                                                                        CentavosInputFormatter(
                                                                          moeda:
                                                                          true,
                                                                        ),
                                                                      ],
                                                                      onChanged: (
                                                                          value,
                                                                          ) {
                                                                        final money =
                                                                        UtilBrasilFields.converterMoedaParaDouble(
                                                                          value ??
                                                                              '',
                                                                        );

                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            basePrice:
                                                                            (money *
                                                                                100)
                                                                                .floor(),
                                                                          ),
                                                                        );
                                                                      },
                                                                      validator: (
                                                                          value,
                                                                          ) {
                                                                        if (value ==
                                                                            null ||
                                                                            value.length <
                                                                                7) {
                                                                          return 'Campo obrigatório';
                                                                        }

                                                                        return null;
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),

                                                                  Flexible(
                                                                    child: AppTextField(
                                                                      initialValue:
                                                                      product.costPrice !=
                                                                          null
                                                                          ? UtilBrasilFields.obterReal(
                                                                        product.costPrice! /
                                                                            100,
                                                                      )
                                                                          : '',
                                                                      title:
                                                                      'Custo do produto',
                                                                      hint:
                                                                      'Ex: R\$ 1,00',
                                                                      formatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly,
                                                                        CentavosInputFormatter(
                                                                          moeda:
                                                                          true,
                                                                        ),
                                                                      ],
                                                                      onChanged: (
                                                                          value,
                                                                          ) {
                                                                        final money =
                                                                        UtilBrasilFields.converterMoedaParaDouble(
                                                                          value ??
                                                                              '',
                                                                        );

                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            costPrice:
                                                                            (money *
                                                                                100)
                                                                                .floor(),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: AppTextField(
                                                                      initialValue:
                                                                      product.costPrice !=
                                                                          null
                                                                          ? UtilBrasilFields.obterReal(
                                                                        product.costPrice! /
                                                                            100,
                                                                      )
                                                                          : '',
                                                                      title:
                                                                      'Peço com desconto',
                                                                      hint:
                                                                      'Ex: R\$ 1,00',
                                                                      formatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly,
                                                                        CentavosInputFormatter(
                                                                          moeda:
                                                                          true,
                                                                        ),
                                                                      ],
                                                                      onChanged: (
                                                                          value,
                                                                          ) {
                                                                        final money =
                                                                        UtilBrasilFields.converterMoedaParaDouble(
                                                                          value ??
                                                                              '',
                                                                        );

                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            costPrice:
                                                                            (money *
                                                                                100)
                                                                                .floor(),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),

                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),

                                                                  AppSelectionFormField<Category>(
                                                                    title: 'Categoria',
                                                                    initialValue: product.category,
                                                                    fetch:
                                                                        () => getIt<CategoryRepository>()
                                                                        .getCategories(widget.storeId),
                                                                    validator: (category) {
                                                                      if (category == null) {
                                                                        return 'Campo obrigatório';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onChanged:
                                                                        (category) => controller.onChanged(
                                                                      product.copyWith(
                                                                        category: () => category,
                                                                      ),
                                                                    ),
                                                                    columns: [
                                                                      AppTableColumnString(
                                                                        title: 'Nome',
                                                                        dataSelector: (c) => c.name,
                                                                      ),
                                                                    ],
                                                                  ),

                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 20,
                                                      ),
                                                      child: Container(
                                                        // width: 400,
                                                        decoration: BoxDecoration(
                                                          //   color:
                                                          //   notifire
                                                          //     .containcolore1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'Estoque',
                                                                    style: TextStyle(
                                                                      //   color:
                                                                      //  notifire
                                                                      //      .textcolore,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        child: Text(
                                                                          'Controlar estoque',
                                                                          style: TextStyle(
                                                                            //   color:
                                                                            //    notifire.textcolore,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 5,
                                                                      ),

                                                                      Switch(
                                                                        value:
                                                                        product
                                                                            .controlStock,

                                                                        onChanged: (
                                                                            bool
                                                                            value,
                                                                            ) {
                                                                          controller.onChanged(
                                                                            product.copyWith(
                                                                              controlStock:
                                                                              value,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  // Mostra os dois TextFormField se o switch estiver ativo
                                                                  if (product
                                                                      .controlStock) ...[
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),

                                                                    Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child: AppTextField(
                                                                            title:
                                                                            'Estoque',
                                                                            hint:
                                                                            '0',
                                                                            initialValue:
                                                                            product.stockQuantity.toString(),

                                                                            keyboardType:
                                                                            TextInputType.number,
                                                                            onChanged: (
                                                                                ean,
                                                                                ) {
                                                                              controller.onChanged(
                                                                                product.copyWith(
                                                                                  stockQuantity: int.tryParse(
                                                                                    ean!,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width: 20,
                                                                        ),
                                                                        Flexible(
                                                                          child: AppTextField(
                                                                            initialValue:
                                                                            product.minStock.toString(),

                                                                            title:
                                                                            'Estoque mín.',
                                                                            hint:
                                                                            'Digite o mínimo',
                                                                            keyboardType:
                                                                            TextInputType.number,
                                                                            onChanged: (
                                                                                ean,
                                                                                ) {
                                                                              controller.onChanged(
                                                                                product.copyWith(
                                                                                  minStock: int.tryParse(
                                                                                    ean!,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),


                                                              if (widget.id != null) ...[
                                                                Padding(
                                                                  padding: const EdgeInsets.all(24),
                                                                  child: Row(
                                                                    children: [
                                                                      const Expanded(
                                                                        child: Text(
                                                                          'Variantes',
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
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            for (final v in product.variants!.where(
                                                                                    (v) => showUnpublished || v.available))
                                                                              ProductVariantListItem(
                                                                                storeId: widget.storeId,

                                                                                variant: v,
                                                                                showUnpublished: showUnpublished,
                                                                              ),
                                                                            AppPrimaryButton(
                                                                              label: 'Adicionar variante',
                                                                              onPressed: () => context.go(
                                                                                  '/stores/${widget.storeId}/products/${product.id}/variants/new'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],








                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                                  children: [
                                                    //imagem
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 15,
                                                        right: 10,
                                                        left: 10,
                                                      ),
                                                      child: Container(
                                                        // height: Get.height,
                                                        // width: 400,
                                                        decoration: BoxDecoration(
                                                          //  color:
                                                          //   notifire
                                                          //   .containcolore1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              secoundecontain(
                                                                product,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // opções
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 20,
                                                        right: 10,
                                                        left: 10,
                                                      ),
                                                      child: Container(
                                                        // height: Get.height,
                                                        // width: 400,
                                                        decoration: BoxDecoration(
                                                          // color:
                                                          ///notifire
                                                          // .containcolore1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                  left: 10,
                                                                ),
                                                                child: Text(
                                                                  'Opções',
                                                                  style: TextStyle(
                                                                    //  color:
                                                                    //    notifire
                                                                    //      .textcolore,
                                                                  ),
                                                                ),
                                                              ),

                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                  left: 10,
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        'Produto disponível ?',
                                                                        style: TextStyle(
                                                                          //     color:
                                                                          //      notifire
                                                                          //        .textcolore,
                                                                        ),
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                      ),
                                                                    ),

                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Switch(
                                                                      value:
                                                                      product
                                                                          .available,

                                                                      onChanged: (
                                                                          bool value,
                                                                          ) {
                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            available:
                                                                            value,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // identificação do produto
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 20,
                                                        right: 10,
                                                        left: 10,
                                                      ),
                                                      child: Container(
                                                        // height: Get.height,
                                                        // width: 400,
                                                        decoration: BoxDecoration(
                                                          //  color:
                                                          //  notifire
                                                          //   .containcolore1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                  left: 10,
                                                                ),
                                                                child: Text(
                                                                  'Identificação do Produto',
                                                                  style: TextStyle(
                                                                    //   color:
                                                                    //     notifire
                                                                    //   .textcolore,
                                                                  ),
                                                                ),
                                                              ),

                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    flex: 1,
                                                                    child: AppTextField(
                                                                      title:
                                                                      'EAN/GTIN',
                                                                      hint: '',
                                                                      initialValue:
                                                                      product
                                                                          .ean,
                                                                      // validator: (title) {
                                                                      //   if (title == null ||
                                                                      //       title.isEmpty) {
                                                                      //     return 'Campo obrigatório';
                                                                      //   } else if (title.length <
                                                                      //       3) {
                                                                      //     return 'Título muito curto';
                                                                      //   }
                                                                      //   return null;
                                                                      // },
                                                                      formatters: [
                                                                        FilteringTextInputFormatter
                                                                            .digitsOnly,
                                                                      ],

                                                                      onChanged: (
                                                                          ean,
                                                                          ) {
                                                                        controller.onChanged(
                                                                          product.copyWith(
                                                                            ean:
                                                                            ean,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),

                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
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
                                ],
                              ),
                            ),
                          ),

                        ],
                      );
                    },

                    mobileBottomNavigationBar: AppPrimaryButton(
                      label: 'Salvar',
                      onPressed:() async  {


                        if (formKey.currentState!.validate()) {
                          final result = await controller.saveData();
                          if (result.isRight && context.mounted) {
                            Navigator.pop(context);
                            context.go('/stores/${widget.storeId}/coupons');
                          }

                        }
                      },




                    ),
                  ),
                ),
              )
            );
          },
        );
      },
    );




  }

  // imagem
  Widget secoundecontain(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Row(children: []),

        AppImageFormField(
          initialValue: product.image,
          title: 'Imagem',
          aspectRatio: 1,
          validator: (image) {
            if (image == null) {
              return 'Selecione uma imagem';
            }
            return null;
          },
          onChanged: (image) {
            controller.onChanged(product.copyWith(image: image));
          },
        ),
      ],
    );
  }
}

class UnitOption implements SelectableItem {
  final String label;
  final String value;

  UnitOption({required this.label, required this.value});

  @override
  String get title => label;
}

Future<Either<void, List<UnitOption>>> fetchUnitOptions() async {
  return Right(unitOptions);
}

String? selectedUnitOption;

final List<UnitOption> unitOptions = [
  UnitOption(label: 'Unidade', value: 'UN'),
  UnitOption(label: 'Caixa', value: 'CX'),
  UnitOption(label: 'Peça', value: 'PC'),
  UnitOption(label: 'Litro', value: 'LT'),
  UnitOption(label: 'Mililitro', value: 'ML'),
  UnitOption(label: 'Quilograma', value: 'KG'),
  UnitOption(label: 'Grama', value: 'G'),
  UnitOption(label: 'Miligrama', value: 'MG'),
  UnitOption(label: 'Metro', value: 'M'),
  UnitOption(label: 'Centímetro', value: 'CM'),
  UnitOption(label: 'Milímetro', value: 'MM'),
  UnitOption(label: 'Pacote', value: 'PCT'),
  UnitOption(label: 'Dúzia', value: 'DZ'),
  UnitOption(label: 'Saco', value: 'SC'),
  UnitOption(label: 'Rolo', value: 'RL'),
  UnitOption(label: 'Fardo', value: 'FD'),
  UnitOption(label: 'Ampola', value: 'AM'),
  UnitOption(label: 'Frasco', value: 'FR'),
  UnitOption(label: 'Tubo', value: 'TB'),
  UnitOption(label: 'Placa', value: 'PL'),
  UnitOption(label: 'Bandeja', value: 'BD'),
  UnitOption(label: 'Jarra', value: 'JR'),
  UnitOption(label: 'Galão', value: 'GL'),
];


    // return AnimatedBuilder(
    //   animation: controller,
    //
    //   builder: (_, __) {
    //     return AppPageStatusBuilder<Product>(
    //       status: controller.status,
    //       successBuilder: (product) {
    //         light0 ??= product.controlStock ?? false;
    //
    //         // Se o produto já existir e tiver uma unidade, usa essa unidade. Se não, deixa como null.
    //         String? selectedUnitOption = product.unit ?? null;
    //
    //         // Verificar se o valor não está presente nas opções, e se for o caso, setar o valor para null
    //         if (selectedUnitOption != null && !unitOptions.any((option) => option['value'] == selectedUnitOption)) {
    //           selectedUnitOption = null;  // ou pode definir um valor padrão
    //         }
    //         return BasePage(
    //           mobileAppBar: AppBarCustom(title: 'Produtos'),
    //
    //           mobileBuilder: (BuildContext context) {
    //             return SingleChildScrollView(
    //               scrollDirection: Axis.vertical,
    //               child: Column(
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Expanded(
    //                         child: Padding(
    //                           padding: const EdgeInsets.only(
    //                             top: 20,
    //                             left: 10,
    //                             right: 10,
    //                           ),
    //                           child: Container(
    //                             // width: 400,
    //                             decoration: BoxDecoration(
    //                              / color: Theme.of(context).cardColor,
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                             child: Column(
    //                               children: [
    //                                 const SizedBox(height: 20),
    //                                 Row(
    //                                   children: [
    //                                     Padding(
    //                                       padding: const EdgeInsets.only(
    //                                         left: 10,
    //                                       ),
    //                                       child: Text(
    //                                         'Geral',
    //                                         style: TextStyle(
    //                                          // color: notifire.textcolore,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //                                 Row(
    //                                   children: [
    //                                     Flexible(
    //                                       flex: 2,
    //                                       child: txtfilled(
    //                                         txt1: 'Código',
    //                                         txt2: '',
    //                                         initialValue: product.code,
    //                                         // validator: (title) {
    //                                         //   if (title == null ||
    //                                         //       title.isEmpty) {
    //                                         //     return 'Campo obrigatório';
    //                                         //   } else if (title.length <
    //                                         //       3) {
    //                                         //     return 'Título muito curto';
    //                                         //   }
    //                                         //   return null;
    //                                         // },
    //                                         onChanged: (ean) {
    //                                           controller.onChanged(
    //                                             product.copyWith(code: ean),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //                                 Row(
    //                                   children: [
    //                                     Flexible(
    //                                       flex: 2,
    //                                       child: txtfilled(
    //                                         txt1: 'Código extra',
    //                                         txt2: '',
    //                                         initialValue: product.extraCode,
    //                                         // validator: (title) {
    //                                         //   if (title == null ||
    //                                         //       title.isEmpty) {
    //                                         //     return 'Campo obrigatório';
    //                                         //   } else if (title.length <
    //                                         //       3) {
    //                                         //     return 'Título muito curto';
    //                                         //   }
    //                                         //   return null;
    //                                         // },
    //                                         onChanged: (ean) {
    //                                           controller.onChanged(
    //                                             product.copyWith(
    //                                               extraCode: ean,
    //                                             ),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //                                 Row(
    //                                   children: [
    //                                     Flexible(
    //                                       flex: 2,
    //                                       child: txtfilled(
    //                                         txt1: 'EAN/GTIN',
    //                                         txt2: '',
    //                                         initialValue: product.ean,
    //                                         // validator: (title) {
    //                                         //   if (title == null ||
    //                                         //       title.isEmpty) {
    //                                         //     return 'Campo obrigatório';
    //                                         //   } else if (title.length <
    //                                         //       3) {
    //                                         //     return 'Título muito curto';
    //                                         //   }
    //                                         //   return null;
    //                                         // },
    //                                         onChanged: (ean) {
    //                                           controller.onChanged(
    //                                             product.copyWith(ean: ean),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //
    //                                 // titulo
    //                                 Row(
    //                                   children: [
    //                                     Flexible(
    //                                       flex: 2,
    //                                       child: txtfilled(
    //                                         txt1: 'Nome',
    //                                         txt2: 'Ex: Guaraná',
    //                                         initialValue: product.title,
    //
    //                                         onChanged: (name) {
    //                                           controller.onChanged(
    //                                             product.copyWith(name: name),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //
    //                                 //categoria
    //                                 Row(
    //                                   children: [
    //                                     Flexible(
    //                                       flex: 4,
    //                                       child: Padding(
    //                                         padding: const EdgeInsets.only(
    //                                           left: 10,
    //                                           right: 10,
    //                                         ),
    //                                         child: AppSelectionFormField<
    //                                           Category
    //                                         >(
    //
    //                                           title: 'Categoria',
    //                                           initialValue: product.category,
    //                                           fetch:
    //                                               () => getIt<
    //                                                     CategoryRepository
    //                                                   >()
    //                                                   .getCategories(
    //                                                     widget.storeId,
    //                                                   ),
    //                                           validator: (category) {
    //                                             if (category == null) {
    //                                               return 'Campo obrigatório';
    //                                             }
    //                                             return null;
    //                                           },
    //                                           onChanged: (category) {
    //                                             controller.onChanged(
    //                                               product.copyWith(
    //                                                 category: () => category,
    //                                               ),
    //                                             );
    //                                           },
    //                                           columns: [
    //                                             AppTableColumnString(
    //                                               title: 'Nome',
    //                                               dataSelector: (c) => c.name,
    //                                             ),
    //                                           ],
    //
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //
    //
    //
    //
    //                                 Row(
    //                                   children: [
    //
    //                                     Flexible(
    //                                       flex: 1,
    //                                       child: txtfilled(
    //                                         txt1: 'Peso liquido',
    //                                         txt2: 'ex: 600g',
    //                                         initialValue: product.extraCode,
    //                                         // validator: (title) {
    //                                         //   if (title == null ||
    //                                         //       title.isEmpty) {
    //                                         //     return 'Campo obrigatório';
    //                                         //   } else if (title.length <
    //                                         //       3) {
    //                                         //     return 'Título muito curto';
    //                                         //   }
    //                                         //   return null;
    //                                         // },
    //                                         onChanged: (ean) {
    //                                           controller.onChanged(
    //                                             product.copyWith(ean: ean),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                     Flexible(
    //                                       flex: 1,
    //                                       child: txtfilled(
    //                                         txt1: 'Peso bruto',
    //                                         txt2: 'ex: 800g',
    //                                         initialValue: product.extraCode,
    //                                         // validator: (title) {
    //                                         //   if (title == null ||
    //                                         //       title.isEmpty) {
    //                                         //     return 'Campo obrigatório';
    //                                         //   } else if (title.length <
    //                                         //       3) {
    //                                         //     return 'Título muito curto';
    //                                         //   }
    //                                         //   return null;
    //                                         // },
    //                                         onChanged: (ean) {
    //                                           controller.onChanged(
    //                                             product.copyWith(ean: ean),
    //                                           );
    //                                         },
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //
    //
    //
    //                                 // descrição
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Padding(
    //                                         padding: const EdgeInsets.only(
    //                                           left: 10,
    //                                           right: 10,
    //                                         ),
    //                                         child: Container(
    //                                           height: 150,
    //                                           decoration: BoxDecoration(
    //                                             border: Border.all(
    //                                               color: Colors.grey
    //                                                   .withOpacity(0.4),
    //                                             ),
    //                                             borderRadius:
    //                                                 const BorderRadius.all(
    //                                                   Radius.circular(10),
    //                                                 ),
    //                                           ),
    //                                           child: TextFormField(
    //                                             initialValue:
    //                                                 product.description,
    //
    //                                             validator: (title) {
    //                                               if (title == null ||
    //                                                   title.isEmpty) {
    //                                                 return 'Campo obrigatório';
    //                                               } else if (title.length <
    //                                                   10) {
    //                                                 return 'Descrição muito curta';
    //                                               }
    //                                               return null;
    //                                             },
    //                                             onChanged: (desc) {
    //                                               controller.onChanged(
    //                                                 product.copyWith(
    //                                                   description: desc,
    //                                                 ),
    //                                               );
    //                                             },
    //                                             style: TextStyle(
    //                                               color: notifire.textcolore,
    //                                             ),
    //                                             decoration: InputDecoration(
    //                                               contentPadding:
    //                                                   const EdgeInsets.only(
    //                                                     left: 10,
    //                                                   ),
    //                                               focusColor: Colors.red,
    //                                               hintText: 'Descrição',
    //                                               hintStyle: TextStyle(
    //                                                 color: notifire.textcolore,
    //                                               ),
    //                                               border: InputBorder.none,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 const SizedBox(height: 20),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.only(
    //                       top: 20,
    //                       left: 10,
    //                       right: 10,
    //                     ),
    //                     child: Container(
    //                       // width: 400,
    //                       decoration: BoxDecoration(
    //                         color: Theme.of(context).cardColor,
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                       child: Column(
    //                         children: [
    //                           const SizedBox(height: 20),
    //                           Row(
    //                             children: [
    //                               Padding(
    //                                 padding: const EdgeInsets.only(left: 10),
    //                                 child: Text(
    //                                   'Preço e estoque',
    //                                   style: TextStyle(
    //                                     color: notifire.textcolore,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //
    //                           const SizedBox(height: 20),
    //                           Row(
    //                             children: [
    //
    //                               Flexible(
    //                                 flex: 2,
    //                                 child: txtfilled(
    //                                   initialValue:
    //                                   product.basePrice != null
    //                                       ? UtilBrasilFields.obterReal(
    //                                     product.basePrice! / 100,
    //                                   )
    //                                       : '',
    //                                   txt1: 'Preço venda',
    //                                   txt2: 'Ex: R\$ 15,00',
    //                                   keyboardType: TextInputType.number,
    //                                   inputFormatters: [RealInputFormatter()],
    //                                   onChanged: (value) {
    //                                     final money =
    //                                     UtilBrasilFields.converterMoedaParaDouble(
    //                                       value ?? '',
    //                                     );
    //
    //                                     controller.onChanged(
    //                                       product.copyWith(
    //                                         basePrice: (money * 100).floor(),
    //                                       ),
    //                                     );
    //                                   },
    //                                   validator: (value) {
    //                                     if (value == null || value.length < 7) {
    //                                       return 'Campo obrigatório';
    //                                     }
    //
    //                                     return null;
    //                                   },
    //                                 ),
    //                               ),
    //                               Flexible(
    //                                 flex: 2,
    //                                 child: txtfilled(
    //                                   initialValue:
    //                                       product.costPrice != null
    //                                           ? UtilBrasilFields.obterReal(
    //                                             product.costPrice! / 100,
    //                                           )
    //                                           : '',
    //                                   txt1: 'Preço custo',
    //                                   txt2: 'Ex: R\$ 5,00',
    //                                   keyboardType: TextInputType.number,
    //                                   inputFormatters: [RealInputFormatter()],
    //                                   onChanged: (value) {
    //                                     final money =
    //                                         UtilBrasilFields.converterMoedaParaDouble(
    //                                           value ?? '',
    //                                         );
    //
    //                                     controller.onChanged(
    //                                       product.copyWith(
    //                                         basePrice: (money * 100).floor(),
    //                                       ),
    //                                     );
    //                                   },
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                           const SizedBox(height: 20),
    //
    //                           Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                               Padding(
    //                                 padding: const EdgeInsets.only(left: 10),
    //                                 child: Row(
    //                                   children: [
    //                                     Switch(
    //                                       value: light0,
    //                                       onChanged: (bool value) {
    //                                         setState(() {
    //                                           light0 = value;
    //                                         });
    //                                       },
    //                                     ),
    //                                     const SizedBox(width: 5),
    //                                     Text(
    //                                       'Controlar estoque',
    //                                       style: TextStyle(
    //                                         color: notifire.textcolore,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //
    //                               // Mostra os dois TextFormField se o switch estiver ativo
    //                               if (light0) ...[
    //                                 const SizedBox(height: 10),
    //                                 txtfilled(
    //                                   txt1: 'Estoque atual',
    //                                   txt2: '0',
    //                                   initialValue:
    //                                       product.stockQuantity.toString(),
    //
    //                                   keyboardType: TextInputType.number,
    //                                   onChanged: (ean) {
    //                                     controller.onChanged(
    //                                       product.copyWith(
    //                                         stockQuantity: int.tryParse(ean),
    //                                       ),
    //                                     );
    //                                   },
    //                                 ),
    //                                 const SizedBox(height: 10),
    //                                 txtfilled(
    //                                   initialValue: product.minStock.toString(),
    //
    //                                   txt1: 'Estoque mínimo',
    //                                   txt2: 'Digite o mínimo',
    //                                   keyboardType: TextInputType.number,
    //                                   onChanged: (ean) {
    //                                     controller.onChanged(
    //                                       product.copyWith(
    //                                         minStock: int.tryParse(ean),
    //                                       ),
    //                                     );
    //                                   },
    //                                 ),
    //                               ],
    //                             ],
    //                           ),
    //
    //                           Padding(
    //                             padding: const EdgeInsets.only(
    //                               left: 10,
    //                               right: 10,
    //                             ),
    //                             child: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Text(
    //                                   "Unidade medida",
    //                                   style: TextStyle(
    //                                     color: notifire.textcolore,
    //                                   ),
    //                                 ),
    //                                 const SizedBox(height: 10),
    //                                 Container(
    //                                   height: 53,
    //                                   decoration: BoxDecoration(
    //                                     border: Border.all(
    //                                       color: Colors.grey.withOpacity(0.4),
    //                                     ),
    //                                     borderRadius: const BorderRadius.all(
    //                                       Radius.circular(10),
    //                                     ),
    //                                   ),
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.only(top: 5),
    //                                     child: DropdownButtonFormField<String>(
    //
    //                                       dropdownColor:
    //                                           notifire.containcolore1,
    //                                       value: selectedUnitOption,
    //                                       padding: const EdgeInsets.only(
    //                                         left: 10,
    //                                       ),
    //                                       items:
    //                                           unitOptions.map((
    //                                             Map<String, String> option,
    //                                           ) {
    //                                             return DropdownMenuItem<String>(
    //                                               value: option['value'],
    //
    //                                               // Sigla para salvar no banco
    //                                               child: Text(
    //                                                 option['label']!,
    //                                                 // Nome visível
    //                                                 style: TextStyle(
    //                                                   color:
    //                                                       notifire.textcolore,
    //                                                 ),
    //                                               ),
    //                                             );
    //                                           }).toList(),
    //                                       onChanged: (String? newValue) {
    //                                         controller.onChanged(
    //                                           product.copyWith(
    //                                             unit: newValue,
    //                                           ),
    //                                         );
    //                                       },
    //                                       decoration: InputDecoration(
    //                                         hintText: 'Selecione',
    //                                         hintStyle: TextStyle(
    //                                           color: notifire.textcolore,
    //                                         ),
    //                                         border: InputBorder.none,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //
    //                           const SizedBox(height: 20),
    //                           //   Row(children: [Expanded(child: apk())]),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //
    //                   Padding(
    //                     padding: const EdgeInsets.only(
    //                       top: 20,
    //                       right: 10,
    //                       left: 10,
    //                     ),
    //                     child: Container(
    //                       // height: Get.height,
    //                       // width: 400,
    //                       decoration: BoxDecoration(
    //                         color: Theme.of(context).cardColor,
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsets.all(20),
    //                         child: Column(children: [secoundecontain()]),
    //                       ),
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.only(
    //                       top: 20,
    //                       right: 10,
    //                       left: 10,
    //                     ),
    //                     child: Container(
    //                       // height: Get.height,
    //                       // width: 400,
    //                       decoration: BoxDecoration(
    //                         color: Theme.of(context).cardColor,
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsets.all(20),
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           mainAxisAlignment: MainAxisAlignment.start,
    //                           children: [
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Text(
    //                                 'Settings',
    //                                 style: TextStyle(
    //                                   //color: notifire.textcolore,
    //                                 ),
    //                               ),
    //                             ),
    //                             const SizedBox(height: 15),
    //                             lastcontain(),
    //                             const SizedBox(height: 15),
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Column(
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.start,
    //                                 mainAxisAlignment: MainAxisAlignment.start,
    //                                 children: [
    //                                   Text(
    //                                     'Discussion',
    //                                     style: TextStyle(
    //                                       color: notifire.textcolore,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const SizedBox(height: 10),
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Row(
    //                                 children: [
    //                                   Switch(
    //                                     value: light0,
    //                                     onChanged: (bool value) {
    //                                       setState(() {
    //                                         light0 = value;
    //                                       });
    //                                     },
    //                                   ),
    //                                   const SizedBox(width: 5),
    //                                   Text(
    //                                     'Allow comments',
    //                                     style: TextStyle(
    //                                       color: notifire.textcolore,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const SizedBox(height: 10),
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Row(
    //                                 children: [
    //                                   Switch(
    //                                     value: light1,
    //                                     onChanged: (bool value) {
    //                                       setState(() {
    //                                         light1 = value;
    //                                       });
    //                                     },
    //                                   ),
    //                                   const SizedBox(width: 5),
    //                                   Text(
    //                                     'Allow Piggybacks & tracebacks',
    //                                     style: TextStyle(
    //                                       color: notifire.textcolore,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const SizedBox(height: 15),
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Column(
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.start,
    //                                 mainAxisAlignment: MainAxisAlignment.start,
    //                                 children: [
    //                                   Text(
    //                                     'Mobile App',
    //                                     style: TextStyle(
    //                                       color: notifire.textcolore,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             const SizedBox(height: 10),
    //                             Padding(
    //                               padding: const EdgeInsets.only(left: 10),
    //                               child: Row(
    //                                 children: [
    //                                   Switch(
    //                                     value: light2,
    //                                     onChanged: (bool value) {
    //                                       setState(() {
    //                                         light2 = value;
    //                                       });
    //                                     },
    //                                   ),
    //                                   const SizedBox(width: 5),
    //                                   Text(
    //                                     'Show mobile app',
    //                                     style: TextStyle(
    //                                       color: notifire.textcolore,
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 100),
    //                 ],
    //               ),
    //             );
    //           },
    //           desktopBuilder: (BuildContext context) {
    //             return SingleChildScrollView(
    //               scrollDirection: Axis.vertical,
    //               child: Column(
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Expanded(
    //                         child: AppPageHeader(
    //                           title: 'Produtos',
    //                           actions: [],
    //                           canPop: true,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(height: 0),
    //                   Padding(
    //                     padding: const EdgeInsets.only(
    //                       left: 10,
    //                       right: 10,
    //                       bottom: 30,
    //                     ),
    //                     child: Container(
    //                       // height: 1500,
    //                       decoration: BoxDecoration(
    //                         color: notifire.bgcolore,
    //                         borderRadius: const BorderRadius.all(
    //                           Radius.circular(10),
    //                         ),
    //                       ),
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Expanded(
    //                             flex: 2,
    //                             child: Column(
    //                               children: [
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Padding(
    //                                         padding: const EdgeInsets.only(
    //                                           top: 15,
    //                                         ),
    //                                         child: Container(
    //                                           // width: 400,
    //                                           decoration: BoxDecoration(
    //                                             color: Theme.of(context).cardColor,
    //                                             borderRadius:
    //                                                 BorderRadius.circular(10),
    //                                           ),
    //                                           child: Column(
    //                                             children: [
    //                                               const SizedBox(height: 20),
    //                                               Row(
    //                                                 children: [
    //                                                   Padding(
    //                                                     padding:
    //                                                         const EdgeInsets.only(
    //                                                           left: 10,
    //                                                         ),
    //                                                     child: Text(
    //                                                       'Geral',
    //                                                       style: TextStyle(
    //                                                         color:
    //                                                             notifire
    //                                                                 .textcolore,
    //                                                       ),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               const SizedBox(height: 20),
    //                                               Row(
    //                                                 children: [
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: txtfilled(
    //                                                       txt1: 'Código',
    //                                                       txt2: '',
    //                                                       initialValue: product.code,
    //                                                       // validator: (title) {
    //                                                       //   if (title == null ||
    //                                                       //       title.isEmpty) {
    //                                                       //     return 'Campo obrigatório';
    //                                                       //   } else if (title.length <
    //                                                       //       3) {
    //                                                       //     return 'Título muito curto';
    //                                                       //   }
    //                                                       //   return null;
    //                                                       // },
    //                                                       onChanged: (ean) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(code: ean),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: txtfilled(
    //                                                       txt1: 'Código extra',
    //                                                       txt2: '',
    //                                                       initialValue: product.extraCode,
    //                                                       // validator: (title) {
    //                                                       //   if (title == null ||
    //                                                       //       title.isEmpty) {
    //                                                       //     return 'Campo obrigatório';
    //                                                       //   } else if (title.length <
    //                                                       //       3) {
    //                                                       //     return 'Título muito curto';
    //                                                       //   }
    //                                                       //   return null;
    //                                                       // },
    //                                                       onChanged: (ean) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(
    //                                                             extraCode: ean,
    //                                                           ),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //
    //
    //                                               const SizedBox(height: 20),
    //                                               Row(
    //                                                 children: [
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: txtfilled(
    //                                                       txt1: 'EAN/GTIN',
    //                                                       txt2: '',
    //                                                       initialValue: product.ean,
    //                                                       // validator: (title) {
    //                                                       //   if (title == null ||
    //                                                       //       title.isEmpty) {
    //                                                       //     return 'Campo obrigatório';
    //                                                       //   } else if (title.length <
    //                                                       //       3) {
    //                                                       //     return 'Título muito curto';
    //                                                       //   }
    //                                                       //   return null;
    //                                                       // },
    //                                                       onChanged: (ean) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(ean: ean),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: SizedBox.shrink()
    //                                                   ),
    //                                                 ],
    //                                               ),
    //
    //
    //                                               const SizedBox(height: 20),
    //
    //                                               // titulo
    //                                               Row(
    //                                                 children: [
    //                                                   Flexible(
    //                                                     flex: 4,
    //                                                     child: txtfilled(
    //                                                       txt1: 'Nome',
    //                                                       txt2: 'Ex: Guaraná',
    //                                                       initialValue: product.title,
    //
    //                                                       onChanged: (name) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(name: name),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               const SizedBox(height: 20),
    //
    //
    //                                               Row(
    //                                                 children: [
    //                                                   Flexible(
    //                                                     flex: 4,
    //                                                     child: Padding(
    //                                                       padding:
    //                                                           const EdgeInsets.only(
    //                                                             left: 10,
    //                                                             right: 10,
    //                                                           ),
    //                                                       child: AppSelectionFormField<
    //                                                         Category
    //                                                       >(
    //
    //                                                         title: 'Categoria',
    //                                                         initialValue:
    //                                                             product
    //                                                                 .category,
    //                                                         fetch:
    //                                                             () => getIt<
    //                                                                   CategoryRepository
    //                                                                 >()
    //                                                                 .getCategories(
    //                                                                   widget
    //                                                                       .storeId,
    //                                                                 ),
    //                                                         validator: (
    //                                                           category,
    //                                                         ) {
    //                                                           if (category ==
    //                                                               null) {
    //                                                             return 'Campo obrigatório';
    //                                                           }
    //                                                           return null;
    //                                                         },
    //                                                         onChanged: (
    //                                                           category,
    //                                                         ) {
    //                                                           controller.onChanged(
    //                                                             product.copyWith(
    //                                                               category:
    //                                                                   () =>
    //                                                                       category,
    //                                                             ),
    //                                                           );
    //                                                         },
    //                                                         columns: [
    //                                                           AppTableColumnString(
    //                                                             title: 'Nome',
    //                                                             dataSelector:
    //                                                                 (c) =>
    //                                                                     c.name,
    //                                                           ),
    //                                                         ],
    //
    //                                                       ),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               const SizedBox(height: 20),
    //
    //
    //
    //                                               Row(
    //                                                 children: [
    //
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: txtfilled(
    //                                                       txt1: 'Peso liquido',
    //                                                       txt2: 'ex: 600g',
    //                                                       initialValue: product.extraCode,
    //                                                       // validator: (title) {
    //                                                       //   if (title == null ||
    //                                                       //       title.isEmpty) {
    //                                                       //     return 'Campo obrigatório';
    //                                                       //   } else if (title.length <
    //                                                       //       3) {
    //                                                       //     return 'Título muito curto';
    //                                                       //   }
    //                                                       //   return null;
    //                                                       // },
    //                                                       onChanged: (ean) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(ean: ean),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                   Flexible(
    //                                                     flex: 1,
    //                                                     child: txtfilled(
    //                                                       txt1: 'Peso bruto',
    //                                                       txt2: 'ex: 800g',
    //                                                       initialValue: product.extraCode,
    //                                                       // validator: (title) {
    //                                                       //   if (title == null ||
    //                                                       //       title.isEmpty) {
    //                                                       //     return 'Campo obrigatório';
    //                                                       //   } else if (title.length <
    //                                                       //       3) {
    //                                                       //     return 'Título muito curto';
    //                                                       //   }
    //                                                       //   return null;
    //                                                       // },
    //                                                       onChanged: (ean) {
    //                                                         controller.onChanged(
    //                                                           product.copyWith(ean: ean),
    //                                                         );
    //                                                       },
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               const SizedBox(height: 20),
    //
    //                                               // descrição
    //                                               Row(
    //                                                 children: [
    //                                                   Expanded(
    //                                                     child: Padding(
    //                                                       padding: const EdgeInsets.only(
    //                                                         left: 10,
    //                                                         right: 10,
    //                                                       ),
    //                                                       child: Container(
    //                                                         height: 150,
    //                                                         decoration: BoxDecoration(
    //                                                           border: Border.all(
    //                                                             color: Colors.grey
    //                                                                 .withOpacity(0.4),
    //                                                           ),
    //                                                           borderRadius:
    //                                                           const BorderRadius.all(
    //                                                             Radius.circular(10),
    //                                                           ),
    //                                                         ),
    //                                                         child: TextFormField(
    //                                                           initialValue:
    //                                                           product.description,
    //
    //                                                           validator: (title) {
    //                                                             if (title == null ||
    //                                                                 title.isEmpty) {
    //                                                               return 'Campo obrigatório';
    //                                                             } else if (title.length <
    //                                                                 10) {
    //                                                               return 'Descrição muito curta';
    //                                                             }
    //                                                             return null;
    //                                                           },
    //                                                           onChanged: (desc) {
    //                                                             controller.onChanged(
    //                                                               product.copyWith(
    //                                                                 description: desc,
    //                                                               ),
    //                                                             );
    //                                                           },
    //                                                           style: TextStyle(
    //                                                             color: notifire.textcolore,
    //                                                           ),
    //                                                           decoration: InputDecoration(
    //                                                             contentPadding:
    //                                                             const EdgeInsets.only(
    //                                                               left: 10,
    //                                                             ),
    //                                                             focusColor: Colors.red,
    //                                                             hintText: 'Descrição',
    //                                                             hintStyle: TextStyle(
    //                                                               color: notifire.textcolore,
    //                                                             ),
    //                                                             border: InputBorder.none,
    //                                                           ),
    //                                                         ),
    //                                                       ),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //
    //
    //
    //                                               const SizedBox(height: 20),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 Padding(
    //                                   padding: const EdgeInsets.only(top: 20),
    //                                   child: Container(
    //                                     // width: 400,
    //                                     decoration: BoxDecoration(
    //                                       color: Theme.of(context).cardColor,
    //                                       borderRadius: BorderRadius.circular(
    //                                         10,
    //                                       ),
    //                                     ),
    //                                     child: Column(
    //                                       children: [
    //                                         const SizedBox(height: 20),
    //                                         Row(
    //                                           children: [
    //                                             Padding(
    //                                               padding:
    //                                                   const EdgeInsets.only(
    //                                                     left: 10,
    //                                                   ),
    //                                               child: Text(
    //                                                 'Preço e estoque',
    //                                                 style: TextStyle(
    //                                                   color:
    //                                                       notifire.textcolore,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //
    //
    //                                         const SizedBox(height: 20),
    //                                         Row(
    //                                           children: [
    //
    //                                             Flexible(
    //                                               flex: 1,
    //                                               child: txtfilled(
    //                                                 initialValue:
    //                                                 product.basePrice != null
    //                                                     ? UtilBrasilFields.obterReal(
    //                                                   product.basePrice! / 100,
    //                                                 )
    //                                                     : '',
    //                                                 txt1: 'Preço venda',
    //                                                 txt2: 'Ex: R\$ 15,00',
    //                                                 keyboardType: TextInputType.number,
    //                                                 inputFormatters: [RealInputFormatter()],
    //
    //                                                 onChanged: (value) {
    //                                                   final money =
    //                                                   UtilBrasilFields.converterMoedaParaDouble(
    //                                                     value ?? '',
    //                                                   );
    //
    //                                                   controller.onChanged(
    //                                                     product.copyWith(
    //                                                       basePrice: (money * 100).floor(),
    //                                                     ),
    //                                                   );
    //                                                 },
    //                                                 validator: (value) {
    //                                                   if (value == null || value.length < 7) {
    //                                                     return 'Campo obrigatório';
    //                                                   }
    //
    //                                                   return null;
    //                                                 },
    //                                               ),
    //                                             ),
    //                                             Flexible(
    //                                               flex: 1,
    //                                               child: txtfilled(
    //                                                 initialValue:
    //                                                 product.costPrice != null
    //                                                     ? UtilBrasilFields.obterReal(
    //                                                   product.costPrice! / 100,
    //                                                 )
    //                                                     : '',
    //                                                 txt1: 'Preço custo',
    //                                                 txt2: 'Ex: R\$ 5,00',
    //                                                 keyboardType: TextInputType.number,
    //                                                 inputFormatters: [RealInputFormatter()],
    //                                                 onChanged: (value) {
    //                                                   final money =
    //                                                   UtilBrasilFields.converterMoedaParaDouble(
    //                                                     value ?? '',
    //                                                   );
    //
    //                                                   controller.onChanged(
    //                                                     product.copyWith(
    //                                                       basePrice: (money * 100).floor(),
    //                                                     ),
    //                                                   );
    //                                                 },
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //                                         const SizedBox(height: 20),
    //
    //                                         Column(
    //                                           crossAxisAlignment: CrossAxisAlignment.start,
    //                                           children: [
    //                                             Padding(
    //                                               padding: const EdgeInsets.only(left: 10),
    //                                               child: Row(
    //                                                 children: [
    //                                                   Switch(
    //                                                     value: light0,
    //                                                     onChanged: (bool value) {
    //                                                       setState(() {
    //                                                         light0 = value;
    //                                                       });
    //                                                     },
    //                                                   ),
    //                                                   const SizedBox(width: 5),
    //                                                   Text(
    //                                                     'Controlar estoque',
    //                                                     style: TextStyle(
    //                                                       color: notifire.textcolore,
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                             ),
    //
    //                                             // Mostra os dois TextFormField se o switch estiver ativo
    //                                             if (light0) ...[
    //                                               const SizedBox(height: 10),
    //                                               txtfilled(
    //                                                 txt1: 'Estoque atual',
    //                                                 txt2: '0',
    //                                                 initialValue:
    //                                                 product.stockQuantity.toString(),
    //
    //                                                 keyboardType: TextInputType.number,
    //                                                 onChanged: (ean) {
    //                                                   controller.onChanged(
    //                                                     product.copyWith(
    //                                                       stockQuantity: int.tryParse(ean),
    //                                                     ),
    //                                                   );
    //                                                 },
    //                                               ),
    //                                               const SizedBox(height: 10),
    //                                               txtfilled(
    //                                                 initialValue: product.minStock.toString(),
    //
    //                                                 txt1: 'Estoque mínimo',
    //                                                 txt2: 'Digite o mínimo',
    //                                                 keyboardType: TextInputType.number,
    //                                                 onChanged: (ean) {
    //                                                   controller.onChanged(
    //                                                     product.copyWith(
    //                                                       minStock: int.tryParse(ean),
    //                                                     ),
    //                                                   );
    //                                                 },
    //                                               ),
    //                                             ],
    //                                           ],
    //                                         ),
    //                                         const SizedBox(height: 20),
    //                                         Padding(
    //                                           padding: const EdgeInsets.only(
    //                                             left: 10,
    //                                             right: 10,
    //                                           ),
    //                                           child: Column(
    //                                             crossAxisAlignment: CrossAxisAlignment.start,
    //                                             children: [
    //                                               Text(
    //                                                 "Unidade medida",
    //                                                 style: TextStyle(
    //                                                   color: notifire.textcolore,
    //                                                 ),
    //                                               ),
    //                                               const SizedBox(height: 10),
    //                                               Container(
    //                                                 height: 53,
    //                                                 decoration: BoxDecoration(
    //                                                   border: Border.all(
    //                                                     color: Colors.grey.withOpacity(0.4),
    //                                                   ),
    //                                                   borderRadius: const BorderRadius.all(
    //                                                     Radius.circular(10),
    //                                                   ),
    //                                                 ),
    //                                                 child: DropdownButtonFormField<String>(
    //
    //                                                   dropdownColor:
    //                                                   notifire.containcolore1,
    //                                                   value: selectedUnitOption,
    //                                                   padding: const EdgeInsets.only(
    //                                                     left: 10,
    //                                                   ),
    //                                                   items:
    //                                                   unitOptions.map((
    //                                                       Map<String, String> option,
    //                                                       ) {
    //                                                     return DropdownMenuItem<String>(
    //                                                       value: option['value'],
    //
    //                                                       // Sigla para salvar no banco
    //                                                       child: Text(
    //                                                         option['label']!,
    //                                                         // Nome visível
    //                                                         style: TextStyle(
    //                                                           color:
    //                                                           notifire.textcolore,
    //                                                         ),
    //                                                       ),
    //                                                     );
    //                                                   }).toList(),
    //                                                   onChanged: (String? newValue) {
    //                                                     controller.onChanged(
    //                                                       product.copyWith(
    //                                                         unit: newValue,
    //                                                       ),
    //                                                     );
    //                                                   },
    //                                                   decoration: InputDecoration(
    //                                                     hintText: 'Selecione',
    //                                                     hintStyle: TextStyle(
    //                                                       color: notifire.textcolore,
    //                                                     ),
    //                                                     border: InputBorder.none,
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                         ),
    //
    //
    //
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           Expanded(
    //                             flex: 1,
    //                             child: Column(
    //                               mainAxisAlignment: MainAxisAlignment.end,
    //                               crossAxisAlignment: CrossAxisAlignment.end,
    //                               children: [
    //                                 Padding(
    //                                   padding: const EdgeInsets.only(
    //                                     top: 20,
    //                                     right: 10,
    //                                     left: 10,
    //                                   ),
    //                                   child: Container(
    //                                     // height: Get.height,
    //                                     // width: 400,
    //                                     decoration: BoxDecoration(
    //                                       color: Theme.of(context).cardColor,
    //                                       borderRadius: BorderRadius.circular(
    //                                         10,
    //                                       ),
    //                                     ),
    //                                     child: Padding(
    //                                       padding: const EdgeInsets.all(20),
    //                                       child: Column(
    //                                         children: [secoundecontain()],
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 Padding(
    //                                   padding: const EdgeInsets.only(
    //                                     top: 20,
    //                                     right: 10,
    //                                     left: 10,
    //                                   ),
    //                                   child: Container(
    //                                     // height: Get.height,
    //                                     // width: 400,
    //                                     decoration: BoxDecoration(
    //                                       color: Theme.of(context).cardColor,
    //                                       borderRadius: BorderRadius.circular(
    //                                         10,
    //                                       ),
    //                                     ),
    //                                     child: Padding(
    //                                       padding: const EdgeInsets.all(20),
    //                                       child: Column(
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.start,
    //                                         mainAxisAlignment:
    //                                             MainAxisAlignment.start,
    //                                         children: [
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Text(
    //                                               'Settings',
    //                                               style: TextStyle(
    //                                                 color: notifire.textcolore,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           const SizedBox(height: 15),
    //                                           lastcontain(),
    //                                           const SizedBox(height: 15),
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Column(
    //                                               crossAxisAlignment:
    //                                                   CrossAxisAlignment.start,
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.start,
    //                                               children: [
    //                                                 Text(
    //                                                   'Discussion',
    //                                                   style: TextStyle(
    //                                                     color:
    //                                                         notifire.textcolore,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                           const SizedBox(height: 10),
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Row(
    //                                               children: [
    //                                                 Switch(
    //                                                   value: light0,
    //                                                   onChanged: (bool value) {
    //                                                     setState(() {
    //                                                       light0 = value;
    //                                                     });
    //                                                   },
    //                                                 ),
    //                                                 const SizedBox(width: 5),
    //                                                 Text(
    //                                                   'Allow comments',
    //                                                   style: TextStyle(
    //                                                     color:
    //                                                         notifire.textcolore,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                           const SizedBox(height: 10),
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Row(
    //                                               children: [
    //                                                 Switch(
    //                                                   value: light1,
    //                                                   onChanged: (bool value) {
    //                                                     setState(() {
    //                                                       light1 = value;
    //                                                     });
    //                                                   },
    //                                                 ),
    //                                                 const SizedBox(width: 5),
    //                                                 Flexible(
    //                                                   child: Text(
    //                                                     'Allow Piggybacks & tracebacks',
    //                                                     style: TextStyle(
    //                                                       color:
    //                                                           notifire
    //                                                               .textcolore,
    //                                                     ),
    //                                                     overflow:
    //                                                         TextOverflow
    //                                                             .ellipsis,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                           const SizedBox(height: 15),
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Column(
    //                                               crossAxisAlignment:
    //                                                   CrossAxisAlignment.start,
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.start,
    //                                               children: [
    //                                                 Text(
    //                                                   'Mobile App',
    //                                                   style: TextStyle(
    //                                                     color:
    //                                                         notifire.textcolore,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                           const SizedBox(height: 10),
    //                                           Padding(
    //                                             padding: const EdgeInsets.only(
    //                                               left: 10,
    //                                             ),
    //                                             child: Row(
    //                                               children: [
    //                                                 Switch(
    //                                                   value: light2,
    //                                                   onChanged: (bool value) {
    //                                                     setState(() {
    //                                                       light2 = value;
    //                                                     });
    //                                                   },
    //                                                 ),
    //                                                 const SizedBox(width: 5),
    //                                                 Text(
    //                                                   'Show mobile app',
    //                                                   style: TextStyle(
    //                                                     color:
    //                                                         notifire.textcolore,
    //                                                   ),
    //                                                 ),
    //                                               ],
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 const SizedBox(height: 10),
    //                                 Row(
    //                                   mainAxisAlignment: MainAxisAlignment.end,
    //                                   crossAxisAlignment:
    //                                       CrossAxisAlignment.end,
    //                                   children: [
    //                                     const SizedBox(width: 5),
    //                                     Padding(
    //                                       padding: const EdgeInsets.only(
    //                                         right: 10,
    //                                       ),
    //                                       child: ElevatedButton(
    //                                         onPressed: () {},
    //                                         style: const ButtonStyle(
    //                                           backgroundColor:
    //                                               MaterialStatePropertyAll(
    //                                                 Color(0xff6c757d),
    //                                               ),
    //                                         ),
    //                                         child: const Text(
    //                                           'Discard',
    //                                           style: TextStyle(
    //                                             color: Colors.white,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     const SizedBox(width: 5),
    //                                     Padding(
    //                                       padding: const EdgeInsets.only(
    //                                         right: 10,
    //                                       ),
    //                                       child: ElevatedButton(
    //                                         onPressed: () {},
    //                                         style: const ButtonStyle(
    //                                           backgroundColor:
    //                                               MaterialStatePropertyAll(
    //                                                 Color(0xff5151f9),
    //                                               ),
    //                                         ),
    //                                         child: const Text(
    //                                           'Save changed',
    //                                           style: TextStyle(
    //                                             color: Colors.white,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 10),
    //                   const SizedBox(height: 20),
    //                 ],
    //               ),
    //             );
    //           },
    //         );
    //       },
    //     );
    //   },
    // );


//   Widget txtfilled({
//     required String txt1,
//     String? txt2,
//     IconData? sufixIcon,
//     String? initialValue,
//     String? Function(String?)? validator,
//     void Function(String)? onChanged,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(txt1, style: TextStyle(color: notifire.textcolore)),
//           const SizedBox(height: 5),
//           SizedBox(
//             height: 40,
//             child: TextFormField(
//               initialValue: initialValue,
//               onChanged: onChanged,
//               validator: validator,
//               keyboardType: keyboardType,
//               inputFormatters: inputFormatters,
//               style: TextStyle(color: notifire.textcolore),
//               decoration: InputDecoration(
//                 hintText: txt2,
//                 hintStyle: TextStyle(color: notifire.textcolore),
//                 suffixIcon: sufixIcon != null
//                     ? Icon(sufixIcon, color: notifire.textcolore)
//                     : null,
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: const BorderSide(color: Colors.blue),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String? selectedOption;
//   String? selectedUnitOption;
//   List<String> dropdownOptions = ["INDIA", "UK", "USA", 'AUSTRALIA'];
//
//   List<Map<String, String>> unitOptions = [
//     {'label': 'Unidade', 'value': 'UN'},
//     {'label': 'Caixa', 'value': 'CX'},
//     {'label': 'Peça', 'value': 'PC'},
//     {'label': 'Litro', 'value': 'LT'},
//     {'label': 'Mililitro', 'value': 'ML'},
//     {'label': 'Quilograma', 'value': 'KG'},
//     {'label': 'Grama', 'value': 'G'},
//     {'label': 'Miligrama', 'value': 'MG'},
//     {'label': 'Metro', 'value': 'M'},
//     {'label': 'Centímetro', 'value': 'CM'},
//     {'label': 'Milímetro', 'value': 'MM'},
//     {'label': 'Pacote', 'value': 'PCT'},
//     {'label': 'Dúzia', 'value': 'DZ'},
//     {'label': 'Saco', 'value': 'SC'},
//     {'label': 'Rolo', 'value': 'RL'},
//     {'label': 'Fardo', 'value': 'FD'},
//     {'label': 'Ampola', 'value': 'AM'},
//     {'label': 'Frasco', 'value': 'FR'},
//     {'label': 'Tubo', 'value': 'TB'},
//     {'label': 'Placa', 'value': 'PL'},
//     {'label': 'Bandeja', 'value': 'BD'},
//     {'label': 'Jarra', 'value': 'JR'},
//     {'label': 'Galão', 'value': 'GL'},
//   ];
//
//   File? _pickedImage;
//   Uint8List webImage = Uint8List(8);
//
//   Widget secoundecontain() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Text('Media', style: TextStyle(color: notifire.textcolore)),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.withOpacity(0.4)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             children: [
//               const Row(children: []),
//               const SizedBox(height: 20),
//               InkWell(
//                 onTap: () {
//                   // selectFile();
//                   //  _pickImage();
//                 },
//                 child: Container(
//                   height: 100,
//                   width: 100,
//                   decoration: BoxDecoration(
//                     color: const Color(0xffe9ecef),
//                     borderRadius: BorderRadius.circular(10),
//                     image: const DecorationImage(
//                       image: AssetImage('assets/images/image-upload (1).png'),
//                     ),
//                   ),
//                   // child: image == null ? const SizedBox() : Image.file(File(image!.path),width: 120,height: 120),
//                   child:
//                       _pickedImage == null
//                           ? Image(
//                             image: AssetImage(
//                               'assets/images/image-upload (1).png',
//                             ),
//                           )
//                           : Image.memory(webImage, fit: BoxFit.fill),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Column(
//                 children: [
//                   Text(
//                     'Drag & Drop',
//                     style: TextStyle(color: notifire.textcolore),
//                   ),
//                   const SizedBox(height: 5),
//                   Text('OR', style: TextStyle(color: notifire.textcolore)),
//                   const SizedBox(height: 5),
//                   const Text(
//                     'Browse Photo',
//                     style: TextStyle(color: Color(0xff5151f9)),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     'Supports: *.png,*jpg and *.jpeg',
//                     style: TextStyle(color: notifire.textcolore, fontSize: 15),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget areyacontain() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Container(
//         height: 150,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.withOpacity(0.4)),
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//         ),
//         child: TextField(
//           style: TextStyle(color: notifire.textcolore),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.only(left: 10),
//             focusColor: Colors.red,
//             hintText: 'Text area',
//             hintStyle: TextStyle(color: notifire.textcolore),
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget unitDropButton() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Unidade medida", style: TextStyle(color: notifire.textcolore)),
//           const SizedBox(height: 10),
//           Container(
//             height: 40,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.withOpacity(0.4)),
//               borderRadius: const BorderRadius.all(Radius.circular(6)),
//             ),
//             child: DropdownButtonFormField<String>(
//               dropdowncolor: Theme.of(context).cardColor,
//               value: selectedUnitOption,
//               padding: const EdgeInsets.only(left: 10),
//               items:
//                   unitOptions.map((Map<String, String> option) {
//                     return DropdownMenuItem<String>(
//                       value: option['value'], // Sigla para salvar no banco
//                       child: Text(
//                         option['label']!, // Nome visível
//                         style: TextStyle(color: notifire.textcolore),
//                       ),
//                     );
//                   }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedUnitOption =
//                       newValue; // Corrigido o erro de sintaxe
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Selecione',
//                 hintStyle: TextStyle(color: notifire.textcolore),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget dropdownbuton2() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Status", style: TextStyle(color: notifire.textcolore)),
//           const SizedBox(height: 10),
//           Container(
//             height: 53,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.withOpacity(0.4)),
//               borderRadius: const BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: DropdownButtonFormField<String>(
//                 dropdowncolor: Theme.of(context).cardColor,
//                 value: selectedOption,
//                 padding: const EdgeInsets.only(left: 10),
//                 items:
//                     dropdownOptions.map((String option) {
//                       return DropdownMenuItem<String>(
//                         value: option,
//                         child: Text(
//                           option,
//                           style: TextStyle(color: notifire.textcolore),
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedOption = newValue;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Select Status',
//                   hintStyle: TextStyle(color: notifire.textcolore),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget dropdownbuton3() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10, right: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Market Template", style: TextStyle(color: notifire.textcolore)),
//           const SizedBox(height: 10),
//           Container(
//             height: 53,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.withOpacity(0.4)),
//               borderRadius: const BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: DropdownButtonFormField<String>(
//                 dropdowncolor: Theme.of(context).cardColor,
//                 value: selectedOption,
//                 padding: const EdgeInsets.only(left: 10),
//                 items:
//                     dropdownOptions.map((String option) {
//                       return DropdownMenuItem<String>(
//                         value: option,
//                         child: Text(
//                           option,
//                           style: TextStyle(color: notifire.textcolore),
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedOption = newValue;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Select Template',
//                   hintStyle: TextStyle(color: notifire.textcolore),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Widget lastcontain() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         dropdownbuton2(),
//         const SizedBox(height: 20),
//         dropdownbuton3(),
//       ],
//     );
//   }
// }
//
// class SubCategoryItem implements SelectableItem {
//   final String value;
//
//   SubCategoryItem(this.value);
//
//   @override
//   String get title => value;
// }

