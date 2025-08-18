// lib/pages/edit_settings/widgets/city_card.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_city.dart';
import 'package:totem_pro_admin/models/store_neig.dart';

class CityCard extends StatelessWidget {
  final int storeId;
  final StoreCity city;
  final List<StoreNeighborhood> neighborhoods; // Recebe a lista já filtrada
  final Function(int cityId, {int? neighborhoodId}) onAddNeighborhood;
  final Function(StoreCity city) onEditCity;
  final Function(StoreCity city) onDeleteCity;
  final Function(StoreCity city) onToggleCityStatus;
  final Function(int cityId, StoreNeighborhood neighborhood) onEditNeighborhood;
  final Function(int cityId, StoreNeighborhood neighborhood) onDeleteNeighborhood;
  final Function(int cityId, StoreNeighborhood neighborhood) onToggleNeighborhoodStatus;

  const CityCard({
    super.key,
    required this.storeId,
    required this.city,
    required this.neighborhoods,
    required this.onAddNeighborhood,
    required this.onEditCity,
    required this.onDeleteCity,
    required this.onToggleCityStatus,
    required this.onEditNeighborhood,
    required this.onDeleteNeighborhood,
    required this.onToggleNeighborhoodStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da Cidade
            Row(
              children: [
                Expanded(
                  child: Text(
                    city.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Bairro'),
                  onPressed: () => onAddNeighborhood(city.id!),
                ),
                _buildCityActionsMenu(context),
              ],
            ),
            const Divider(height: 24),

            // Lista de Bairros
            if (neighborhoods.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Nenhum bairro encontrado para esta cidade.'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...neighborhoods.map((neighborhood) => ListTile(
                title: Text(neighborhood.name),
                trailing: _buildNeighborhoodActionsMenu(context, neighborhood),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildCityActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') onEditCity(city);
        if (value == 'delete') onDeleteCity(city);
        if (value == 'toggle_active') onToggleCityStatus(city);
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text('Editar Cidade'.tr())),
        PopupMenuItem(value: 'delete', child: Text('Excluir Cidade'.tr())),
        PopupMenuItem(value: 'toggle_active', child: Text(city.isActive ? 'Desativar'.tr() : 'Ativar'.tr())),
      ],
    );
  }

  Widget _buildNeighborhoodActionsMenu(BuildContext context, StoreNeighborhood neighborhood) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') onEditNeighborhood(city.id!, neighborhood);
        if (value == 'delete') onDeleteNeighborhood(city.id!, neighborhood);
        if (value == 'toggle_active') onToggleNeighborhoodStatus(city.id!, neighborhood);
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text('Editar Bairro'.tr())),
        PopupMenuItem(value: 'delete', child: Text('Excluir Bairro'.tr())),
        PopupMenuItem(value: 'toggle_active', child: Text(neighborhood.isActive ? 'Desativar'.tr() : 'Ativar'.tr())),
      ],
    );
  }
}