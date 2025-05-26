import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/models/totem.dart';
import 'package:totem_pro_admin/pages/totems/widgets/add_totem_dialog.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/totems_repository.dart';

import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../widgets/app_confirmation_dialog.dart';

class TotemsPage extends StatefulWidget {
  const TotemsPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<TotemsPage> createState() => _TotemsPageState();
}

class _TotemsPageState extends State<TotemsPage> {
  late final AppListController<Totem> totemsController =
      AppListController<Totem>(
        fetch: () => getIt<TotemsRepository>().getTotems(widget.storeId),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          AppPageHeader(
            title: 'Totens Vinculados',

            actions: [
              AppPrimaryButton(
                label: 'Vincular Totem',
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => AddTotemDialog(storeId: widget.storeId),
                  );
                  totemsController.refresh();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: totemsController,
            builder: (_, __) {
              return AppPageStatusBuilder<List<Totem>>(
                tryAgain: totemsController.refresh,
                status: totemsController.status,
                successBuilder: (totems) {
                  return AppTable<Totem>(
                    items: totems,
                    maxWidth: 600,
                    columns: [
                      AppTableColumnString(
                        title: 'Nome',
                        dataSelector: (totem) => totem.name,
                      ),
                      AppTableColumnString(
                        title: 'Criado em',
                        dataSelector:
                            (totem) => totem.createdAt.toIso8601String(),
                      ),
                      AppTableColumnWidget(
                        title: 'Ações',
                        width: FixedColumnWidth(120),
                        dataSelector:
                            (totem) => Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder:
                                          (_) => AppConfirmationDialog(
                                            title: 'Tem certeza?',
                                            description:
                                                'Este totem será desconectado e apresentará erro caso algum cliente esteja utilizando.',
                                          ),
                                    );
                                    if(result != null && result) {
                                      final l = showLoading();
                                      final result = await getIt<TotemsRepository>()
                                          .revokeTotem(widget.storeId, totem.id);
                                      l();
                                      if(result.isRight) {
                                        showSuccess('Totem desconectado com sucesso!');
                                        totemsController.refresh();
                                      } else {
                                        showError('Falha ao desconectar totem!');
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
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
