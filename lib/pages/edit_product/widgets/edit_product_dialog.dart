// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:brasil_fields/brasil_fields.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';





import '../../../UI TEMP/controller/invoicecreatcontroller.dart';

import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../models/category.dart';

import '../../../repositories/category_repository.dart';
import '../../../repositories/product_repository.dart';

import '../../../services/dialog_service.dart';
import '../../../widgets/app_image_form_field.dart';
import '../../../widgets/app_page_header.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../widgets/app_selection_form_field.dart';
import '../../../widgets/app_table.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/base_dialog.dart';
import '../../../widgets/drawercode.dart';

class EditProductDialog extends StatefulWidget {
  const EditProductDialog({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved, this.category,
  });

  final int storeId;
  final Category? category;
  final int? id;
  final void Function(Product)? onSaved;

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  InvoiceCreatController invoiceCreatController = Get.put(
    InvoiceCreatController(),
  );


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ProductRepository repository = getIt();

  late final AppEditController<void, Product> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getProduct(widget.storeId, id),
    save: (product) => repository.saveProduct(widget.storeId, product),
    empty: () => Product(category: widget.category),
  );

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

              child: BaseDialog(
                content:
                  SizedBox(
                  width:
                  MediaQuery.of(context).size.width < 600
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.45,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: BasePage(

                  mobileBuilder: (BuildContext context) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          children: [secoundecontain(product)],
                                        ),
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
                                          Flexible(
                                            child: AppSelectionFormField<Category>(
                                              title: 'Categoria',
                                              initialValue: widget.id != null ?
                                              product.category : widget.category,
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
                                          ),

                                        ],
                                      ),

                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Em destaque',
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
                                                .featured,

                                            onChanged: (
                                                bool value,
                                                ) {
                                              controller.onChanged(
                                                product.copyWith(
                                                  featured:
                                                  value,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),


                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [


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


                                //   Row(children: [Expanded(child: apk())]),
                              ],
                            ),
                          ),

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

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(

                                    tilePadding: EdgeInsets.zero, // remove espaçamento
                                    childrenPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Opções Avançadas',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 78, // altura suficiente para comportar o Switch + TextField
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 18.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          'Promoção?',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Switch(
                                                          value: product.activatePromotion,
                                                          onChanged: (bool value) {
                                                            controller.onChanged(
                                                              product.copyWith(activatePromotion: value),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                Expanded(
                                                  flex: 2,
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    transitionBuilder: (child, animation) =>
                                                        FadeTransition(opacity: animation, child: child),
                                                    child: product.activatePromotion
                                                        ? AppTextField(
                                                      key: const ValueKey('costPriceField'),
                                                      initialValue: product.promotionPrice != null
                                                          ? UtilBrasilFields.obterReal(product.promotionPrice! / 100)
                                                          : '',
                                                      title: 'Preço promoconal',
                                                      hint: 'Ex: R\$ 10,00',
                                                      formatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                        CentavosInputFormatter(moeda: true),
                                                      ],
                                                      onChanged: (value) {
                                                        final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                                                        controller.onChanged(product.copyWith(promotionPrice: (money * 100).floor()));
                                                      },
                                                    )
                                                        : const SizedBox.shrink(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),



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

                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Produto disponível no cardápio ?',
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
                                          // Coloque aqui os seus widgets personalizados
                                        ],
                                      ),

                                    ],
                                  ),
                                ),





                                //   Row(children: [Expanded(child: apk())]),
                              ],
                            ),
                          ),



                        ],
                      ),
                    );
                  },
                  desktopBuilder: (BuildContext context) {
                    return DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.black,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: 'INFORMAÇÕES'),
                              Tab(text: 'COMPLEMENTOS'),
                              Tab(text: 'Imagens'),
                            ],
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Aba 1 - Geral
                                SingleChildScrollView(

                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ESQUERDA: imagem ou outro conteúdo visual
                                          Container(
                                            width: 200,
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              children: [
                                                // Aqui você pode colocar a imagem do produto ou outro conteúdo

                                            secoundecontain(product)

                                              ],
                                            ),
                                          ),

                                          // DIREITA: campos do formulário
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    AppTextField(
                                                      initialValue: product.name,
                                                      title: 'Nome',
                                                      hint: 'Ex: Guaraná',
                                                      validator: (title) {
                                                        if (title == null || title.isEmpty) {
                                                          return 'Campo obrigatório';
                                                        } else if (title.length < 3) {
                                                          return 'Título muito curto';
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (name) {
                                                        controller.onChanged(product.copyWith(name: name));
                                                      },
                                                    ),
                                                    const SizedBox(height: 20),


                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child:

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


                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),


                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: AppTextField(
                                                            initialValue: product.basePrice != null
                                                                ? UtilBrasilFields.obterReal(product.basePrice! / 100)
                                                                : '',
                                                            title: 'Preço',
                                                            hint: 'Ex: R\$ 5,00',
                                                            formatters: [
                                                              FilteringTextInputFormatter.digitsOnly,
                                                              CentavosInputFormatter(moeda: true),
                                                            ],
                                                            onChanged: (value) {
                                                              final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                                                              controller.onChanged(product.copyWith(basePrice: (money * 100).floor()));
                                                            },
                                                            validator: (value) {
                                                              if (value == null || value.length < 7) {
                                                                return 'Campo obrigatório';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20),
                                                        Flexible(
                                                          child: AppTextField(
                                                            initialValue: product.costPrice != null
                                                                ? UtilBrasilFields.obterReal(product.costPrice! / 100)
                                                                : '',
                                                            title: 'Custo do produto',
                                                            hint: 'Ex: R\$ 1,00',
                                                            formatters: [
                                                              FilteringTextInputFormatter.digitsOnly,
                                                              CentavosInputFormatter(moeda: true),
                                                            ],
                                                            onChanged: (value) {
                                                              final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                                                              controller.onChanged(product.copyWith(costPrice: (money * 100).floor()));
                                                            },
                                                          ),
                                                        ),


                                                      ],
                                                    ),





                                                    const SizedBox(height: 20),
                                                    AppTextField(
                                                      initialValue: product.description,
                                                      title: 'Descrição',
                                                      hint: 'Descreva seu produto',
                                                      validator: (desc) {
                                                        if (desc == null || desc.isEmpty) {
                                                          return 'Campo obrigatório';
                                                        } else if (desc.length < 10) {
                                                          return 'Descrição muito curta';
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (desc) {
                                                        controller.onChanged(product.copyWith(description: desc));
                                                      },
                                                    ),


                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            'Em destaque',
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
                                                              .featured,

                                                          onChanged: (
                                                              bool value,
                                                              ) {
                                                            controller.onChanged(
                                                              product.copyWith(
                                                                featured:
                                                                value,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
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




                                                    // OPÇÃOES AVANÇADAS





                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),


                                        ],
                                      ),


                                      Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(

                                          tilePadding: EdgeInsets.zero, // remove espaçamento
                                          childrenPadding: EdgeInsets.zero,
                                          title: const Text(
                                            'Opções Avançadas',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 72, // altura suficiente para comportar o Switch + TextField
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              const Text(
                                                                'Ativar promoção?',
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Switch(
                                                                value: product.activatePromotion,
                                                                onChanged: (bool value) {
                                                                  controller.onChanged(
                                                                    product.copyWith(activatePromotion: value),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        const SizedBox(width: 16),

                                                        Expanded(
                                                          flex: 2,
                                                          child: AnimatedSwitcher(
                                                            duration: const Duration(milliseconds: 300),
                                                            transitionBuilder: (child, animation) =>
                                                                FadeTransition(opacity: animation, child: child),
                                                            child: product.activatePromotion
                                                                ? AppTextField(
                                                              key: const ValueKey('costPriceField'),
                                                              initialValue: product.promotionPrice != null
                                                                  ? UtilBrasilFields.obterReal(product.promotionPrice! / 100)
                                                                  : '',
                                                              title: '',
                                                              hint: 'Ex: R\$ 10,00',
                                                              formatters: [
                                                                FilteringTextInputFormatter.digitsOnly,
                                                                CentavosInputFormatter(moeda: true),
                                                              ],
                                                              onChanged: (value) {
                                                                final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                                                                controller.onChanged(product.copyWith(promotionPrice: (money * 100).floor()));
                                                              },
                                                            )
                                                                : const SizedBox.shrink(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),



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

                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          'Produto disponível no cardápio ?',
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
                                                  // Coloque aqui os seus widgets personalizados
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Aba 2 - Estoque
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: const [
                                      Text('Conteúdo da aba Estoque'),
                                    ],
                                  ),
                                ),
                                // Aba 3 - Imagens
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: const [
                                      Text('Conteúdo da aba Imagens'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );















                  },
                ),
              ),
            ),
                title: '',
                onSave: () async{
                  if (formKey.currentState!.validate()) {
                    final result = await controller.saveData();

                     if (result.isRight && context.mounted) {
                      widget.onSaved?.call(result.right);
                      context.pop(); // fecha o dialog
                    }


                  }
                },
                saveText: 'Salvar',
              ),
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
