// ignore_for_file: camel_case_types, deprecated_member_use
//
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:totem_pro_admin/widgets/select_store.dart';
import 'package:totem_pro_admin/widgets/subscription_inline_text.dart';
import 'package:totem_pro_admin/widgets/theme_switch.dart';

import '../UI TEMP/controller/get_code.dart';

import '../core/di.dart';
import '../core/menu_app_controller.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../repositories/store_repository.dart';

enum SampleItem { itemOne, itemTwo, itemThree, itemfour, itemfive, itemsix }

class appber extends StatefulWidget implements PreferredSizeWidget {
  final int storeId;

  const appber({super.key, required this.storeId});

  @override
  State<appber> createState() => _appberState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _appberState extends State<appber> {
  InboxController inboxController = Get.put(InboxController());

  final StoreRepository storeRepository = getIt();
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) {
          return InkWell(
            onTap: () {
              context.read<DrawerControllerProvider>().toggle();
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image(
                image: const AssetImage('assets/images/menu-left.png'),
                fit: BoxFit.fill,
              ),
            ),
          );
        }
      ),

      actions: [
        ThemeSwitcher(),

        BlocBuilder<StoresManagerCubit, StoresManagerState>(
          builder: (context, storeState) {
            if (storeState is StoresManagerLoaded) {
              final storeData = storeState.stores[widget.storeId];
              final subscription = storeData?.store.subscription;

              if (subscription != null && subscription.isExpired && !subscription.isInGracePeriod) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SubscriptionWarningInline(
                    message: 'Sua assinatura venceu há ${subscription.daysUntilExpiration.abs()} dias!',
                    onRenew: () {
                      context.push('/admin/store/${widget.storeId}/planos');
                    },
                  ),
                );
              }
            }

            return const SizedBox.shrink(); // Não mostra nada se assinatura está válida
          },
        ),


        Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: StorePopupMenu(
                    stores: storeRepository.stores,
                    selectedStoreId: widget.storeId,
                    onStoreSelected: (id) {
                      context.go('/stores/$id/orders');
                    },
                    onAddStore: () {
                      context.go('/stores/new');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
