// import 'package:brasil_fields/brasil_fields.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:totem_pro_admin/constdata/typography.dart';
// import 'package:totem_pro_admin/core/app_edit_controller.dart';
// import 'package:totem_pro_admin/core/di.dart';
// import 'package:totem_pro_admin/core/extensions.dart';
// import 'package:totem_pro_admin/models/category.dart';
// import 'package:totem_pro_admin/models/product.dart';
// import 'package:totem_pro_admin/models/supplier.dart';
// import 'package:totem_pro_admin/pages/base/BasePage.dart';
// import 'package:totem_pro_admin/pages/edit_product/widgets/product_variant_list_item.dart';
// import 'package:totem_pro_admin/repositories/category_repository.dart';
// import 'package:totem_pro_admin/repositories/product_repository.dart';
// import 'package:totem_pro_admin/repositories/supplier_repository.dart';
// import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
// import 'package:totem_pro_admin/widgets/app_page_header.dart';
// import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
// import 'package:totem_pro_admin/widgets/app_primary_button.dart';
// import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
// import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';
// import 'package:totem_pro_admin/widgets/app_table.dart';
// import 'package:totem_pro_admin/widgets/app_text_field.dart';
// import 'package:totem_pro_admin/widgets/appbarcustom.dart';
//
// import '../../widgets/app_switch.dart';
//
// class EditProductPage extends StatefulWidget {
//   const EditProductPage({super.key, required this.storeId, this.id});
//
//   final int storeId;
//   final int? id;
//
//   @override
//   State<EditProductPage> createState() => _EditProductPageState();
// }
//
// class _EditProductPageState extends State<EditProductPage> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   final ProductRepository repository = getIt();
//
//   late final AppEditController<Product> controller = AppEditController(
//     id: widget.id,
//     fetch: (id) => repository.getProduct(widget.storeId, id),
//     save: (product) => repository.saveProduct(widget.storeId, product),
//     empty: () => Product(),
//   );
//
//   Future<void> save() async {
//     final result = await controller.saveData();
//     if (result.isRight && widget.id == null &&mounted) {
//       context.replace('/stores/${widget.storeId}/products/${result.right.id}');
//     }
//   }
//
//   bool showUnpublished = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (_, __) {
//         return AppPageStatusBuilder<Product>(
//           status: controller.status,
//           successBuilder: (product) {
//             return BasePage(
//               mobileBuilder: (BuildContext context) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Material(
//                           color: Colors.white,
//                           child: Padding(
//                             padding: const EdgeInsets.all(24),
//                             child: Form(
//                               key: formKey,
//                               autovalidateMode:
//                               AutovalidateMode.onUserInteraction,
//                               child: Wrap(
//                                 spacing: 24,
//                                 runSpacing: 24,
//                                 children: [
//                                   SizedBox(
//                                     width: 200,
//                                     child: AppImageFormField(
//                                       initialValue: product.image,
//                                       title: 'Imagem',
//                                       aspectRatio: 1,
//                                       validator: (image) {
//                                         if (image == null) {
//                                           return 'Selecione uma imagem';
//                                         }
//                                         return null;
//                                       },
//                                       onChanged: (image) {
//                                         controller.onChanged(
//                                           product.copyWith(image: image),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 200,
//                                     child: AppTextField(
//                                       initialValue: product.name,
//                                       title: 'Título do produto',
//                                       hint: 'Ex: Guaraná',
//                                       validator: (title) {
//                                         if (title == null || title.isEmpty) {
//                                           return 'Campo obrigatório';
//                                         } else if (title.length < 3) {
//                                           return 'Título muito curto';
//                                         }
//                                         return null;
//                                       },
//                                       onChanged: (name) {
//                                         controller.onChanged(
//                                           product.copyWith(name: name),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 400,
//                                     child: AppTextField(
//                                       initialValue: product.description,
//                                       title: 'Descrição do produto',
//                                       hint: 'Ex: Muito saboroso',
//                                       validator: (title) {
//                                         if (title == null || title.isEmpty) {
//                                           return 'Campo obrigatório';
//                                         } else if (title.length < 10) {
//                                           return 'Descrição muito curta';
//                                         }
//                                         return null;
//                                       },
//                                       onChanged: (desc) {
//                                         controller.onChanged(
//                                           product.copyWith(description: desc),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 200,
//                                     child: AppTextField(
//                                       initialValue:
//                                       product.basePrice != null
//                                           ? UtilBrasilFields.obterReal(
//                                         product.basePrice! / 100,
//                                       )
//                                           : '',
//                                       title: 'Preço base',
//                                       hint: 'Ex: R\$ 5,00',
//                                       formatters: [
//                                         FilteringTextInputFormatter.digitsOnly,
//                                         CentavosInputFormatter(moeda: true),
//                                       ],
//                                       onChanged: (value) {
//                                         final money =
//                                         UtilBrasilFields.converterMoedaParaDouble(
//                                           value ?? '',
//                                         );
//
//                                         controller.onChanged(
//                                           product.copyWith(
//                                             basePrice: (money * 100).floor(),
//                                           ),
//                                         );
//                                       },
//                                       validator: (value) {
//                                         if (value == null || value.length < 7) {
//                                           return 'Campo obrigatório';
//                                         }
//
//                                         return null;
//                                       },
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 200,
//                                     child: AppSelectionFormField<Supplier>(
//                                       title: 'Fornecedor',
//                                       initialValue: product.supplier,
//                                       // Pode ser null, o que está correto
//                                       fetch:
//                                           () => getIt<SupplierRepository>()
//                                           .getSuppliers(widget.storeId),
//                                       validator: (supplier) {
//                                         return null; // Se fornecedor for válido ou opcional, não há erro
//                                       },
//                                       onChanged: (supplier) {
//                                         // Atualize o produto com o fornecedor selecionado (ou nulo)
//                                         controller.onChanged(
//                                           product.copyWith(
//                                             supplier:
//                                             supplier, // Pode ser nulo, o que é aceitável
//                                           ),
//                                         );
//                                       },
//                                       columns: [
//                                         AppTableColumnString(
//                                           title: 'Nome',
//                                           dataSelector: (c) => c.name,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   SizedBox(
//                                     width: 200,
//                                     child: AppSelectionFormField<Category>(
//                                       title: 'Categoria',
//                                       initialValue: product.category,
//                                       fetch:
//                                           () => getIt<CategoryRepository>()
//                                           .getCategories(widget.storeId),
//                                       validator: (category) {
//                                         if (category == null) {
//                                           return 'Campo obrigatório';
//                                         }
//                                         return null;
//                                       },
//                                       onChanged:
//                                           (category) => controller.onChanged(
//                                         product.copyWith(
//                                           category: () => category,
//                                         ),
//                                       ),
//                                       columns: [
//                                         AppTableColumnString(
//                                           title: 'Nome',
//                                           dataSelector: (c) => c.name,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (widget.id != null) ...[
//                                     Padding(
//                                       padding: const EdgeInsets.all(24),
//                                       child: Row(
//                                         children: [
//                                           const Expanded(
//                                             child: Text(
//                                               'Variantes',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                           const Text(
//                                             'Exibir\ndespublicados',
//                                             textAlign: TextAlign.end,
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 8),
//                                           AppSwitch(
//                                             value: showUnpublished,
//                                             onChanged: (v) {
//                                               setState(() {
//                                                 showUnpublished = v;
//                                               });
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Align(
//                                       alignment: Alignment.topLeft,
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(left: 24),
//                                         child: Material(
//                                           color: Colors.white,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(24),
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 for (final v in product.variants!.where(
//                                                         (v) => showUnpublished || v.available))
//                                                   ProductVariantListItem(
//                                                     storeId: widget.storeId,
//                                                     productId: product.id!,
//                                                     variant: v,
//                                                     showUnpublished: showUnpublished,
//                                                   ),
//                                                 AppPrimaryButton(
//                                                   label: 'Adicionar variante',
//                                                   onPressed: () => context.go(
//                                                       '/stores/${widget.storeId}/products/${product.id}/variants/new'),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   ],
//
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//
//               desktopBuilder: (BuildContext context) {
//                 return AnimatedBuilder(
//                   animation: controller,
//                   builder: (_, __) {
//                     return AppPageStatusBuilder<Product>(
//                       status: controller.status,
//                       successBuilder: (product) {
//                         return Scaffold(
//                           body: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                   ),
//                                   child: Material(
//                                     color: Colors.white,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(24),
//                                       child: Form(
//                                         key: formKey,
//                                         autovalidateMode:
//                                         AutovalidateMode.onUserInteraction,
//                                         child: Wrap(
//                                           spacing: 24,
//                                           runSpacing: 24,
//                                           children: [
//                                             SizedBox(
//                                               width: 200,
//                                               child: AppImageFormField(
//                                                 initialValue: product.image,
//                                                 title: 'Imagem',
//                                                 aspectRatio: 1,
//                                                 validator: (image) {
//                                                   if (image == null) {
//                                                     return 'Selecione uma imagem';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 onChanged: (image) {
//                                                   controller.onChanged(
//                                                     product.copyWith(
//                                                       image: image,
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 200,
//                                               child: AppTextField(
//                                                 initialValue: product.name,
//                                                 title: 'Título do produto',
//                                                 hint: 'Ex: Guaraná',
//                                                 validator: (title) {
//                                                   if (title == null ||
//                                                       title.isEmpty) {
//                                                     return 'Campo obrigatório';
//                                                   } else if (title.length < 3) {
//                                                     return 'Título muito curto';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 onChanged: (name) {
//                                                   controller.onChanged(
//                                                     product.copyWith(
//                                                       name: name,
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 400,
//                                               child: AppTextField(
//                                                 initialValue:
//                                                 product.description,
//                                                 title: 'Descrição do produto',
//                                                 hint: 'Ex: Muito saboroso',
//                                                 validator: (title) {
//                                                   if (title == null ||
//                                                       title.isEmpty) {
//                                                     return 'Campo obrigatório';
//                                                   } else if (title.length <
//                                                       10) {
//                                                     return 'Descrição muito curta';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 onChanged: (desc) {
//                                                   controller.onChanged(
//                                                     product.copyWith(
//                                                       description: desc,
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 200,
//                                               child: AppTextField(
//                                                 initialValue:
//                                                 product.basePrice != null
//                                                     ? UtilBrasilFields.obterReal(
//                                                   product.basePrice! /
//                                                       100,
//                                                 )
//                                                     : '',
//                                                 title: 'Preço base',
//                                                 hint: 'Ex: R\$ 5,00',
//                                                 formatters: [
//                                                   FilteringTextInputFormatter
//                                                       .digitsOnly,
//                                                   CentavosInputFormatter(
//                                                     moeda: true,
//                                                   ),
//                                                 ],
//                                                 onChanged: (value) {
//                                                   final money =
//                                                   UtilBrasilFields.converterMoedaParaDouble(
//                                                     value ?? '',
//                                                   );
//
//                                                   controller.onChanged(
//                                                     product.copyWith(
//                                                       basePrice:
//                                                       (money * 100).floor(),
//                                                     ),
//                                                   );
//                                                 },
//                                                 validator: (value) {
//                                                   if (value == null ||
//                                                       value.length < 7) {
//                                                     return 'Campo obrigatório';
//                                                   }
//
//                                                   return null;
//                                                 },
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 200,
//                                               child: AppSelectionFormField<
//                                                   Supplier
//                                               >(
//                                                 title: 'Fornecedor',
//                                                 initialValue: product.supplier,
//                                                 // Pode ser null, o que está correto
//                                                 fetch:
//                                                     () => getIt<
//                                                     SupplierRepository
//                                                 >()
//                                                     .getSuppliers(
//                                                   widget.storeId,
//                                                 ),
//                                                 validator: (supplier) {
//                                                   return null; // Se fornecedor for válido ou opcional, não há erro
//                                                 },
//                                                 onChanged: (supplier) {
//                                                   // Atualize o produto com o fornecedor selecionado (ou nulo)
//                                                   controller.onChanged(
//                                                     product.copyWith(
//                                                       supplier:
//                                                       supplier, // Pode ser nulo, o que é aceitável
//                                                     ),
//                                                   );
//                                                 },
//                                                 columns: [
//                                                   AppTableColumnString(
//                                                     title: 'Nome',
//                                                     dataSelector: (c) => c.name,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//
//                                             SizedBox(
//                                               width: 200,
//                                               child: AppSelectionFormField<
//                                                   Category
//                                               >(
//                                                 title: 'Categoria',
//                                                 initialValue: product.category,
//                                                 fetch:
//                                                     () => getIt<
//                                                     CategoryRepository
//                                                 >()
//                                                     .getCategories(
//                                                   widget.storeId,
//                                                 ),
//                                                 validator: (category) {
//                                                   if (category == null) {
//                                                     return 'Campo obrigatório';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 onChanged:
//                                                     (category) =>
//                                                     controller.onChanged(
//                                                       product.copyWith(
//                                                         category:
//                                                             () => category,
//                                                       ),
//                                                     ),
//                                                 columns: [
//                                                   AppTableColumnString(
//                                                     title: 'Nome',
//                                                     dataSelector: (c) => c.name,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//
//
//                                             if (widget.id != null) ...[
//                                               Padding(
//                                                 padding: const EdgeInsets.all(24),
//                                                 child: Row(
//                                                   children: [
//                                                     const Expanded(
//                                                       child: Text(
//                                                         'Variantes',
//                                                         style: TextStyle(
//                                                           fontSize: 16,
//                                                           fontWeight: FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     const Text(
//                                                       'Exibir\ndespublicados',
//                                                       textAlign: TextAlign.end,
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         fontWeight: FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 8),
//                                                     AppSwitch(
//                                                       value: showUnpublished,
//                                                       onChanged: (v) {
//                                                         setState(() {
//                                                           showUnpublished = v;
//                                                         });
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Align(
//                                                 alignment: Alignment.topLeft,
//                                                 child: Padding(
//                                                   padding: const EdgeInsets.only(left: 24),
//                                                   child: Material(
//                                                     color: Colors.white,
//                                                     child: Padding(
//                                                       padding: const EdgeInsets.all(24),
//                                                       child: Column(
//                                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                                         children: [
//                                                           for (final v in product.variants!.where(
//                                                                   (v) => showUnpublished || v.available))
//                                                             ProductVariantListItem(
//                                                               storeId: widget.storeId,
//                                                               productId: product.id!,
//                                                               variant: v,
//                                                               showUnpublished: showUnpublished,
//                                                             ),
//                                                           AppPrimaryButton(
//                                                             label: 'Adicionar variante',
//                                                             onPressed: () => context.go(
//                                                                 '/stores/${widget.storeId}/products/${product.id}/variants/new'),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               )
//                                             ],
//
//
//
//
//
//
//
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           bottomSheet: Container(
//                             padding:
//                             context.isSmallScreen
//                                 ? EdgeInsets.all(0)
//                                 : EdgeInsets.all(24),
//                             color: notifire.getBgColor,
//                             width: double.infinity,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: AppPrimaryButton(
//                                     label: 'Salvar',
//                                     onPressed: () async {
//                                       if (formKey.currentState!.validate()) {
//                                         controller.onChanged(
//                                           product.copyWith(
//                                             available: !product.available,
//                                           ),
//                                         );
//                                         save();
//                                       }
//                                     },
//                                   ),
//                                 ),
//
//                                 context.isSmallScreen
//                                     ? SizedBox.shrink()
//                                     : SizedBox(width: 16),
//                                 context.isSmallScreen
//                                     ? SizedBox.shrink()
//                                     : Expanded(
//                                   child: AppSecondaryButton(
//                                     label: 'Descartar',
//                                     onPressed: () async {
//                                       context.pop();
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//
//               mobileAppBar: AppBarCustom(title: 'Produtos'),
//
//               bottomSheet: Container(
//                 padding:
//                 context.isSmallScreen
//                     ? EdgeInsets.all(0)
//                     : EdgeInsets.all(24),
//                 color: notifire.getBgColor,
//                 width: double.infinity,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: AppPrimaryButton(
//                         label: 'Salvar',
//                         onPressed: () async {
//                           if (formKey.currentState!.validate()) {
//                             controller.onChanged(
//                               product.copyWith(available: !product.available),
//                             );
//                             save();
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
