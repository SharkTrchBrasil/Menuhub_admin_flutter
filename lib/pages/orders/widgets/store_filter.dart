
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/store_with_role.dart';

class StoreFilterSection extends StatelessWidget {
  final List<StoreWithRole> stores;
  final Set<int> selectedStoreIds;
  final void Function(int storeId, bool selected) onToggleStore;

  const StoreFilterSection({
    super.key,
    required this.stores,
    required this.selectedStoreIds,
    required this.onToggleStore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exibir pedidos das lojas:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...stores.map((store) {
          final storeId = store.store.core.id;
          final isSelected = selectedStoreIds.contains(storeId);

          return SwitchListTile(
            value: isSelected,
            title: Text(store.store.core.name),
            secondary: CircleAvatar(
              radius: 12,
              backgroundImage: (store.store.media!.image?.url != null && store.store.media!.image!.url!.isNotEmpty)
                  ? NetworkImage(store.store.media!.image!.url!)
                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
            ),
            onChanged: (bool selected) {
              onToggleStore(storeId!, selected);
            },
          );
        }).toList(),
      ],
    );
  }
}
