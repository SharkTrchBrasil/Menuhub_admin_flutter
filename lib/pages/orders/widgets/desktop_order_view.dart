import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';



import '../../../models/order_details.dart';
import '../../../widgets/fixed_header.dart';
import '../orders_page.dart';


class DesktopOrderView extends StatelessWidget {
  final List<OrderDetails> orders;
  final Widget Function(int statusIndex) buildStatusHeader;
  final List<OrderDetails> Function(List<OrderDetails> orders, int statusIndex) getOrdersByStatusIndex;
  final Widget Function(List<OrderDetails> orders, int statusIndex) buildStatusColumn;
  final VoidCallback? onRemovePressed;
  final VoidCallback? onAddPressed;

  const DesktopOrderView({
    super.key,
    required this.orders,
    required this.buildStatusHeader,
    required this.getOrdersByStatusIndex,
    required this.buildStatusColumn,
    this.onRemovePressed,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          FixedHeader(
            title: '',
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/images/plus-.svg",
                      height: 20,
                      width: 20,
                      color: Colors.red,
                    ),
                    onPressed: onRemovePressed,
                    tooltip: 'Retirar',
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/images/plus+.svg",
                      height: 20,
                      width: 20,
                      color: Colors.green,
                    ),
                    onPressed: onAddPressed,
                    tooltip: 'Adicionar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.store),
                    onPressed: () {

                      context.push('/stores/2/store-settings');


                      // showDialog(
                      //   barrierColor: Colors.transparent,
                      //   context: context,
                      //   builder: (context) => BlocProvider.value(
                      //     value: BlocProvider.of<StoreCubit>(context),
                      //     child: const StoreSettingsDialog(),
                      //   ),
                      // );



                    },
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Expanded(child: buildStatusHeader(0)),
              const SizedBox(width: 16),
              Expanded(child: buildStatusHeader(1)),
              const SizedBox(width: 16),
              Expanded(child: buildStatusHeader(2)),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildStatusColumn(getOrdersByStatusIndex(orders, 0), 0),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildStatusColumn(getOrdersByStatusIndex(orders, 1), 1),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildStatusColumn(getOrdersByStatusIndex(orders, 2), 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
