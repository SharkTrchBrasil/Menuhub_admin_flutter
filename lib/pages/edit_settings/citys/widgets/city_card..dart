import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../models/store/store_city.dart';
import '../../../../models/store/store_neig.dart';

class CityCard extends StatelessWidget {
  // ✅ 1. CONSTRUTOR SIMPLIFICADO
  // Removemos todos os callbacks complexos. Agora só precisamos de onEdit e onDelete.
  final StoreCity city;
  final List<StoreNeighborhood> neighborhoods;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CityCard({
    super.key,
    required this.city,
    required this.neighborhoods,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      // ✅ 2. CARD INTEIRO CLICÁVEL
      // Envolvemos o conteúdo em um InkWell para que o usuário possa tocar
      // em qualquer lugar do card para iniciar a edição.
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCityHeader(context),
              const SizedBox(height: 20),
              _buildNeighborhoodsList(context),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 3. CABEÇALHO SIMPLIFICADO
  // Removemos o botão de "Adicionar Bairro". O menu de ações agora tem menos opções.
  Widget _buildCityHeader(BuildContext context) {
    return Row(
      children: [
        // Indicador de status + Nome da cidade
        Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: city.isActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  city.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Menu de ações da cidade (Editar/Excluir)
        _buildCityActionsMenu(context),
      ],
    );
  }

  // ✅ 4. MENU DE AÇÕES SIMPLIFICADO
  Widget _buildCityActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              const Text('Editar Cidade e Bairros'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Excluir Cidade', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ 5. LISTA DE BAIRROS SOMENTE EXIBIÇÃO
  // Os bairros agora são apenas informativos. Removemos todos os menus de ação deles.
  Widget _buildNeighborhoodsList(BuildContext context) {
    if (neighborhoods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.explore_off_outlined, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Nenhum bairro cadastrado para esta cidade.'.tr(),
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bairros Atendidos'.tr().toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Usamos Wrap para que os bairros possam quebrar a linha se forem muitos
        Wrap(
          spacing: 8.0, // Espaço horizontal entre os chips
          runSpacing: 8.0, // Espaço vertical entre as linhas de chips
          children: neighborhoods.map((neighborhood) => Chip(
            avatar: CircleAvatar(
              backgroundColor: neighborhood.isActive ? Colors.green.shade100 : Colors.grey.shade200,
              child: Icon(
                neighborhood.isActive ? Icons.check_circle : Icons.pause_circle_filled,
                size: 16,
                color: neighborhood.isActive ? Colors.green.shade800 : Colors.grey.shade500,
              ),
            ),
            label: Text(
              neighborhood.name,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800),
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          )).toList(),
        ),
      ],
    );
  }
}