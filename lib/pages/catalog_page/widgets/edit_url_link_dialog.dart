

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';


import '../../../ConstData/typography.dart';
import '../../../widgets/base_dialog.dart';
import '../../create_store/controllers/create_store_controllers.dart';



class EditUrlLinkDialog extends StatefulWidget {
  const EditUrlLinkDialog({super.key, required this.store});

  final Store store;

  @override
  State<EditUrlLinkDialog> createState() => _EditUrlLinkDialogState();
}

class _EditUrlLinkDialogState extends State<EditUrlLinkDialog> {
  final StoreRepository storeRepository = getIt();

  final StoreController storeController = StoreController();

  final formKey = GlobalKey<FormState>();

  late final AppEditController<void, Store> controller = AppEditController<void, Store>(
    id: widget.store.id,
    fetch: (id) async => Right(widget.store), // Retorna Future<Either<void, Store?>> com Right
    save: (store) => storeRepository.updateStore(widget.store.id!,store),
    empty: () => Store(),
  );


  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return AppPageStatusBuilder<Store>(
            status: controller.status,
            successBuilder: (store) {
              if (!storeController.isInitialized) {
                storeController.initControllers(store);

                storeController.isInitialized = true; // controle simples
              }



              return BaseDialog(

                content:

                Container(
                  // height: 200,
                  width: MediaQuery.of(context).size.width<600 ? MediaQuery.of(context).size.width : 500,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [


                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Personalize o link exclusivo da sua loja",
                        style: Typographyy.bodySmallMedium.copyWith(
                           // color: notifire.getGry500_600Color,
                            wordSpacing: 1.4,
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 40,
                      ),

                      const SizedBox(
                        height: 24,
                      ),



                    ],
                  ),
                ),







                title: 'Link do catálogo online',

                onSave:  () async {
                if(formKey.currentState!.validate()) {
                  await controller.saveData();
                }
              },


                saveText: 'Salvar',
              );






            },
          );
        },
      ),
    );
  }

}
