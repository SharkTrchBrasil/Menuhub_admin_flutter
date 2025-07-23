import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/pages/edit_subscription/edit_subscription_page_controller.dart';
import 'package:totem_pro_admin/pages/new_subscription/new_subscription_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';

class EditSubscriptionPage extends StatefulWidget {
  const EditSubscriptionPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<EditSubscriptionPage> createState() => _EditSubscriptionPageState();
}

class _EditSubscriptionPageState extends State<EditSubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSubscriptionPageController(widget.storeId),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: 'Assinatura TotemPRO',
              actions: [],
            ),
            const SizedBox(height: 24),
            Consumer<EditSubscriptionPageController>(
              builder: (_, controller, __) {
                return AppPageStatusBuilder<List<AvailablePlan>>(
                  status: controller.status,
                  successBuilder: (plans) {
                    Widget buildCell(String text,
                        {double width = 150, bool highlight = false}) {
                      return Container(
                        width: width,
                        height: 60,
                        color: highlight ? Colors.blue : Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          text,
                          style: TextStyle(
                            color: highlight ? Colors.white : Colors.black,
                            fontWeight: highlight
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Escolha o plano que melhor atende suas necessidades',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(24),
                          child: Material(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildCell('', width: 200),
                                      for (final p in plans)
                                        buildCell(p.plan.name, highlight: true)
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildCell('Limite de totens',
                                          width: 200, highlight: true),
                                      for (final p in plans)
                                        buildCell(
                                            p.plan.maxTotems?.toString() ??
                                                'Sem limite')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildCell('Design Personalizável',
                                          width: 200, highlight: true),
                                      for (final p in plans)
                                        buildCell(
                                            'Sim')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildCell('Valor',
                                          width: 200, highlight: true),
                                      for (final p in plans)
                                        buildCell(
                                            '${p.plan.price.toPrice()}/${p.plan.interval == 1 ? 'mês' : '${p.plan.interval} meses'}')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 200),
                                      for (final p in plans)
                                        Container(
                                          width: 150,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: p.isCurrent
                                              ? const AppPrimaryButton(
                                              label: 'Atual')
                                              : AppSecondaryButton(
                                            label: 'Assinar',
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (_) =>
                                                    NewSubscriptionDialog(
                                                      storeId: widget.storeId,
                                                      plan: p.plan,
                                                    ),
                                              );

                                              controller.reload();
                                            },
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
