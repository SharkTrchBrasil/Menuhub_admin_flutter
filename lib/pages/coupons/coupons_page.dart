import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/models/coupon.dart';

import 'package:totem_pro_admin/repositories/coupons_repository.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';

import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../constdata/staticdata.dart';
import '../../core/helpers/mask.dart';

import '../../widgets/fixed_header.dart';
import '../base/BasePage.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {


  late final AppListController<Coupon> categoriesController =
      AppListController<Coupon>(
        fetch: () => getIt<CouponRepository>().getCoupons(widget.storeId),
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
              title: 'Cupons',

              actions: [
                AppPrimaryButton(
                  label: 'Adicionar',

                  onPressed: () {
                    DialogService.showCouponsDialog(
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
            DialogService.showCouponsDialog(
              context,
              widget.storeId,
              onSaved: (coupon) {
                categoriesController.refresh();
              },
            );
          },
          tooltip: 'Novo cupom',
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
          return AppPageStatusBuilder<List<Coupon>>(
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
                    return cardss(coupon: coupon, storeId: widget.storeId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget cardss({required Coupon coupon, required int storeId}) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = coupon.isActive
        ? _generateCouponBackground(coupon.id.toString(), isDark)
        : (isDark ? Color(0xFF7F1D1D) : Color(0xFFFEE2E2)); // Inativo

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
        // image: const DecorationImage(
        //   image: AssetImage("assets/images/Group.png"),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //
                    // Expanded(
                    //   child: Text(
                    //     coupon.discountFixed != null
                    //         ? coupon.discountFixed!.toPrice()
                    //         : '${coupon.discountPercent}%',
                    //     style: const TextStyle(fontSize: 14),
                    //   ),
                    // ),

                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      tooltip: 'Editar cupom',
                      onPressed: () {
                        DialogService.showCouponsDialog(
                          context,
                          widget.storeId,
                          couponsId: coupon.id,
                          onSaved: (coupon) {
                            categoriesController.refresh();
                          },
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                coupon.code,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              coupon.isActive
                                  ? CouponCopyButton(couponCode: coupon.code)
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),

                        Text(
                          dateFormat.format(coupon.endDate!),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            coupon.isActive ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              color:
                                  coupon.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          '${coupon.used}/${coupon.maxUses}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    if (coupon.product?.name != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              coupon.product!.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _generateCouponBackground(String id, bool isDark) {
    final List<Color> lightColors = [
      Color(0xFFE0F7FA),
      Color(0xFFFFF9C4),
      Color(0xFFD1C4E9),
      Color(0xFFE1F5FE),
      Color(0xFFC8E6C9),
      Color(0xFFFFE0B2),
      Color(0xFFFFCDD2),
    ];

    final List<Color> darkColors = [
      Color(0xFF004D40),
      Color(0xFF3E2723),
      Color(0xFF1A237E),
      Color(0xFF263238),
      Color(0xFF37474F),
      Color(0xFF4A148C),
      Color(0xFF880E4F),
    ];

    final hash = id.hashCode.abs();
    final index = hash % lightColors.length;

    return isDark ? darkColors[index] : lightColors[index];
  }


}

class CouponCopyButton extends StatelessWidget {
  final String couponCode;

  const CouponCopyButton({Key? key, required this.couponCode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copiar código',
      child: IconButton(
        icon: const Icon(Icons.copy, size: 20),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: couponCode));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código copiado!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
