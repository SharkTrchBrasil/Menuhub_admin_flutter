import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store_theme.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_color_form_field.dart';
import 'package:totem_pro_admin/widgets/app_drop_down_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';

import '../../../repositories/store_repository.dart';

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
        save:
            (theme) => storeRepository.updateStoreTheme(widget.storeId, theme),
        empty:
            () => StoreTheme(
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
              fontFamily: StoreThemeFontFamily.roboto,
            ),
      );

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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
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
                                            theme.copyWith(primaryColor: color),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AppColorFormField(
                                        title: 'Cor do texto na cor primária',
                                        initialValue: theme.onPrimaryColor,
                                        onChanged: (color) {
                                          controller.onChanged(
                                            theme.copyWith(
                                              onPrimaryColor: color,
                                            ),
                                          );
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
                                            theme.copyWith(
                                              secondaryColor: color,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AppColorFormField(
                                        title: 'Cor do texto na cor secundária',
                                        initialValue: theme.onSecondaryColor,
                                        onChanged: (color) {
                                          controller.onChanged(
                                            theme.copyWith(
                                              onSecondaryColor: color,
                                            ),
                                          );
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
                                            theme.copyWith(
                                              backgroundColor: color,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AppColorFormField(
                                        title: 'Cor do texto no fundo',
                                        initialValue: theme.onBackgroundColor,
                                        onChanged: (color) {
                                          controller.onChanged(
                                            theme.copyWith(
                                              onBackgroundColor: color,
                                            ),
                                          );
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
                                          controller.onChanged(
                                            theme.copyWith(cardColor: color),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AppColorFormField(
                                        title: 'Cor do texto no cartão',
                                        initialValue: theme.onCardColor,
                                        onChanged: (color) {
                                          controller.onChanged(
                                            theme.copyWith(onCardColor: color),
                                          );
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
                                            theme.copyWith(
                                              inactiveColor: color,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AppColorFormField(
                                        title: 'Cor do texto na inatividade',
                                        initialValue: theme.onInactiveColor,
                                        onChanged: (color) {
                                          controller.onChanged(
                                            theme.copyWith(
                                              onInactiveColor: color,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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
                                      theme.copyWith(fontFamily: f),
                                    );
                                  },
                                  items:
                                      StoreThemeFontFamily.values
                                          .map(
                                            (f) => DropdownMenuItem(
                                              value: f,
                                              child: Text(f.title),
                                            ),
                                          )
                                          .toList(),
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
                        ),
                      ),
                    ],
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
