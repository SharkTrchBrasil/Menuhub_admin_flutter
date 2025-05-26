import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store_access.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/pages/accesses/widgets/add_user_dialog.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_confirmation_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../repositories/store_repository.dart';

class AccessesPage extends StatefulWidget {
  const AccessesPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<AccessesPage> createState() => _AccessesPageState();
}

class _AccessesPageState extends State<AccessesPage> {
  final StoreRepository storeRepository = getIt();
  final AuthRepository authRepository = getIt();

  late final AppListController<StoreAccess> controller =
  AppListController<StoreAccess>(
    fetch: () => storeRepository.getStoreAccesses(widget.storeId),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Usuários',
            actions: [
              AppPrimaryButton(
                label: 'Adicionar Usuário',
                onPressed: addUser,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return AppPageStatusBuilder<List<StoreAccess>>(
                status: controller.status,
                tryAgain: controller.refresh,
                successBuilder: (users) {
                  return AppTable<StoreAccess>(
                    maxWidth: 600,
                    items: users,
                    columns: [
                      AppTableColumnString(
                        title: 'Usuário',
                        dataSelector: (c) => c.user.name,
                      ),
                      AppTableColumnString(
                        title: 'E-mail',
                        dataSelector: (c) => c.user.email,
                      ),
                      AppTableColumnString(
                        title: 'Função',
                        dataSelector: (c) => c.role.title,
                      ),
                      AppTableColumnWidget(
                        title: 'Ações',
                        width: const FixedColumnWidth(100),
                        dataSelector: (c) {
                          return Row(
                            children: [
                              if (authRepository.user!.id != c.user.id && c.role != StoreAccessRole.owner)
                                IconButton(
                                  onPressed: () => deleteStoreAccess(c),
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
                                ),
                            ],
                          );
                        },
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

  Future<void> addUser() async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddUserDialog(storeId: widget.storeId),
    );
    if(result != null && result && mounted) {
      controller.refresh();
    }
  }

  Future<void> deleteStoreAccess(StoreAccess storeAccess) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => const AppConfirmationDialog(
        title: 'Tem certeza?',
        description:
        'Este usuário será removido da loja e não poderá mais acessá-la.',
      ),
    );
    if (confirmed != null && confirmed) {
      final l = showLoading();
      final result = await storeRepository.revokeAccess(
          widget.storeId, storeAccess.user.id);
      l();
      if (result.isRight) {
        showSuccess('Usuário removido com sucesso!');
        controller.refresh();
      } else {
        showError('Falha ao remover usuário!');
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
