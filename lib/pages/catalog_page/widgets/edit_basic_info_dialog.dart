// import 'package:either_dart/either.dart';
// import 'package:flutter/material.dart';
//
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// import 'package:totem_pro_admin/core/app_edit_controller.dart';
// import 'package:totem_pro_admin/pages/base/BasePage.dart';
//
//
//
//
// import '../../../core/di.dart';
// import '../../../models/store.dart';
// import '../../../repositories/store_repository.dart';
// import '../../../widgets/app_image_form_field.dart';
// import '../../../widgets/app_page_status_builder.dart';
//
// import '../../../widgets/app_text_field.dart';
// import '../../../widgets/base_dialog.dart';
// import '../../create_store/controllers/create_store_controllers.dart';
//
// class EditBasicInfoDialog extends StatefulWidget {
//   const EditBasicInfoDialog({super.key, required this.store});
//
//   final Store store;
//
//   @override
//   State<EditBasicInfoDialog> createState() => _EditBasicInfoDialogState();
// }
//
// class _EditBasicInfoDialogState extends State<EditBasicInfoDialog> {
//   final StoreRepository storeRepository = getIt();
//   final StoreController storeController = StoreController();
//   final formKey = GlobalKey<FormState>();
//
//   late final AppEditController<void, Store> controller =
//   AppEditController<void, Store>(
//     id: widget.store.id,
//     initialData: widget.store,
//     save: (store) => storeRepository.updateStore(widget.store.id!, store),
//   );
//
//   final cepMask = MaskTextInputFormatter(
//     mask: '##.###-###',
//     filter: {"#": RegExp(r'[0-9]')},
//     type: MaskAutoCompletionType.lazy,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (_, __) {
//           return AppPageStatusBuilder<Store>(
//             status: controller.status,
//             successBuilder: (store) {
//               if (!storeController.isInitialized) {
//                 storeController.initControllers(store);
//                 storeController.isInitialized = true;
//               }
//
//               return BaseDialog(
//                 title: 'Dados da loja',
//                 saveText: 'Salvar',
//                 onSave: () async {
//                   if (formKey.currentState!.validate()) {
//                     final updated = store.copyWith(
//                       name: storeController.nameController.text,
//                       instagram: storeController.instagramController.text,
//                       facebook: storeController.facebookController.text,
//                       image: storeController.image,
//                       zip_code: storeController.zipCodeController.text,
//                       street: storeController.streetController.text,
//                       number: storeController.numberController.text,
//                       neighborhood: storeController.neighborhoodController.text,
//                       complement: storeController.complementController.text,
//                       reference: storeController.referenceController.text,
//                       city: storeController.cityController.text,
//                       state: storeController.stateController.text,
//                     );
//                     final result = await controller.saveData(updated);
//
//                     // Fecha o diálogo se a atualização for bem-sucedida
//                     if (result is Right) {
//                       if (context.mounted) Navigator.of(context).pop();
//                     }
//                   }
//
//
//                 },
//                 content: SizedBox(
//                   width: MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.width: 600,
//                   child:
//
//                   BasePage(
//
//                     mobileBuilder: (BuildContext context) {
//                       return   SingleChildScrollView(
//                         scrollDirection: Axis.vertical,
//
//
//
//                         child: Column(
//
//                           children: [
//
//
//                             Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 8.0),
//                                     child: Text(
//                                       'Logo',
//                                       style: TextStyle(
//                                       //  color: notifire.textcolore,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 200,
//                                     width: 180,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.grey.withOpacity(0.4),
//                                       ),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         children: [
//                                           const SizedBox(height: 20),
//                                           AppImageFormField(
//                                             initialValue:
//                                             storeController.image,
//                                             title: 'Imagem',
//                                             aspectRatio: 1,
//                                             validator: (image) {
//                                               if (image == null) {
//                                                 return 'Selecione uma imagem';
//                                               }
//                                               return null;
//                                             },
//                                             onChanged: (image) {
//                                               controller.onChanged(store
//                                                   .copyWith(image: image));
//                                             },
//                                           ),
//
//
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             const SizedBox(height: 40),
//
//                             AppTextField(
//                               controller: storeController.nameController,
//                               title: 'Nome do estabelecimento',
//                               hint: 'Minha loja',
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Campo obrigatório';
//                                 } else if (value.length < 3) {
//                                   return 'Nome muito curto';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 25),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.instagramController,
//                                     title: 'Perfil do Instagram',
//                                     hint: '@sualoja',
//                                   ),
//                                 ),
//
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//
//                             Row(
//                               children: [
//
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.facebookController,
//                                     title: 'Facebook',
//                                     hint: 'facebook/sualoja',
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//
//
//
//                             const SizedBox(height: 40),
//                             Row(
//                               children: [
//                                 Text(
//                                   'Endereço',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 const Expanded(
//                                   child: Divider(
//                                     thickness: 1,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//                             AppTextField(
//                               controller: storeController.zipCodeController,
//                               title: 'Cep*',
//                               hint: '11999-222',
//                               formatters: [cepMask],
//                             ),
//                             const SizedBox(height: 30),
//                             AppTextField(
//                               controller: storeController.streetController,
//                               title: 'Rua ou Avenida*',
//                               hint: 'Rua, avenidas, estrada',
//                             ),
//                             const SizedBox(height: 25),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.numberController,
//                                     title: 'Número*',
//                                     hint: '123',
//                                   ),
//                                 ),
//
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//
//                             Row(
//                               children: [
//
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.neighborhoodController,
//                                     title: 'Bairro*',
//                                     hint: 'Centro',
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//
//                             const SizedBox(height: 25),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.complementController,
//                                     title: 'Complemento',
//                                     hint: 'Apartamento, bloco, etc.',
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller:
//                                     storeController.referenceController,
//                                     title: 'Referência',
//                                     hint: 'Próximo ao mercado',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 30),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller: storeController.cityController,
//                                     title: 'Cidade*',
//                                     hint: 'Ex: São Paulo',
//                                   ),
//                                 ),
//
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Row(
//                               children: [
//
//                                 Expanded(
//                                   child: AppTextField(
//                                     controller: storeController.stateController,
//                                     title: 'Estado*',
//                                     hint: 'Ex: SP',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//
//
//                     desktopBuilder: (BuildContext context) {
//                       return   Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 600,
//                             padding: const EdgeInsets.all(24),
//
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//
//                                   Center(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 8.0),
//                                           child: Text(
//                                             'Logo',
//                                             style: TextStyle(
//                                             //  color: notifire.textcolore,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 150,
//                                           width: 120,
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                               color: Colors.grey.withOpacity(0.4),
//                                             ),
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               children: [
//                                                 const SizedBox(height: 20),
//                                                 AppImageFormField(
//                                                   initialValue:
//                                                   storeController.image,
//                                                   title: 'Imagem',
//                                                   aspectRatio: 1,
//                                                   validator: (image) {
//                                                     if (image == null) {
//                                                       return 'Selecione uma imagem';
//                                                     }
//                                                     return null;
//                                                   },
//                                                   onChanged: (image) {
//                                                     controller.onChanged(store
//                                                         .copyWith(image: image));
//                                                   },
//                                                 ),
//
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 45),
//
//                                   AppTextField(
//                                     controller: storeController.nameController,
//                                     title: 'Nome do estabelecimento',
//                                     hint: 'Minha loja',
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Campo obrigatório';
//                                       } else if (value.length < 3) {
//                                         return 'Nome muito curto';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   const SizedBox(height: 45),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.instagramController,
//                                           title: 'Perfil do Instagram',
//                                           hint: '@sualoja',
//                                         ),
//                                       ),
//                                       const SizedBox(width: 25),
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.facebookController,
//                                           title: 'Facebook',
//                                           hint: 'facebook/sualoja',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 40),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         'Endereço',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       const Expanded(
//                                         child: Divider(
//                                           thickness: 1,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 25),
//                                   AppTextField(
//                                     controller: storeController.zipCodeController,
//                                     title: 'Cep*',
//                                     hint: '11999-222',
//                                     formatters: [cepMask],
//                                   ),
//                                   const SizedBox(height: 30),
//                                   AppTextField(
//                                     controller: storeController.streetController,
//                                     title: 'Rua ou Avenida*',
//                                     hint: 'Rua, avenidas, estrada',
//                                   ),
//                                   const SizedBox(height: 25),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.numberController,
//                                           title: 'Número*',
//                                           hint: '123',
//                                         ),
//                                       ),
//                                       const SizedBox(width: 20),
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.neighborhoodController,
//                                           title: 'Bairro*',
//                                           hint: 'Centro',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 30),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.complementController,
//                                           title: 'Complemento',
//                                           hint: 'Apartamento, bloco, etc.',
//                                         ),
//                                       ),
//                                       const SizedBox(width: 20),
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller:
//                                           storeController.referenceController,
//                                           title: 'Referência',
//                                           hint: 'Próximo ao mercado',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 30),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller: storeController.cityController,
//                                           title: 'Cidade*',
//                                           hint: 'Ex: São Paulo',
//                                         ),
//                                       ),
//                                       const SizedBox(width: 20),
//                                       Expanded(
//                                         child: AppTextField(
//                                           controller: storeController.stateController,
//                                           title: 'Estado*',
//                                           hint: 'Ex: SP',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 20),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//
//                     },
//
//
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
