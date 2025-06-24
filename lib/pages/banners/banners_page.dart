import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/models/banners.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/banner_repository.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/filter_button.dart';


import '../../ConstData/typography.dart';

import '../../services/dialog_service.dart';
import '../../widgets/fixed_header.dart';
import '../../widgets/mobileappbar.dart';
import '../../widgets/search_field.dart';

class BannersPage extends StatefulWidget {
  const BannersPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  late final AppListController<BannerModel> categoriesController =
      AppListController<BannerModel>(
        fetch: () => getIt<BannerRepository>().getBanners(widget.storeId),
      );

  @override
  Widget build(BuildContext context) {

    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Coupons'),
      mobileBuilder: (BuildContext context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              firstcontain(size: MediaQuery.of(context).size.width),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
      desktopBuilder: (BuildContext context) {
        return Column(
          children: [
            FixedHeader(
              title: 'Banners',

              actions: [
                AppPrimaryButton(
                  label: 'Adicionar',

                  onPressed: () {
                    DialogService.showBannerDialog(
                      context,
                      widget.storeId,
                      onSaved: (coupon) {
                        categoriesController.refresh();
                      },
                    );
                  },
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: firstcontain(size: MediaQuery.of(context).size.width),
              ),
            ),
          ],
        );
      },

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showBannerDialog(
              context,
              widget.storeId,
              onSaved: (coupon) {
                categoriesController.refresh();
              },
            );
          },
          tooltip: 'Novo banner',
          elevation: 0,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget firstcontain({required double size}) {

    int crossAxisCount = 1;
    if (MediaQuery.of(context).size.width >= 1200) {
      crossAxisCount = 3;
    } else if (MediaQuery.of(context).size.width  >= 800) {
      crossAxisCount = 2;
    } else if (MediaQuery.of(context).size.width  >= 600) {
      crossAxisCount = 1;
    } else {
      crossAxisCount = 1;
    }






    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10),
      child: AnimatedBuilder(
        animation: categoriesController,
        builder: (_, __) {
          return AppPageStatusBuilder<List<BannerModel>>(
            tryAgain: categoriesController.refresh,
            status: categoriesController.status,
            successBuilder: (coupons) {
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: coupons.length,
                  physics: NeverScrollableScrollPhysics(),

                  // evita conflito de rolagem
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    return Container(child: Text('banner'));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

}



