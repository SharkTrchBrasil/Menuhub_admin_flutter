import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/store_manager_cubit.dart'; // Mantenha se o pai usar
import '../../../models/store/store.dart';

class StoreHeader extends StatelessWidget {
  // NOVO: O widget agora recebe o objeto Store diretamente.
  final Store? store;

  // AJUSTADO: O construtor agora requer o 'store'.
  const StoreHeader({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    // REMOVIDO: A busca de dados foi removida daqui.
    // final Store? store = context.read<StoresManagerCubit>().getActiveStore()?.store;

    // Se a loja não for fornecida, mostra um placeholder.
    if (store == null) {
      return const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carregando...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      );
    }

    // Usa o objeto 'store' que foi passado pelo construtor.
    final String? imageUrl = store!.media!.image?.url;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : null,
          backgroundColor: Colors.grey[200],
          child: imageUrl == null || imageUrl.isEmpty
              ? const Icon(Icons.store, size: 22, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store!.core.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              store!.core.phone!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}