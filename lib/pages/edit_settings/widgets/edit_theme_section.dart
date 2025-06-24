import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store_theme.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_color_form_field.dart';
import 'package:totem_pro_admin/widgets/app_drop_down_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';



class EditThemeSection extends StatefulWidget {
  const EditThemeSection({super.key, required this.storeId});

  final int storeId;

  @override
  State<EditThemeSection> createState() => _EditThemeSectionState();
}

class _EditThemeSectionState extends State<EditThemeSection> {
  final StoreRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();

  late final AppEditController<void, StoreTheme> controller =
  AppEditController<void, StoreTheme>(
    id: widget.storeId,
    fetch: (id) => storeRepository.getStoreTheme(id),
    save: (theme) => storeRepository.updateStoreTheme(widget.storeId, theme),
    empty: () => StoreTheme(
      primaryColor: const Color(0xffdfad00),
      secondaryColor: Colors.black,
      backgroundColor: const Color(0xffeeeeee),
      cardColor: Colors.white,
      onPrimaryColor: Colors.black,
      onSecondaryColor: Colors.white,
      onBackgroundColor: Colors.black,
      onCardColor: Colors.black,
      inactiveColor: Colors.grey[300]!,
      onInactiveColor: Colors.white,
      sidebarBackgroundColor: const Color(0xff333333),
      sidebarTextColor: Colors.white,
      sidebarIconColor: Colors.white70,
      categoryBackgroundColor: const Color(0xfff5f5f5),
      categoryTextColor: Colors.black87,
      productBackgroundColor: Colors.white,
      productTextColor: Colors.black87,
      priceTextColor: const Color(0xffdfad00),
      cartBackgroundColor: const Color(0xffffcc00),
      cartTextColor: Colors.black,
      fontFamily: DsThemeFontFamily.roboto,
      themeName: DsThemeName.classic,
      categoryLayout: DsCategoryLayout.verticalWithSideProducts,
      productLayout: DsProductLayout.grid,
    ),
  );

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tema do Totem',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return AppPageStatusBuilder<StoreTheme>(
                status: controller.status,
                successBuilder: (theme) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Cores Gerais do Tema ---
                        _buildSectionHeader('Cores Gerais do Tema'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              Column(
                                children: [
                                  AppColorFormField(
                                    title: 'Cor primária',
                                    initialValue: theme.primaryColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(primaryColor: color));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppColorFormField(
                                    title: 'Cor do texto na cor primária',
                                    initialValue: theme.onPrimaryColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(onPrimaryColor: color));
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  AppColorFormField(
                                    title: 'Cor secundária',
                                    initialValue: theme.secondaryColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(secondaryColor: color));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppColorFormField(
                                    title: 'Cor do texto na cor secundária',
                                    initialValue: theme.onSecondaryColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(onSecondaryColor: color));
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  AppColorFormField(
                                    title: 'Cor de fundo',
                                    initialValue: theme.backgroundColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(backgroundColor: color));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppColorFormField(
                                    title: 'Cor do texto no fundo',
                                    initialValue: theme.onBackgroundColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(onBackgroundColor: color));
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  AppColorFormField(
                                    title: 'Cor de cartões',
                                    initialValue: theme.cardColor,
                                    onChanged: (color) {
                                      controller
                                          .onChanged(theme.copyWith(cardColor: color));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppColorFormField(
                                    title: 'Cor do texto no cartão',
                                    initialValue: theme.onCardColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(onCardColor: color));
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  AppColorFormField(
                                    title: 'Cor de inatividade',
                                    initialValue: theme.inactiveColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(inactiveColor: color));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppColorFormField(
                                    title: 'Cor do texto na inatividade',
                                    initialValue: theme.onInactiveColor,
                                    onChanged: (color) {
                                      controller.onChanged(
                                          theme.copyWith(onInactiveColor: color));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // --- Cores da Sidebar ---
                        _buildSectionHeader('Configurações da Sidebar'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              AppColorFormField(
                                title: 'Cor do fundo da sidebar',
                                initialValue: theme.sidebarBackgroundColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(sidebarBackgroundColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do texto na sidebar',
                                initialValue: theme.sidebarTextColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(sidebarTextColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do ícone na sidebar',
                                initialValue: theme.sidebarIconColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(sidebarIconColor: color));
                                },
                              ),
                            ],
                          ),
                        ),

                        // --- Cores e Layout de Categorias ---
                        _buildSectionHeader('Configurações de Categorias'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              AppColorFormField(
                                title: 'Cor de fundo da categoria',
                                initialValue: theme.categoryBackgroundColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(categoryBackgroundColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do texto na categoria',
                                initialValue: theme.categoryTextColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(categoryTextColor: color));
                                },
                              ),
                              SizedBox(
                                width: 300,
                                child: AppDropDownFormField(
                                  title: 'Layout das Categorias',
                                  value: theme.categoryLayout,
                                  validator: (f) {
                                    if (f == null) {
                                      return 'Selecione o layout de categorias';
                                    }
                                    return null;
                                  },
                                  onChanged: (f) {
                                    controller.onChanged(
                                        theme.copyWith(categoryLayout: f));
                                  },
                                  items: DsCategoryLayout.values
                                      .map(
                                        (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f.name),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- Cores e Layout de Produtos ---
                        _buildSectionHeader('Configurações de Produtos'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              AppColorFormField(
                                title: 'Cor de fundo do produto',
                                initialValue: theme.productBackgroundColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(productBackgroundColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do texto no produto',
                                initialValue: theme.productTextColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(productTextColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do preço',
                                initialValue: theme.priceTextColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(priceTextColor: color));
                                },
                              ),
                              SizedBox(
                                width: 300,
                                child: AppDropDownFormField(
                                  title: 'Layout dos Produtos',
                                  value: theme.productLayout,
                                  validator: (f) {
                                    if (f == null) {
                                      return 'Selecione o layout dos produtos';
                                    }
                                    return null;
                                  },
                                  onChanged: (f) {
                                    controller
                                        .onChanged(theme.copyWith(productLayout: f));
                                  },
                                  items: DsProductLayout.values
                                      .map(
                                        (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f.name),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- Cores do Carrinho ---
                        _buildSectionHeader('Configurações do Carrinho'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              AppColorFormField(
                                title: 'Cor de fundo do carrinho',
                                initialValue: theme.cartBackgroundColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(cartBackgroundColor: color));
                                },
                              ),
                              AppColorFormField(
                                title: 'Cor do texto no carrinho',
                                initialValue: theme.cartTextColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(cartTextColor: color));
                                },
                              ),
                            ],
                          ),
                        ),

                        // --- Configurações Gerais do Tema (Fonte e Nome do Tema) ---
                        _buildSectionHeader('Geral do Tema'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              SizedBox(
                                width: 300,
                                child: AppDropDownFormField(
                                  title: 'Fonte',
                                  value: theme.fontFamily,
                                  validator: (f) {
                                    if (f == null) {
                                      return 'Selecione uma fonte';
                                    }
                                    return null;
                                  },
                                  onChanged: (f) {
                                    controller
                                        .onChanged(theme.copyWith(fontFamily: f));
                                  },
                                  items: DsThemeFontFamily.values
                                      .map(
                                        (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f.nameGoogle),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: AppDropDownFormField(
                                  title: 'Tema',
                                  value: theme.themeName,
                                  validator: (f) {
                                    if (f == null) return 'Selecione um tema';
                                    return null;
                                  },
                                  onChanged: (f) {
                                    controller
                                        .onChanged(theme.copyWith(themeName: f));
                                  },
                                  items: DsThemeName.values
                                      .map(
                                        (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f.title),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
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
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}