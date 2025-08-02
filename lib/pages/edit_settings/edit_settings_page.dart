
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field_banner.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field_logo.dart';


import '../../ConstData/typography.dart';
import '../../constdata/colorfile.dart';
import '../../constdata/colorprovider.dart';
import '../../core/app_edit_controller.dart';
import '../../core/di.dart';
import '../../core/helpers/mask.dart';
import '../../models/store.dart';
import '../../repositories/store_repository.dart';
import '../../widgets/app_image_form_field.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';


class Settings extends StatefulWidget {
  const Settings({super.key, required this.storeId});
  final int storeId;
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final StoreRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();

  late final AppEditController<void, Store> controller =
  AppEditController<void, Store>(
    id: widget.storeId,
    fetch: (id) => storeRepository.getStore(id),
    save: (store) => storeRepository.updateStore(widget.storeId, store),
    empty: () => Store(),
  );

  ColorNotifire notifire = ColorNotifire();
  bool switch1 = false;
  bool switch2 = true;
  bool switch3 = false;
  bool switch4 = true;


  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);


    return Form(
      key: formKey,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return AppPageStatusBuilder<Store>(
            status: controller.status,
            successBuilder: (store) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                     // color: notifire.getBgColor,
                      child: DefaultTabController(
                        length: 5,
                        initialIndex: 0,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return NestedScrollView(
                                headerSliverBuilder: (context, innerBoxIsScrolled) {
                                  return [
                                    const SliverToBoxAdapter(child: SizedBox(height: 25)),
                                    SliverToBoxAdapter(child: _buildTabBar()),
                                    const SliverToBoxAdapter(child: SizedBox(height: 25)),
                                  ];
                                },
                                body: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: TabBarView(
                                    children: [
                                      _buildApi(width: constraints.maxWidth, store: store),
                                      _buildNewpass(store),
                                      _buildUser(width: constraints.maxWidth, store: store),
                                      _build2SF(width: constraints.maxWidth, store: store),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  children: [
                                    _buildTabBar(),
                                    const SizedBox(height: 25),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _buildApi(width: constraints.maxWidth, store: store),
                                          _buildNewpass(store),
                                          _buildUser(width: constraints.maxWidth, store: store),
                                          _build2SF(width: constraints.maxWidth, store: store),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  AppPrimaryButton(label: 'Salvar',

                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await controller.saveData();
                      }
                    },

                  ),

                  SizedBox(height: 40,)



                ],
              );
            },
          );
        },
      ),
    );















  }



  Widget _buildUser({required double width, required Store store}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(

            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              child: Column(

                mainAxisSize: MainAxisSize.min,
                children: [
              
                  width<800? const SizedBox() :
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo da Loja
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Logo da Loja (500x500)',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          AppImageFormFieldLogo(
                            title: 'Logo',
                            initialValue: store.image,
                            validator: (image) {
                              if (image == null) return 'Selecione uma imagem';
                              return null;
                            },
                            onChanged: (image) {
                              controller.onChanged(store.copyWith(image: image));
                            },
                          ),
                        ],
                      ),
              
                      const SizedBox(width: 24),
              
                      // Banner da Loja
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Banner da Loja (1920x375)',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            AppImageFormFieldBanner(
                              title: '',
                              aspectRatio: 1920 / 375,
                              initialValue: store.banner,
                              validator: (image) {
                                if (image == null) return 'Selecione o banner';
                                return null;
                              },
                              onChanged: (image) {
                                controller.onChanged(store.copyWith(banner: image));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  width<800? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Logo da Loja (500x500)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                AppImageFormFieldLogo(
                                  title: 'Logo',
                                  initialValue: store.image,
                                  validator: (image) {
                                    if (image == null) return 'Selecione uma imagem';
                                    return null;
                                  },
                                  onChanged: (image) {
                                    controller.onChanged(store.copyWith(image: image));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              
                      const SizedBox(width: 24),
              
                      // Banner da Loja
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Banner da Loja (1920x375)',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                AppImageFormFieldBanner(
                                  title: '',
                                  aspectRatio: 1920 / 375,
                                  initialValue: store.image,
                                  validator: (image) {
                                    if (image == null) return 'Selecione o banner';
                                    return null;
                                  },
                                  onChanged: (image) {
                                    controller.onChanged(store.copyWith(image: image));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
              
              
              
                  ): const SizedBox(),
              
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }





  Widget _buildReferralss({required double width, required Store store}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Text("Retirada",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),),
                  const SizedBox(height: 8,),

                  Text("Preencha o endereço completo para retiradas(se ativado).",style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),),
                  const SizedBox(height: 24,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          // height: 100,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: notifire.getGry50_800Color
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Endereço da loja ",style: Typographyy.heading6.copyWith(color: notifire.getTextColor)),
                              const SizedBox(height: 20,),
                              width<800?  const SizedBox() : Column(

                                children: [







                                  Row(
                                    children: [

                                      Expanded(
                                        child:   AppTextField(
                                          initialValue: store.zipCode,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(zipCode: v));
                                          },
                                          title: 'Cep',
                                          hint: '11999-222',
                                          formatters: [cepMask],
                                        ),
                                      ),





                                    ],
                                  ),

                                  const SizedBox(height: 15,),
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
                                  const SizedBox(height: 15,),


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
                                      const SizedBox( width: 8,),

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



                                  const SizedBox(height: 15,),

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
                                      const SizedBox( width: 8,),



                                    ],
                                  ),



                                  const SizedBox(height: 15,),

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
                                      const SizedBox(width: 8,),

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




                                  const SizedBox(height: 20,),



































                                ],
                              ),
                              width<800? Column(
                                children: [

                                  Row(
                                    children: [

                                      Expanded(
                                        child:   AppTextField(
                                          initialValue: store.zipCode,
                                          onChanged: (v) {
                                            controller.onChanged(store.copyWith(zipCode: v));
                                          },
                                          title: 'Cep',
                                          hint: '11999-222',
                                          formatters: [cepMask],
                                        ),
                                      ),





                                    ],
                                  ),

                                  const SizedBox(height: 15,),
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
                                  const SizedBox(height: 15,),


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
                                      const SizedBox( width: 8,),

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



                                  const SizedBox(height: 15,),

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
                                      const SizedBox( width: 8,),



                                    ],
                                  ),



                                  const SizedBox(height: 15,),

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
                                      const SizedBox(width: 8,),

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
                              ) :const SizedBox(),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),























                ],
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _build2SF({required double width, required Store store}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(

            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(children: [
                        TextSpan(text: "Redes ",style: Typographyy.heading5.copyWith( color: Theme.of(context).textTheme.displayLarge?.color)),
                        TextSpan(text: "Sociais",style: Typographyy.heading5.copyWith(color: Colors.green)),
                      ])),

                  const SizedBox(height: 8,),

                  Text("Configure as redes sociais da sua loja",style: Typographyy.bodySmallRegular.copyWith( ),maxLines: 2),
                  const SizedBox(height: 25,),




                  const SizedBox(height: 12,),
                  width<800? const SizedBox() :Row(
                    children: [
                      Expanded(child:AppTextField(
                        initialValue: store.facebook,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(facebook: v));
                        },
                        title: 'Facebook',
                        hint: 'facebook/minhaloja',
                      )),
                      const SizedBox(width: 8,),
                      Expanded(child:  AppTextField(
                        initialValue: store.instagram,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(instagram: v));
                        },
                        title: 'Instagram',
                        hint: '@minhaloja',
                      ),


                      ),
                      const SizedBox(width: 8,),
                      Expanded(child:   AppTextField(
                        initialValue: store.tiktok,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(tiktok: v));
                        },
                        title: 'Tiktok',
                        hint: 'tiktok',
                      ),


                      ),
                    ],
                  ),
                  width<800? Column(
                    children: [
                      AppTextField(
                        initialValue: store.facebook,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(facebook: v));
                        },
                        title: 'Facebook',
                        hint: 'facebook/minhaloja',
                      ),

                      const SizedBox(height: 8,),

                      AppTextField(
                        initialValue: store.instagram,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(instagram: v));
                        },
                        title: 'Instagram',
                        hint: '@minhaloja',
                      ),
                      const SizedBox(height: 8,),

                      AppTextField(
                        initialValue: store.tiktok,
                        onChanged: (v) {
                          controller.onChanged(store.copyWith(tiktok: v));
                        },
                        title: 'Tiktok',
                        hint: 'tiktok',
                      ),

                    ],
                  ) :const SizedBox(),



                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApi({required double width, required Store store}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //
                  // Column(
                  //   children: [
                  //     Text("Breanne Schinner",style: Typographyy.heading5.copyWith(color: notifire.getTextColor),),
                  //     const SizedBox(height: 8,),
                  //     Text("demo@gmail.com",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color)),
                  //     const SizedBox(height: 12,),
                  //     Container(
                  //       padding: const EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(50),
                  //           border: Border.all(color: notifire.getGry700_300Color)
                  //       ),
                  //       child: Text("Level 2 Verified",style: Typographyy.bodyMediumMedium.copyWith(color: priMeryColor)),)
                  //   ],
                  // ),

                //  Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry.",style: Typographyy.bodySmallRegular.copyWith( color: notifire.getGry500_600Color),maxLines: 2),
                  const SizedBox(height: 8,),
                  RichText(
                      text: TextSpan(children: [
                        TextSpan(text: "Sobre a ",style: Typographyy.heading5.copyWith( color: Theme.of(context).textTheme.displayLarge?.color)),
                        TextSpan(text: "Loja",style: Typographyy.heading5.copyWith(color: Colors.orange)),
                      ])),
                  const SizedBox(height: 12,),


                //  Text("Enable API Keys",style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor),),
               //   const SizedBox(height: 8,),
                 // Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry",style: Typographyy.bodySmallRegular.copyWith( color: notifire.getGry500_600Color),maxLines: 2),
                //  const SizedBox(height: 25,),
                  width<800? const SizedBox() :Row(
                    children: [


                      Expanded(
                        child: AppTextField(
                                      initialValue: store.name,
                                      title: 'Nome do estabelecimento',
                                      hint: 'Minha loja',
                                      validator: (title) {
                                        if (title == null || title.isEmpty) {
                                          return 'Campo obrigatório';
                                        } else if (title.length < 3) {
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
                      ),
                      const SizedBox(width: 8,),
            Expanded(
              child: AppTextField(
                initialValue: store.description,
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
            ),




                    ],
                  ),
                  width<800? Column(
                    children: [
                      AppTextField(
                        initialValue: store.name,
                        title: 'Nome do estabelecimento',
                        hint: 'Minha loja',
                        validator: (title) {
                          if (title == null || title.isEmpty) {
                            return 'Campo obrigatório';
                          } else if (title.length < 3) {
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
                      const SizedBox(height: 8,),
                      AppTextField(
                        initialValue: store.description,
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

                    ],
                  ) :const SizedBox(),




                ],
              ),
            ),
          ),
        ),
      ],
    );
  }





  Widget _buildNewpass(Store store){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child:  SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [







                  Text("Endereço",style: Typographyy.heading4.copyWith( color: Theme.of(context).textTheme.displayLarge?.color),),








                  Row(
                    children: [

                      Expanded(
                        child:   AppTextField(
                          initialValue: store.zipCode,
                          onChanged: (v) {
                            controller.onChanged(store.copyWith(zipCode: v));
                          },
                          title: 'Cep',
                          hint: '11999-222',
                          formatters: [cepMask],
                        ),
                      ),





                    ],
                  ),

                  const SizedBox(height: 25,),
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
                  const SizedBox(height: 25,),


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
                      const SizedBox( width: 8,),

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



                  const SizedBox(height: 25,),

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
                      const SizedBox( width: 8,),


                    ],
                  ),



                  const SizedBox(height: 25,),

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
                      const SizedBox(width: 8,),

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
        )
      ],
    );
  }


  bool isEye1 = true;


  bool isEye2 = true;



  bool isEye = true;



  Widget _buildTabBar(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 15,),
          SizedBox(
            height: 50,
            width: 700,
            child: TabBar(

              //  labelStyle: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),
                isScrollable: true,

                // indicator: BoxDecoration(
                //   borderRadius: BorderRadius.circular(12),
                //   border: Border.all(color: priMeryColor),
                // ),
              //  unselectedLabelColor: notifire.getTextColor,
                tabs:   [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/user.svg",height: 20,width: 20, color: Theme.of(context).textTheme.displayLarge?.color),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(width: 8,),
                        Text("Geral",style: Typographyy.bodyMediumMedium.copyWith()),

                      ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/share.svg",height: 20,width: 20, color: Theme.of(context).textTheme.displayLarge?.color),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(width: 8,),
                        Text("Endereço",style: Typographyy.bodyMediumMedium.copyWith()),

                      ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/keyboard.svg",height: 20,width: 20, color: Theme.of(context).textTheme.displayLarge?.color),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(width: 8,),
                        Text("Identidade Visual",style: Typographyy.bodyMediumMedium.copyWith()),

                      ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/fingerprint-viewfinder.svg",height: 20,width: 20, color: Theme.of(context).textTheme.displayLarge?.color),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(width: 8,),
                        Text("Redes Sociais",style: Typographyy.bodyMediumMedium.copyWith()),

                      ],),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       SvgPicture.asset("assets/images/lock.svg",height: 20,width: 20,color: notifire.getTextColor),
                  //       // Icon(Icons.supervisor_account),
                  //       const SizedBox(width: 8,),
                  //       Text("Change Password",style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor)),
                  //
                  //     ],),
                  // ),

                ]
            ),
          ),
        ],
      ),
    );
  }
}





