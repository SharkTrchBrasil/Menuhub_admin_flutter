// import 'package:brasil_fields/brasil_fields.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:totem_pro_admin/core/app_edit_controller.dart';
// import 'package:totem_pro_admin/core/di.dart';
// import 'package:totem_pro_admin/core/extensions/extensions.dart';
// import 'package:totem_pro_admin/models/coupon.dart';
// import 'package:totem_pro_admin/models/product.dart';
// import 'package:totem_pro_admin/pages/base/BasePage.dart';
// import 'package:totem_pro_admin/repositories/coupons_repository.dart';
// import 'package:totem_pro_admin/repositories/product_repository.dart';
//
// import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
//
// import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';
// import 'package:totem_pro_admin/widgets/app_table.dart';
// import 'package:totem_pro_admin/widgets/app_text_field.dart';
// import 'package:totem_pro_admin/widgets/base_dialog.dart';
//
// import '../../../ConstData/typography.dart';
// import '../../../widgets/app_date_time_form_field.dart';
// import '../../../widgets/app_text_field_2.dart';
//
// class EditCouponPageDialog extends StatefulWidget {
//   const EditCouponPageDialog({super.key, required this.storeId, this.id, this.onSaved});
//
//   final int storeId;
//   final int? id;
//   final void Function(Coupon)? onSaved;
//
//   @override
//   State<EditCouponPageDialog> createState() => _EditCouponPageDialogState();
// }
//
// class _EditCouponPageDialogState extends State<EditCouponPageDialog> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   final CouponRepository repository = getIt();
//
//   late final AppEditController<void, Coupon> controller = AppEditController(
//     id: widget.id,
//     fetch: (id) => repository.getCoupon(widget.storeId, id),
//     save: (coupon) => repository.saveCoupon(widget.storeId, coupon),
//     empty: () => Coupon(),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (_, __) {
//         return AppPageStatusBuilder<Coupon>(
//           status: controller.status,
//           successBuilder: (coupon) {
//             return Form(
//               key: formKey,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               child:
//               BaseDialog(
//
//
//               title:  widget.id == null ? 'Criar cupom' : 'Editar cupom',
//
//
//                 onSave: () async {
//                   if (formKey.currentState!.validate()) {
//                     final result = await controller.saveData();
//                     if (result.isRight && context.mounted) {
//                       widget.onSaved?.call(result.right);
//                       context.pop(); // fecha o dialog
//                     }
//                   }
//                 } ,
//                 saveText: 'Salvar',
//
//
//
//
//
//                 content:
//
//                 SizedBox(
//                   width:
//                       MediaQuery.of(context).size.width < 600
//                           ? MediaQuery.of(context).size.width
//                           : 500,
//
//                   child: BasePage(
//                     mobileBuilder: (BuildContext context) {
//                       return LayoutBuilder(
//                         builder: (
//                           BuildContext context,
//                           BoxConstraints constraints,
//                         ) {
//                           return SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 AppTextField(
//                                   initialValue: coupon.code,
//                                   title: 'Código do cupom',
//                                   hint: 'Ex: PROMO10OFF',
//                                   validator: (title) {
//                                     if (title == null || title.isEmpty) {
//                                       return 'Campo obrigatório';
//                                     } else if (title.length < 3) {
//                                       return 'Código muito curto';
//                                     }
//                                     return null;
//                                   },
//                                   onChanged: (name) {
//                                     controller.onChanged(
//                                       coupon.copyWith(code: name),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(height: 15),
//
//                                 AppSelectionFormField<Product>(
//                                   title: 'Produto',
//                                   fetch:
//                                       () => getIt<ProductRepository>()
//                                       .getProducts(widget.storeId),
//                                   columns: [
//                                     AppTableColumnString(
//                                       title: 'Nome',
//                                       dataSelector: (p) => p.name,
//                                     ),
//                                   ],
//                                   onChanged: (product) {
//                                     controller.onChanged(
//                                       coupon.copyWith(product: product),
//                                     );
//                                   },
//                                 ),
//
//
//                                 const SizedBox(height: 15),
//
//                                 AppDateTimeFormField(
//                                   initialValue: coupon.startDate,
//                                   title: 'Início da promoção *',
//                                   validator: (value) {
//                                     if (value == null) {
//                                       return 'Campo obrigatório';
//                                     }
//                                     return null;
//                                   },
//                                   onChanged: (v) {
//                                     controller.onChanged(
//                                       coupon.copyWith(startDate: v),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(height: 15),
//
//                                 AppDateTimeFormField(
//                                   initialValue: coupon.endDate,
//                                   title: 'Fim da promoção *',
//                                   validator: (value) {
//                                     if (value == null) {
//                                       return 'Campo obrigatório';
//                                     }
//                                     return null;
//                                   },
//                                   onChanged: (v) {
//                                     controller.onChanged(
//                                       coupon.copyWith(endDate: v),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(height: 15),
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: AppTextField(
//                                         initialValue:
//                                             coupon.maxUses?.toString(),
//                                         title: 'Limite de usos *',
//                                         hint: 'Ex: 100 usos no total',
//                                         validator: (value) {
//                                           if (value == null ||
//                                               value.isEmpty) {
//                                             return 'Campo obrigatório';
//                                           }
//                                           final integer = int.tryParse(
//                                             value,
//                                           );
//                                           if (integer == null) {
//                                             return 'Número inválido';
//                                           } else if (integer < 0 ||
//                                               integer > 1000000) {
//                                             return 'O número deve ser entre 0 e 1000000';
//                                           }
//                                           return null;
//                                         },
//                                         formatters: [
//                                           FilteringTextInputFormatter
//                                               .digitsOnly,
//                                         ],
//                                         onChanged: (v) {
//                                           controller.onChanged(
//                                             coupon.copyWith(
//                                               maxUses: int.tryParse(
//                                                 v ?? '',
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(width: 15),
//                                     Flexible(
//                                       child: AppTextField(
//                                         title: 'Limite por cliente',
//                                         hint: 'Ex: 1 uso por cliente',
//                                         initialValue:
//                                             coupon.maxUsesPerCustomer
//                                                 ?.toString(),
//                                         validator: (value) {
//                                           final integer = int.tryParse(
//                                             value ?? '',
//                                           );
//                                           if (integer != null &&
//                                               (integer < 0 ||
//                                                   integer > 100)) {
//                                             return 'Número inválido';
//                                           }
//                                           return null;
//                                         },
//                                         onChanged: (v) {
//                                           controller.onChanged(
//                                             coupon.copyWith(
//                                               maxUsesPerCustomer:
//                                                   int.tryParse(v ?? ''),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 15),
//
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: AppTextField(
//                                         title: 'Valor mínimo do pedido',
//                                         hint: 'Ex: R\$ 50,00',
//                                         initialValue:
//                                             coupon.minOrderValue?.toPrice(),
//                                         formatters: [
//                                           FilteringTextInputFormatter
//                                               .digitsOnly,
//                                           CentavosInputFormatter(
//                                             moeda: true,
//                                           ),
//                                         ],
//                                         onChanged: (v) {
//                                           final value =
//                                               (UtilBrasilFields.converterMoedaParaDouble(
//                                                         v ?? '',
//                                                       ) *
//                                                       100)
//                                                   .floor();
//                                           controller.onChanged(
//                                             coupon.copyWith(
//                                               minOrderValue: value,
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 15),
//
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: DropdownButtonFormField<String>(
//                                         value: coupon.discountType,
//                                         decoration: InputDecoration(
//                                           labelText: 'Tipo de desconto',
//
//                                         ),
//                                         items: const [
//                                           DropdownMenuItem(value: 'percentage', child: Text('Porcentagem')),
//                                           DropdownMenuItem(value: 'fixed', child: Text('Valor fixo')),
//                                         ],
//                                         onChanged: (value) {
//                                           if (value != null) {
//                                             controller.onChanged(
//                                               coupon.copyWith(discountType: value),
//                                             );
//                                           }
//                                         },
//                                       ),
//                                     ),
//
//                                     SizedBox(width: 15,),
//
//                                     Flexible(
//                                       child: AppTextField(
//                                         title: coupon.discountType == 'percentage' ? 'Valor do desconto (%)' : 'Valor do desconto (R\$)',
//                                         initialValue: coupon.discountValue.toString(),
//                                         hint: coupon.discountType == 'percentage' ? 'Ex: 10' : 'Ex: R\$ 10,00',
//
//                                         formatters: coupon.discountType == 'percentage'
//                                             ? [FilteringTextInputFormatter.digitsOnly]
//                                             : [
//                                           FilteringTextInputFormatter.digitsOnly,
//                                           CentavosInputFormatter(moeda: true),
//                                         ],
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return 'Campo obrigatório';
//                                           }
//
//                                           final parsed = coupon.discountType == 'percentage'
//                                               ? int.tryParse(value)
//                                               : UtilBrasilFields.converterMoedaParaDouble(value);
//
//                                           if (parsed == null || parsed == 0) {
//                                             return 'Valor inválido';
//                                           }
//
//                                           return null;
//                                         },
//                                         onChanged: (v) {
//                                           final parsed = coupon.discountType == 'percentage'
//                                               ? int.tryParse(v ?? '') ?? 0
//                                               : (UtilBrasilFields.converterMoedaParaDouble(v ?? '') * 100).floor();
//
//                                           controller.onChanged(
//                                             coupon.copyWith(discountValue: parsed),
//                                           );
//                                         },
//                                       ),
//                                     ),
//
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 15),
//
//
//
//                                 // Row(
//                                 //   children: [
//                                 //
//                                 //     Expanded(
//                                 //       child:
//                                 //
//                                 //       AppTextField2(
//                                 //         initialValue:
//                                 //             coupon.discountPercent
//                                 //                 ?.toString(),
//                                 //         title: 'Percentual',
//                                 //         hint: 'Ex: 10%',
//                                 //         suffixText: '%',
//                                 //         description:
//                                 //             'Informe somente um tipo de desconto',
//                                 //         validator: (value) {
//                                 //           if (value == null ||
//                                 //               value.isEmpty) {
//                                 //             if (coupon.discountFixed ==
//                                 //                 null) {
//                                 //               return 'Campo obrigatório';
//                                 //             } else {
//                                 //               return null;
//                                 //             }
//                                 //           }
//                                 //           final integer = int.tryParse(
//                                 //             value,
//                                 //           );
//                                 //           if (integer == null) {
//                                 //             return 'Número inválido';
//                                 //           } else if (integer < 0 ||
//                                 //               integer > 1000000) {
//                                 //             return 'O número deve ser entre 1 e 100';
//                                 //           }
//                                 //           return null;
//                                 //         },
//                                 //         formatters: [
//                                 //           FilteringTextInputFormatter
//                                 //               .digitsOnly,
//                                 //         ],
//                                 //         onChanged: (v) {
//                                 //           controller.onChanged(
//                                 //             coupon.copyWith(
//                                 //               discountPercent:
//                                 //                   int.tryParse(v ?? '') ??
//                                 //                   0,
//                                 //             ),
//                                 //           );
//                                 //         },
//                                 //       ),
//                                 //     ),
//                                 //     const SizedBox(width: 15),
//                                 //
//                                 //     Expanded(
//                                 //       child: AppTextField2(
//                                 //         initialValue:
//                                 //             coupon.discountFixed?.toPrice(),
//                                 //         title: 'Desconto fixo',
//                                 //         hint: 'Ex: R\$ 10,00',
//                                 //         description:
//                                 //             'Informe somente um tipo de desconto',
//                                 //         validator: (value) {
//                                 //           if (value == null ||
//                                 //               value.isEmpty) {
//                                 //             if (coupon.discountPercent ==
//                                 //                 null) {
//                                 //               return 'Campo obrigatório';
//                                 //             } else {
//                                 //               return null;
//                                 //             }
//                                 //           } else if (coupon
//                                 //                   .discountPercent !=
//                                 //               null) {
//                                 //             return 'Informe somente um';
//                                 //           }
//                                 //           final money =
//                                 //               UtilBrasilFields.converterMoedaParaDouble(
//                                 //                 value,
//                                 //               );
//                                 //           if (money == 0) {
//                                 //             return 'Desconto inválido';
//                                 //           } else if (money > 1000000) {
//                                 //             return 'Número muito grande';
//                                 //           }
//                                 //           return null;
//                                 //         },
//                                 //         formatters: [
//                                 //           FilteringTextInputFormatter
//                                 //               .digitsOnly,
//                                 //           CentavosInputFormatter(
//                                 //             moeda: true,
//                                 //           ),
//                                 //         ],
//                                 //         onChanged: (v) {
//                                 //           final money =
//                                 //               (UtilBrasilFields.converterMoedaParaDouble(
//                                 //                         v ?? '',
//                                 //                       ) *
//                                 //                       100)
//                                 //                   .floor();
//                                 //
//                                 //           controller.onChanged(
//                                 //             coupon.copyWith(
//                                 //               discountFixed: money,
//                                 //             ),
//                                 //           );
//                                 //         },
//                                 //       ),
//                                 //     ),
//                                 //   ],
//                                 // ),
//
//
//                                 const SizedBox(width: 25),
//
//
//                                 Container(
//                                   // height: Get.height,
//                                   // width: 400,
//                                   decoration: BoxDecoration(
//
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 10,
//                                           top: 8,
//                                         ),
//                                         child: Text(
//                                           'Opções',
//                                           style: TextStyle(
//                                          //   color: notifire.textcolore,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 7),
//
//                                       Padding(
//                                         padding: const EdgeInsets.all(12.0),
//                                         child: Column(
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     'Cupom disponível ?',
//                                                     style: TextStyle(
//                                                      // color:
//                                                        //   notifire
//                                                              // .textcolore,
//                                                     ),
//                                                     overflow:
//                                                         TextOverflow
//                                                             .ellipsis,
//                                                   ),
//                                                 ),
//
//                                                 const SizedBox(width: 5),
//                                                 Switch(
//                                                   value: coupon.isActive,
//
//                                                   onChanged: (bool value) {
//                                                     controller.onChanged(
//                                                       coupon.copyWith(
//                                                         isActive: value,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(width: 15),
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     'Ativar apenas para primeira compra',
//                                                     style: TextStyle(
//                                                      // color:
//                                                          // notifire
//                                                            //   .textcolore,
//                                                     ),
//                                                     overflow:
//                                                         TextOverflow
//                                                             .ellipsis,
//                                                   ),
//                                                 ),
//
//                                                 const SizedBox(width: 5),
//                                                 Switch(
//                                                   value:
//                                                       coupon
//                                                           .onlyFirstPurchase,
//
//                                                   onChanged: (bool value) {
//                                                     controller.onChanged(
//                                                       coupon.copyWith(
//                                                         onlyFirstPurchase:
//                                                             value,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     desktopBuilder: (BuildContext context) {
//                       return LayoutBuilder(
//                         builder: (
//                           BuildContext context,
//                           BoxConstraints constraints,
//                         ) {
//                           return SingleChildScrollView(
//                             child: ConstrainedBox(
//                               constraints: BoxConstraints(
//                                 minHeight: constraints.maxHeight,
//                               ),
//
//                               child: IntrinsicHeight(
//                                 child: Column(
//                                   children: [
//                                     const SizedBox(height: 15),
//
//                                     Container(
//                                       decoration: BoxDecoration(
//
//                                         borderRadius: BorderRadius.circular(
//                                           6,
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(12.0),
//                                         child: Column(
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: AppTextField(
//                                                     initialValue:
//                                                         coupon.code,
//                                                     title:
//                                                         'Código do cupom',
//                                                     hint: 'Ex: PROMO10OFF',
//                                                     validator: (title) {
//                                                       if (title == null ||
//                                                           title.isEmpty) {
//                                                         return 'Campo obrigatório';
//                                                       } else if (title
//                                                               .length <
//                                                           3) {
//                                                         return 'Código muito curto';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     onChanged: (name) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           code: name,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//
//                                                 const SizedBox(width: 20),
//
//                                                 Flexible(
//                                                   child:   AppSelectionFormField<Product>(
//                                                     title: 'Produto',
//                                                     initialValue: coupon.product,
//                                                     fetch:
//                                                         () => getIt<ProductRepository>()
//                                                         .getProducts(widget.storeId),
//                                                     columns: [
//                                                       AppTableColumnString(
//                                                         title: 'Nome',
//                                                         dataSelector: (p) => p.name,
//                                                       ),
//                                                     ],
//                                                     onChanged: (product) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(product: product),
//                                                       );
//                                                     },
//                                                   ),
//                                                 )
//
//
//                                               ],
//                                             ),
//                                             const SizedBox(height: 15),
//
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: AppTextField(
//                                                     initialValue:
//                                                         coupon.maxUses
//                                                             ?.toString(),
//                                                     title:
//                                                         'Limite de usos *',
//                                                     hint:
//                                                         'Ex: 100 usos no total',
//                                                     validator: (value) {
//                                                       if (value == null ||
//                                                           value.isEmpty) {
//                                                         return 'Campo obrigatório';
//                                                       }
//                                                       final integer =
//                                                           int.tryParse(
//                                                             value,
//                                                           );
//                                                       if (integer == null) {
//                                                         return 'Número inválido';
//                                                       } else if (integer <
//                                                               0 ||
//                                                           integer >
//                                                               1000000) {
//                                                         return 'O número deve ser entre 0 e 1000000';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     formatters: [
//                                                       FilteringTextInputFormatter
//                                                           .digitsOnly,
//                                                     ],
//                                                     onChanged: (v) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           maxUses:
//                                                               int.tryParse(
//                                                                 v ?? '',
//                                                               ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 20),
//                                                 Flexible(
//                                                   child: AppTextField(
//                                                     title:
//                                                         'Limite por cliente',
//                                                     hint:
//                                                         'Ex: 1 uso por cliente',
//                                                     initialValue:
//                                                         coupon
//                                                             .maxUsesPerCustomer
//                                                             ?.toString(),
//                                                     validator: (value) {
//                                                       final integer =
//                                                           int.tryParse(
//                                                             value ?? '',
//                                                           );
//                                                       if (integer != null &&
//                                                           (integer < 0 ||
//                                                               integer >
//                                                                   100)) {
//                                                         return 'Número inválido';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     onChanged: (v) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           maxUsesPerCustomer:
//                                                               int.tryParse(
//                                                                 v ?? '',
//                                                               ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 15),
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   flex: 1,
//
//                                                   child: AppTextField(
//                                                     title:
//                                                         'Valor mínimo do pedido',
//                                                     hint: 'Ex: R\$ 50,00',
//                                                     initialValue:
//                                                         coupon.minOrderValue
//                                                             ?.toPrice(),
//                                                     formatters: [
//                                                       FilteringTextInputFormatter
//                                                           .digitsOnly,
//                                                       CentavosInputFormatter(
//                                                         moeda: true,
//                                                       ),
//                                                     ],
//                                                     onChanged: (v) {
//                                                       final value =
//                                                           (UtilBrasilFields.converterMoedaParaDouble(
//                                                                     v ?? '',
//                                                                   ) *
//                                                                   100)
//                                                               .floor();
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           minOrderValue:
//                                                               value,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                                 Flexible(
//                                                   child: SizedBox.shrink(),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//
//                                     const SizedBox(height: 15),
//
//                                     Container(
//                                       decoration: BoxDecoration(
//
//                                         borderRadius: BorderRadius.circular(
//                                           6,
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(12.0),
//                                         child: Column(
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: AppDateTimeFormField(
//                                                     initialValue:
//                                                         coupon.startDate,
//                                                     title:
//                                                         'Início da promoção *',
//                                                     validator: (value) {
//                                                       if (value == null) {
//                                                         return 'Campo obrigatório';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     onChanged: (v) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           startDate: v,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 20),
//                                                 Flexible(
//                                                   child: AppDateTimeFormField(
//                                                     initialValue:
//                                                         coupon.endDate,
//                                                     title:
//                                                         'Fim da promoção *',
//                                                     validator: (value) {
//                                                       if (value == null) {
//                                                         return 'Campo obrigatório';
//                                                       }
//                                                       return null;
//                                                     },
//                                                     onChanged: (v) {
//                                                       controller.onChanged(
//                                                         coupon.copyWith(
//                                                           endDate: v,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 15),
//
//
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: DropdownButtonFormField<String>(
//
//                                                     value: coupon.discountType,
//                                                     decoration: InputDecoration(
//                                                       labelText: 'Tipo de desconto',
//
//                                                     ),
//                                                     items: const [
//                                                       DropdownMenuItem(value: 'percentage', child: Text('Porcentagem')),
//                                                       DropdownMenuItem(value: 'fixed', child: Text('Valor fixo')),
//                                                     ],
//                                                     onChanged: (value) {
//                                                       if (value != null) {
//                                                         controller.onChanged(
//                                                           coupon.copyWith(discountType: value),
//                                                         );
//                                                       }
//                                                     },
//                                                   ),
//                                                 ),
//
//                                                 SizedBox(width: 15,),
//                                                 Flexible(
//                                                   child: AppTextField(
//                                                     title: coupon.discountType == 'percentage' ? 'Valor do desconto (%)' : 'Valor do desconto (R\$)',
//                                                     initialValue: coupon.discountValue.toString(),
//                                                     hint: coupon.discountType == 'percentage' ? 'Ex: 10' : 'Ex: R\$ 10,00',
//
//                                                     formatters: coupon.discountType == 'percentage'
//                                                         ? [FilteringTextInputFormatter.digitsOnly]
//                                                         : [
//                                                       FilteringTextInputFormatter.digitsOnly,
//                                                       CentavosInputFormatter(moeda: true),
//                                                     ],
//                                                     validator: (value) {
//                                                       if (value == null || value.isEmpty) {
//                                                         return 'Campo obrigatório';
//                                                       }
//
//                                                       final parsed = coupon.discountType == 'percentage'
//                                                           ? int.tryParse(value)
//                                                           : UtilBrasilFields.converterMoedaParaDouble(value);
//
//                                                       if (parsed == null || parsed == 0) {
//                                                         return 'Valor inválido';
//                                                       }
//
//                                                       return null;
//                                                     },
//                                                     onChanged: (v) {
//                                                       final parsed = coupon.discountType == 'percentage'
//                                                           ? int.tryParse(v ?? '') ?? 0
//                                                           : (UtilBrasilFields.converterMoedaParaDouble(v ?? '') * 100).floor();
//
//                                                       controller.onChanged(
//                                                         coupon.copyWith(discountValue: parsed),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//
//
//
//
//
//                                               ],
//                                             ),
//
//
//                                             const SizedBox(height: 15),
//
//
//
//
//
//                                             // Row(
//                                             //   children: [
//                                             //     Flexible(
//                                             //       child: AppTextField2(
//                                             //         initialValue:
//                                             //             coupon
//                                             //                 .discountPercent
//                                             //                 ?.toString(),
//                                             //         title: 'Percentual',
//                                             //         hint: 'Ex: 10%',
//                                             //         suffixText: '%',
//                                             //         description:
//                                             //             'Informe somente um tipo de desconto',
//                                             //         validator: (value) {
//                                             //           if (value == null ||
//                                             //               value.isEmpty) {
//                                             //             if (coupon
//                                             //                     .discountFixed ==
//                                             //                 null) {
//                                             //               return 'Campo obrigatório';
//                                             //             } else {
//                                             //               return null;
//                                             //             }
//                                             //           }
//                                             //           final integer =
//                                             //               int.tryParse(
//                                             //                 value,
//                                             //               );
//                                             //           if (integer == null) {
//                                             //             return 'Número inválido';
//                                             //           } else if (integer <
//                                             //                   0 ||
//                                             //               integer >
//                                             //                   1000000) {
//                                             //             return 'O número deve ser entre 1 e 100';
//                                             //           }
//                                             //           return null;
//                                             //         },
//                                             //         formatters: [
//                                             //           FilteringTextInputFormatter
//                                             //               .digitsOnly,
//                                             //         ],
//                                             //         onChanged: (v) {
//                                             //           controller.onChanged(
//                                             //             coupon.copyWith(
//                                             //               discountPercent:
//                                             //                   int.tryParse(
//                                             //                     v ?? '',
//                                             //                   ) ??
//                                             //                   0,
//                                             //             ),
//                                             //           );
//                                             //         },
//                                             //       ),
//                                             //     ),
//                                             //     const SizedBox(width: 20),
//                                             //     Flexible(
//                                             //       child: AppTextField2(
//                                             //         initialValue:
//                                             //             coupon.discountFixed
//                                             //                 ?.toPrice(),
//                                             //         title: 'Desconto fixo',
//                                             //         hint: 'Ex: R\$ 10,00',
//                                             //         description:
//                                             //             'Informe somente um tipo de desconto',
//                                             //         validator: (value) {
//                                             //           if (value == null ||
//                                             //               value.isEmpty) {
//                                             //             if (coupon
//                                             //                     .discountPercent ==
//                                             //                 null) {
//                                             //               return 'Campo obrigatório';
//                                             //             } else {
//                                             //               return null;
//                                             //             }
//                                             //           } else if (coupon
//                                             //                   .discountPercent !=
//                                             //               null) {
//                                             //             return 'Informe somente um';
//                                             //           }
//                                             //           final money =
//                                             //               UtilBrasilFields.converterMoedaParaDouble(
//                                             //                 value,
//                                             //               );
//                                             //           if (money == 0) {
//                                             //             return 'Desconto inválido';
//                                             //           } else if (money >
//                                             //               1000000) {
//                                             //             return 'Número muito grande';
//                                             //           }
//                                             //           return null;
//                                             //         },
//                                             //         formatters: [
//                                             //           FilteringTextInputFormatter
//                                             //               .digitsOnly,
//                                             //           CentavosInputFormatter(
//                                             //             moeda: true,
//                                             //           ),
//                                             //         ],
//                                             //         onChanged: (v) {
//                                             //           final money =
//                                             //               (UtilBrasilFields.converterMoedaParaDouble(
//                                             //                         v ?? '',
//                                             //                       ) *
//                                             //                       100)
//                                             //                   .floor();
//                                             //
//                                             //           controller.onChanged(
//                                             //             coupon.copyWith(
//                                             //               discountFixed:
//                                             //                   money,
//                                             //             ),
//                                             //           );
//                                             //         },
//                                             //       ),
//                                             //     ),
//                                             //   ],
//                                             // ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 25),
//                                     Container(
//                                       // height: Get.height,
//                                       // width: 400,
//                                       decoration: BoxDecoration(
//
//                                         borderRadius: BorderRadius.circular(
//                                           6,
//                                         ),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                               left: 10,
//                                               top: 8,
//                                             ),
//                                             child: Text(
//                                               'Opções',
//                                               style: TextStyle(
//                                            //     color: notifire.textcolore,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 7),
//
//                                           Padding(
//                                             padding: const EdgeInsets.all(
//                                               12.0,
//                                             ),
//                                             child: Column(
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Flexible(
//                                                       child: Text(
//                                                         'Cupom disponível ?',
//                                                         style: TextStyle(
//                                                         //  color:
//                                                           //    notifire
//                                                              //     .textcolore,
//                                                         ),
//                                                         overflow:
//                                                             TextOverflow
//                                                                 .ellipsis,
//                                                       ),
//                                                     ),
//
//                                                     const SizedBox(
//                                                       width: 5,
//                                                     ),
//                                                     Switch(
//                                                       value:
//                                                           coupon.isActive,
//
//                                                       onChanged: (
//                                                         bool value,
//                                                       ) {
//                                                         controller.onChanged(
//                                                           coupon.copyWith(
//                                                             isActive:
//                                                                 value,
//                                                           ),
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(width: 15),
//                                                 Row(
//                                                   children: [
//                                                     Flexible(
//                                                       child: Text(
//                                                         'Ativar apenas para primeira compra',
//                                                         style: TextStyle(
//                                                          // color:
//                                                            //   notifire
//                                                                //   .textcolore,
//                                                         ),
//                                                         overflow:
//                                                             TextOverflow
//                                                                 .ellipsis,
//                                                       ),
//                                                     ),
//
//                                                     const SizedBox(
//                                                       width: 5,
//                                                     ),
//                                                     Switch(
//                                                       value:
//                                                           coupon
//                                                               .onlyFirstPurchase,
//
//                                                       onChanged: (
//                                                         bool value,
//                                                       ) {
//                                                         controller.onChanged(
//                                                           coupon.copyWith(
//                                                             onlyFirstPurchase:
//                                                                 value,
//                                                           ),
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//
//
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//
//
// }
