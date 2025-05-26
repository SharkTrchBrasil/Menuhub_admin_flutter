import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/filter_button.dart';


import '../../ConstData/typography.dart';

import '../../widgets/search_field.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final AppListController<Category> categoriesController =
      AppListController<Category>(
        fetch: () => getIt<CategoryRepository>().getCategories(widget.storeId),
      );

  @override
  Widget build(BuildContext context) {

    return BasePage(
      mobileBuilder: (BuildContext context) {
        return Column(
          children: [
            const SizedBox(height: 26),
            Expanded(
              child: AnimatedBuilder(
                animation: categoriesController,
                builder: (_, __) {
                  return AppPageStatusBuilder<List<Category>>(
                    tryAgain: categoriesController.refresh,
                    status: categoriesController.status,
                    successBuilder: (categories) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            // MOBILE
                            return ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    onTap:
                                        () => context.go(
                                          '/stores/${widget.storeId}/categories/${category.id}',
                                        ),
                                    leading: Image.network(
                                      category.image!.url ?? '',
                                    ),
                                    title: Text(
                                      category.name,
                                      style: Typographyy.bodyLargeMedium
                                          .copyWith(
                                         //   color: notifire.getTextColor,
                                          ),
                                    ),
                                    subtitle: Text(category.name ?? ''),
                                  ),
                                );
                              },
                            );
                          } else {
                            // DESKTOP OU TABLET
                            return SizedBox(
                              height:
                                  MediaQuery.of(context).size.height +
                                  (constraints.maxWidth < 600 ? 110 : -150),
                              width: constraints.maxWidth,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  SizedBox(
                                    width:
                                        constraints.maxWidth < 1400
                                            ? 1500
                                            : constraints.maxWidth,
                                    child: Column(
                                      children: [
                                        // Cabeçalho fixo
                                        Container(
                                          color: Colors.white,
                                          child: Table(
                                            children: [
                                              TableRow(
                                                children: [
                                                  Center(
                                                    child: dataColumn1(
                                                      title: "Ação",
                                                      iscenter: true,
                                                    ),
                                                  ),
                                                  dataColumn1(
                                                    title: "Imagem",
                                                    iscenter: false,
                                                  ),
                                                  dataColumn1(
                                                    title: "Nome",
                                                    iscenter: false,
                                                  ),

                                                  dataColumn1(
                                                    title: "Prioridade",
                                                    iscenter: false,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Divider
                                        // Divider após cabeçalho
                                        Table(
                                          children: [
                                            TableRow(
                                              children: List.generate(6, (_) {
                                                return Divider(

                                                  height: 30,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        // Conteúdo rolável
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: categories.length,
                                            itemBuilder: (context, index) {
                                              final product = categories[index];
                                              return Table(
                                                // columnWidths: const {
                                                //   0: FixedColumnWidth(140), // Coluna "Ação" bem estreita
                                                // },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 10,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Botão de três pontinhos
                                                            PopupMenuButton(
                                                              tooltip: "",
                                                           //   color:
                                                             //     notifire
                                                                  //    .getDrawerColor,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    45,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Container(
                                                                height: 30,
                                                                width: 30,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  color:
                                                                      Colors
                                                                          .transparent,
                                                                  border: Border.all(
                                                                  //  color:
                                                                    //    notifire
                                                                        //    .getGry700_300Color,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/images/dots-vertical.svg",
                                                                    height: 20,
                                                                    width: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                              itemBuilder: (
                                                                context,
                                                              ) {
                                                                return [
                                                                  PopupMenuItem(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    child: Column(
                                                                      children: [
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/copy.svg",
                                                                          title:
                                                                              "Copiar",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/printer.svg",
                                                                          title:
                                                                              "Imprimir",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/file-download.svg",
                                                                          title:
                                                                              "Baixar PDF",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/share-two.svg",
                                                                          title:
                                                                              "Compartilhar",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/archive.svg",
                                                                          title:
                                                                              "Arquivar",
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ];
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),

                                                            // Botão Editar
                                                            GestureDetector(
                                                              onTap:
                                                                  () => context.go(
                                                                    '/stores/${widget.storeId}/categories/${product.id}',
                                                                  ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          6,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  "Editar",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          leading: CircleAvatar(
                                                            radius: 24,
                                                          //  backgroundColor:
                                                               // notifire.getBgPrimaryColor
                                                                  //  .withOpacity(
                                                                   //   0.2,
                                                                   // ),

                                                            child:
                                                                Image.network(
                                                                  product
                                                                      .image!
                                                                      .url!,
                                                                ),
                                                          ),
                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          title: Text(
                                                            product.name,
                                                            style: Typographyy
                                                                .bodyLargeMedium
                                                                .copyWith(
                                                                 // color:
                                                                   //   notifire
                                                                        //  .getTextColor,
                                                                ),
                                                          ),

                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          title: Text(
                                                            product.priority
                                                                .toString(),
                                                            style: Typographyy
                                                                .bodyLargeMedium
                                                                .copyWith(
                                                                 // color:
                                                                   //   notifire
                                                                      //    .getTextColor,
                                                                ),
                                                          ),

                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      desktopBuilder: (BuildContext context) {
        return Column(
          children: [
            Row(
              children: [
                SearchField(onChanged: (String value) {}),

                const Spacer(),

                FilterButton(onPressed: () {}),

                const SizedBox(width: 16),

                AppPrimaryButton(
                  label: 'Nova categoria',
                  onPressed: () {
                    context.go('/stores/${widget.storeId}/categories/new');
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            Expanded(
              child: AnimatedBuilder(
                animation: categoriesController,
                builder: (_, __) {
                  return AppPageStatusBuilder<List<Category>>(
                    tryAgain: categoriesController.refresh,
                    status: categoriesController.status,
                    successBuilder: (categories) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            // MOBILE
                            return ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    onTap:
                                        () => context.go(
                                          '/stores/${widget.storeId}/categories/${category.id}',
                                        ),
                                    leading: Image.network(
                                      category.image!.url ?? '',
                                    ),
                                    title: Text(
                                      category.name,
                                      style: Typographyy.bodyLargeMedium
                                          .copyWith(
                                         //   color: notifire.getTextColor,
                                          ),
                                    ),
                                    subtitle: Text(category.name ?? ''),
                                  ),
                                );
                              },
                            );
                          } else {
                            // DESKTOP OU TABLET
                            return SizedBox(
                              height:
                                  MediaQuery.of(context).size.height +
                                  (constraints.maxWidth < 600 ? 110 : -150),
                              width: constraints.maxWidth,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  SizedBox(
                                    width:
                                        constraints.maxWidth < 1400
                                            ? 1500
                                            : constraints.maxWidth,
                                    child: Column(
                                      children: [
                                        // Cabeçalho fixo
                                        Container(
                                          color: Colors.white,
                                          child: Table(
                                            children: [
                                              TableRow(
                                                children: [
                                                  Center(
                                                    child: dataColumn1(
                                                      title: "Ação",
                                                      iscenter: true,
                                                    ),
                                                  ),
                                                  dataColumn1(
                                                    title: "Imagem",
                                                    iscenter: false,
                                                  ),
                                                  dataColumn1(
                                                    title: "Nome",
                                                    iscenter: false,
                                                  ),

                                                  dataColumn1(
                                                    title: "Prioridade",
                                                    iscenter: false,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Divider
                                        // Divider após cabeçalho
                                        Table(
                                          children: [
                                            TableRow(
                                              children: List.generate(6, (_) {
                                                return Divider(
                                                 // color:
                                                    //  notifire
                                                      //    .getGry700_300Color,
                                                  height: 30,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        // Conteúdo rolável
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: categories.length,
                                            itemBuilder: (context, index) {
                                              final product = categories[index];
                                              return Table(
                                                // columnWidths: const {
                                                //   0: FixedColumnWidth(140), // Coluna "Ação" bem estreita
                                                // },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 10,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Botão de três pontinhos
                                                            PopupMenuButton(
                                                              tooltip: "",
                                                            //  color:
                                                              //    notifire
                                                                 //     .getDrawerColor,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    45,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Container(
                                                                height: 30,
                                                                width: 30,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  color:
                                                                      Colors
                                                                          .transparent,
                                                                  border: Border.all(
                                                                 //   color:
                                                                      //  notifire
                                                                      //      .getGry700_300Color,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/images/dots-vertical.svg",
                                                                    height: 20,
                                                                    width: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                              itemBuilder: (
                                                                context,
                                                              ) {
                                                                return [
                                                                  PopupMenuItem(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    child: Column(
                                                                      children: [
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/copy.svg",
                                                                          title:
                                                                              "Copiar",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/printer.svg",
                                                                          title:
                                                                              "Imprimir",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/file-download.svg",
                                                                          title:
                                                                              "Baixar PDF",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/share-two.svg",
                                                                          title:
                                                                              "Compartilhar",
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        _buildRow(
                                                                          iconpath:
                                                                              "assets/images/archive.svg",
                                                                          title:
                                                                              "Arquivar",
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ];
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),

                                                            // Botão Editar
                                                            GestureDetector(
                                                              onTap:
                                                                  () => context.go(
                                                                    '/stores/${widget.storeId}/categories/${product.id}',
                                                                  ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          6,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  "Editar",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          leading: CircleAvatar(
                                                            radius: 24,
                                                         //   backgroundColor:
                                                              //  notifire.getBgPrimaryColor
                                                                   // .withOpacity(
                                                                   //   0.2,
                                                                 //   ),
                                                            child:
                                                                Image.network(
                                                                  product
                                                                      .image!
                                                                      .url!,
                                                                ),
                                                          ),
                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          title: Text(
                                                            product.name,
                                                            style: Typographyy
                                                                .bodyLargeMedium
                                                                .copyWith(
                                                                 // color:
                                                                  //    notifire
                                                                      //    .getTextColor,
                                                                ),
                                                          ),

                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: ListTile(
                                                          title: Text(
                                                            product.priority
                                                                .toString(),
                                                            style: Typographyy
                                                                .bodyLargeMedium
                                                                .copyWith(
                                                                 // color:
                                                                  //    notifire
                                                                       //   .getTextColor,
                                                                ),
                                                          ),

                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            context.go('/stores/${widget.storeId}/categories/new');
          },
          child: Icon(Icons.add),
          tooltip: 'Nova categoria',
          elevation: 0,
        ),
      ),
    );
  }
}

Widget dataColumn1({required String title, required bool iscenter}) {
  return Row(
    mainAxisAlignment:
        iscenter ? MainAxisAlignment.center : MainAxisAlignment.start,
    children: [
      Text(
        title,
        style: Typographyy.bodyLargeExtraBold.copyWith(
         // color: notifire.getGry500_600Color,
        ),
      ),
    ],
  );
}

Widget _buildRow({required String iconpath, required String title}) {
  return Row(
    children: [
      SvgPicture.asset(
        iconpath,
        width: 20,
        height: 20,
      //  color: notifire.getGry500_600Color,
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: Typographyy.bodySmallSemiBold.copyWith(
       //   color: notifire.getGry500_600Color,
        ),
      ),
    ],
  );
}
