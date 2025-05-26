import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../ConstData/typography.dart';
import '../../core/app_edit_controller.dart';
import '../../core/di.dart';
import '../../core/helpers/mask.dart';
import '../../models/store.dart';
import '../../repositories/store_repository.dart';
import '../../widgets/app_image_form_field.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../base/BasePage.dart';
import '../create_store/controllers/create_store_controllers.dart';

class EditSettingsPage extends StatefulWidget {
  final int storeId;

  const EditSettingsPage({super.key, required this.storeId});

  @override
  State<EditSettingsPage> createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  final StoreRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();


  late final AppEditController<void, Store> controller =
      AppEditController<void, Store>(
        id: widget.storeId,
        fetch: (id) => storeRepository.getStore(id),
        save: (store) => storeRepository.updateStore(widget.storeId, store),
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

              return  BasePage(
                mobileBuilder: (BuildContext context) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 28,
                        top: 10,
                        right: 28,
                        bottom: 30,
                      ),
                      child: Column(
                        children: [
                          secoundecontain(store),





                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: Card(

                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Geral',
                                                style: TextStyle(
                                                //  color:
                                                 // notifire.textcolore,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // titulo
                                        AppTextField(
                                          initialValue: store.name,
                                          title: 'Nome do estabelecimento',
                                          hint: 'Minha loja',
                                          validator: (title) {
                                            if (title == null ||
                                                title.isEmpty) {
                                              return 'Campo obrigatório';
                                            } else if (title.length <
                                                3) {
                                              return 'Nome muito curto';
                                            }
                                            return null;
                                          },
                                          onChanged: (name) {
                                            controller.onChanged(
                                              store.copyWith(
                                                name: name,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        AppTextField(
                                          initialValue:
                                          store.description,
                                          title: 'Descrição',
                                          hint: 'Descreva sua loja',

                                          onChanged: (desc) {
                                            controller.onChanged(
                                              store.copyWith(
                                                description: desc,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),

                                        //categoria



                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Endereço',
                                        style: TextStyle(
                                         // color: notifire.textcolore,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  AppTextField(
                                    initialValue: store.zip_code,
                                    onChanged: (v) {
                                      controller.onChanged(store.copyWith(zip_code: v));
                                    },

                                    title: 'Cep',
                                    hint: '11999-222',
                                    formatters: [cepMask],
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.street,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(street: v));
                                          },


                                          title: 'Rua ou Avenida*',
                                          hint: 'Rua, avenidas, estrada',
                                        ),
                                      ),


                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [



                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.number,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(number: v));
                                          },

                                          title: 'Número*',
                                          hint: '123',
                                        ),
                                      ),
                                      SizedBox(width: 25,),

                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.neighborhood,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(neighborhood: v));
                                          },

                                          title: 'Bairro*',
                                          hint: 'Centro',
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),


                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.complement,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(complement: v));
                                          },

                                          title: 'Complemento',
                                          hint: 'Apartamento, bloco, etc.',
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.reference,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(reference: v));
                                          },

                                          title: 'Referência',
                                          hint: 'Próximo ao mercado',
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.city,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(city: v));
                                          },

                                          title: 'Cidade*',
                                          hint: 'Ex: São Paulo',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          initialValue: store.state,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(state: v));
                                          },

                                          title: 'Estado*',
                                          hint: 'Ex: SP',
                                        ),
                                      ),
                                    ],
                                  ),
                                  //   Row(children: [Expanded(child: apk())]),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          Card(



                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Redes Sociais',
                                        style: TextStyle(
                                        //  color: notifire.textcolore,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),
                                  AppTextField(
                                    initialValue: store.facebook,
                                    onChanged: (v) {
                                      controller.onChanged(store.copyWith(facebook: v));
                                    },


                                    title: 'Facebook',
                                    hint: 'facebook/minhaloja',
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),
                                  AppTextField(
                                    initialValue: store.instagram,
                                    onChanged: (v) {
                                      controller.onChanged(store.copyWith(instagram: v));
                                    },


                                    title: 'Instagram',
                                    hint: '@minhaloja',
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  AppTextField(
                                    initialValue: store.tiktok,
                                    onChanged: (v) {
                                      controller.onChanged(store.copyWith(tiktok: v));
                                    },


                                    title: 'Tiktok',
                                    hint: 'tiktok',
                                  ),

                                  const SizedBox(height: 20),
                                  //   Row(children: [Expanded(child: apk())]),
                                ],
                              ),
                            ),
                          ),









                        ],
                      ),
                    ),
                  );
                },
                desktopBuilder: (BuildContext context) {
                  return Column(
                    children: [
                      FixedHeader(title: 'Configurações',

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
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
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
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        top: 15,
                                                      ),
                                                      child: Card(

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
                                                                store
                                                                    .name,
                                                                title: 'Nome do estabelecimento',
                                                                hint:
                                                                'Minha loja',
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
                                                                    return 'Nome muito curto';
                                                                  }
                                                                  return null;
                                                                },
                                                                onChanged: (
                                                                    name,
                                                                    ) {
                                                                  controller.onChanged(
                                                                    store.copyWith(
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
                                                                store
                                                                    .description,
                                                                title:
                                                                'Descrição',
                                                                hint:
                                                                'Descreva sua loja',

                                                                onChanged: (
                                                                    desc,
                                                                    ) {
                                                                  controller.onChanged(
                                                                    store.copyWith(
                                                                      description:
                                                                      desc,
                                                                    ),
                                                                  );
                                                                },
                                                              ),

                                                              const SizedBox(
                                                                height: 20,
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
                                                child: Card(

                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Column(


                                                      children: [

                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Endereço da loja',
                                                              style: TextStyle(
                                                              //  color:
                                                              //  notifire
                                                                //    .textcolore,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),

                                                        AppTextField(
                                                          initialValue: store.zip_code,
                                                          onChanged: (v) {
                                                            controller.onChanged(store.copyWith(zip_code: v));
                                                          },

                                                          title: 'Cep',
                                                          hint: '11999-222',
                                                          formatters: [cepMask],
                                                        ),

                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [

                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.street,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(street: v));
                                                                },


                                                                title: 'Rua ou Avenida*',
                                                                hint: 'Rua, avenidas, estrada',
                                                              ),
                                                            ),
                                                            SizedBox(width: 20,),

                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.number,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(number: v));
                                                                },

                                                                title: 'Número*',
                                                                hint: '123',
                                                              ),
                                                            ),



                                                          ],
                                                        ),

                                                        SizedBox(height: 20,),

                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.neighborhood,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(neighborhood: v));
                                                                },

                                                                title: 'Bairro*',
                                                                hint: 'Centro',
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(height: 25),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.complement,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(complement: v));
                                                                },

                                                                title: 'Complemento',
                                                                hint: 'Apartamento, bloco, etc.',
                                                              ),
                                                            ),
                                                            const SizedBox(width: 25),
                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.reference,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(reference: v));
                                                                },

                                                                title: 'Referência',
                                                                hint: 'Próximo ao mercado',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 25),

                                                        Row(
                                                          children: [

                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.city,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(city: v));
                                                                },

                                                                title: 'Cidade*',
                                                                hint: 'Ex: São Paulo',
                                                              ),
                                                            ),
                                                            const SizedBox(width: 25),
                                                            Expanded(
                                                              child: AppTextField(
                                                                initialValue: store.state,
                                                                onChanged: (v) {
                                                                  controller.onChanged(store.copyWith(state: v));
                                                                },

                                                                title: 'Estado*',
                                                                hint: 'Ex: SP',
                                                              ),
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
                                                  top: 10,
                                                  right: 10,
                                                  left: 10,
                                                  bottom: 20

                                                ),
                                                child: Card(

                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 10, right: 10,),
                                                    child: Column(
                                                      children: [
                                                        secoundecontain(
                                                          store,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),


                                              Padding(
                                                padding:
                                                const EdgeInsets.only(





                                                  right: 10,
                                                  left: 10,
                                                ),
                                                child: Card(

                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      children: [


                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Redes Sociais',
                                                              style: TextStyle(
                                                           //     color:
                                                             //   notifire
                                                              //      .textcolore,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        AppTextField(
                                                          initialValue: store.facebook,
                                                          onChanged: (v) {
                                                            controller.onChanged(store.copyWith(facebook: v));
                                                          },


                                                          title: 'Facebook',
                                                          hint: 'facebook/minhaloja',
                                                        ),

                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        AppTextField(
                                                          initialValue: store.instagram,
                                                          onChanged: (v) {
                                                            controller.onChanged(store.copyWith(instagram: v));
                                                          },


                                                          title: 'Instagram',
                                                          hint: '@minhaloja',
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        AppTextField(
                                                          initialValue: store.tiktok,
                                                          onChanged: (v) {
                                                            controller.onChanged(store.copyWith(tiktok: v));
                                                          },


                                                          title: 'Tiktok',
                                                          hint: 'tiktok',
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
                                  ),
                                ),
                                const SizedBox(height: 10),



                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },

                  mobileBottomNavigationBar:      AppPrimaryButton(label: 'Salvar',

                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await controller.saveData();
                      }
                    },

                  ),

                mobileAppBar: AppBarCustom(title: 'Configurações gerais'),

              );























            },
          );
        },
      ),
    );
  }

  Widget secoundecontain(Store store) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AppImageFormField(
        initialValue: store.image,
        title: 'Imagem',
        aspectRatio: 1,
        validator: (image) {
          if (image == null) {
            return 'Selecione uma imagem';
          }
          return null;
        },
        onChanged: (image) {
          controller.onChanged(store.copyWith(image: image));
        },
      ),
    );
  }
}
