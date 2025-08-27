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
      mode: DsThemeMode.light,  // Alterado para DsThemeMode.light
      fontFamily: DsThemeFontFamily.roboto,
      themeName: DsThemeName.classic,
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
                        // --- Configurações Básicas do Tema ---
                        _buildSectionHeader('Configurações Básicas do Tema'),
                        _buildCard(
                          child: Wrap(
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              AppColorFormField(
                                title: 'Cor primária',
                                initialValue: theme.primaryColor,
                                onChanged: (color) {
                                  controller.onChanged(
                                      theme.copyWith(primaryColor: color));
                                },
                              ),
                              SizedBox(
                                width: 300,
                                child: AppDropDownFormField(
                                  title: 'Modo do Tema',
                                  value: theme.mode,
                                  validator: (mode) {
                                    if (mode == null) {
                                      return 'Selecione o modo do tema';
                                    }
                                    return null;
                                  },
                                  onChanged: (mode) {
                                    controller.onChanged(
                                        theme.copyWith(mode: mode));
                                  },
                                  items: DsThemeMode.values  // Alterado para DsThemeMode
                                      .map(
                                        (mode) => DropdownMenuItem(
                                      value: mode,
                                      child: Text(
                                        mode == DsThemeMode.light  // Alterado para DsThemeMode.light
                                            ? 'Claro'
                                            : 'Escuro',
                                      ),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
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
                                    controller.onChanged(
                                        theme.copyWith(fontFamily: f));
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
                                  title: 'Tema Pré-definido',
                                  value: theme.themeName,
                                  validator: (f) {
                                    if (f == null) return 'Selecione um tema';
                                    return null;
                                  },
                                  onChanged: (f) {
                                    controller.onChanged(
                                        theme.copyWith(themeName: f));
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

                        // --- Visualização das Cores Derivadas ---
                        _buildSectionHeader('Visualização das Cores Derivadas'),
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estas cores são calculadas automaticamente a partir da cor primária e modo selecionado:',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                runSpacing: 16,
                                spacing: 16,
                                children: [
                                  _buildColorPreview(
                                    'Cor Secundária',
                                    theme.secondaryColor,
                                  ),
                                  _buildColorPreview(
                                    'Cor de Fundo',
                                    theme.backgroundColor,
                                  ),
                                  _buildColorPreview(
                                    'Texto sobre Primária',
                                    theme.onPrimaryColor,
                                  ),

                                ],
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

  Widget _buildColorPreview(String title, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
            style: TextStyle(
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}