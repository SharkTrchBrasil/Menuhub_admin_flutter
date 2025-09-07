import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../widgets/ds_primary_button.dart';


class EmptyCategoryCardContent extends StatelessWidget {
  final VoidCallback onAddItem;

  const EmptyCategoryCardContent({
    super.key,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),

        child: Column(
          children: [

            SvgPicture.asset(
              "assets/icons/chef.svg",
              height: 80,
              width: 80,),

            const SizedBox(height: 16),
            const Text(
              'Nenhum item nessa categoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Essa categoria não está sendo exibida no momento',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            DsButton(
              style: DsButtonStyle.secondary,
              label: 'Adicionar item',
              onPressed:onAddItem,
            )

          ],
        ),
      ),
    );
  }
}