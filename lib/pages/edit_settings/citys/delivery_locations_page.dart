// lib/pages/edit_settings/citys/delivery_locations_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/city_card..dart';

import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/locations_filter_bar.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../../../core/di.dart';

import '../../../models/store/store_city.dart';
import '../../../models/store/store_neig.dart';
import '../../../repositories/store_repository.dart';
import '../../../services/dialog_service.dart';

class CityNeighborhoodPage extends StatefulWidget {
  const CityNeighborhoodPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<CityNeighborhoodPage> createState() => _CityNeighborhoodPageState();
}

class _CityNeighborhoodPageState extends State<CityNeighborhoodPage> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchText = _searchController.text.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: DotLoading());
        }

        final allCities = state.activeStore?.relations.cities ?? [];

        // ✅ ================== LÓGICA DE TELA INTELIGENTE ==================
        // Se a lista de cidades estiver completamente vazia, mostramos a UI simplificada.
        if (allCities.isEmpty) {
          return _buildEmptyState();
        }

        // Se houver cidades, construímos a UI completa com a lista e filtros.
        return _buildLoadedState(allCities);
        // ================== FIM DA LÓGICA ==================
      },
    );
  }

  // ✅ NOVO WIDGET: Constrói o estado de "lista vazia"
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_city_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum local de entrega cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comece cadastrando a primeira cidade onde sua loja fará entregas.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DsButton(
              label: 'Cadastrar primeira cidade',
              onPressed: _showAddCityDialog,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVO WIDGET: Constrói o estado quando a lista não está vazia
  Widget _buildLoadedState(List<StoreCity> allCities) {
    final allNeighborhoods = allCities.expand((city) => city.neighborhoods).toList();

    final searchedNeighborhoods = _searchText.isEmpty
        ? allNeighborhoods
        : allNeighborhoods.where((n) => n.name.toLowerCase().contains(_searchText)).toList();

    final visibleCityIds = searchedNeighborhoods.map((n) => n.cityId).toSet();

    final visibleCities = _searchText.isEmpty
        ? allCities
        : allCities.where((c) => visibleCityIds.contains(c.id)).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: CustomScrollView(
        slivers: [
          // Cabeçalho Principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FixedHeader(
                title: 'Locais de Entrega',
                subtitle: 'Gerencie as cidades e bairros onde sua loja realiza entregas.',
                actions: [
                  DsButton(
                    label: 'Cadastrar cidade',
                    onPressed: _showAddCityDialog,
                  )
                ],
              ),
            ),
          ),
          // Barra de Filtro Fixa
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverFilterBarDelegate(
              child: LocationsFilterBar(searchController: _searchController),
            ),
          ),
          // Conteúdo da Lista
          if (visibleCities.isEmpty && _searchText.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                alignment: Alignment.center,
                child: Text(
                  'Nenhum local encontrado para "${_searchController.text}"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final city = visibleCities[index];
                    final neighborhoodsForThisCity = (_searchText.isEmpty
                        ? city.neighborhoods
                        : searchedNeighborhoods.where((n) => n.cityId == city.id)).toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CityCard(
                        storeId: widget.storeId,
                        city: city,
                        neighborhoods: neighborhoodsForThisCity,
                        onAddNeighborhood: _showAddNeighborhoodDialog,
                        onEditCity: (city) => _showAddCityDialog(cityId: city.id),
                        onDeleteCity: _deleteCity,
                        onToggleCityStatus: _toggleCityActiveStatus,
                        onEditNeighborhood: (cityId, neighborhood) {
                          _showAddNeighborhoodDialog(cityId, neighborhoodId: neighborhood.id);
                        },
                        onDeleteNeighborhood: _deleteNeighborhood,
                        onToggleNeighborhoodStatus: _toggleNeighborhoodActiveStatus,
                      ),
                    );
                  },
                  childCount: visibleCities.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- MÉTODOS DE AÇÃO (sem alterações) ---

  Future<void> _performAction(Future<void> Function() action, String successMessage) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage.tr()), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'.tr()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddCityDialog({int? cityId}) {
    DialogService.showCityDialog(
      context,
      storeId: widget.storeId,
      cityId: cityId,
      onSaved: (city) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cityId == null ? 'Cidade criada com sucesso!' : 'Cidade atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // O cubit já escuta o evento de socket, então a recarga manual não é estritamente necessária aqui.
      },
    );
  }

  void _deleteCity(StoreCity city) async {
    final confirmed = await DialogService.showConfirmationDialog(context,
        title: 'Confirmar Exclusão', content: 'Deseja excluir a cidade "${city.name}" e todos os seus bairros?');
    if (confirmed == true) {
      await _performAction(
            () => getIt<StoreRepository>().deleteCity(widget.storeId, city.id!),
        'Cidade "${city.name}" excluída com sucesso.',
      );
    }
  }

  void _toggleCityActiveStatus(StoreCity city) {
    final updatedCity = city.copyWith(isActive: !city.isActive);
    _performAction(
          () => getIt<StoreRepository>().saveCity(widget.storeId, updatedCity),
      'Status da cidade "${city.name}" atualizado.',
    );
  }

  void _showAddNeighborhoodDialog(int cityId, {int? neighborhoodId}) {
    DialogService.showNeighborhoodDialog(
      context,
      cityId: cityId,
      neighborhoodId: neighborhoodId,
      onSaved: (neighborhood) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(neighborhoodId == null ? 'Bairro criado com sucesso!' : 'Bairro atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _deleteNeighborhood(int cityId, StoreNeighborhood neighborhood) async {
    final confirmed = await DialogService.showConfirmationDialog(context,
        title: 'Confirmar Exclusão', content: 'Deseja excluir o bairro "${neighborhood.name}"?');
    if (confirmed == true) {
      await _performAction(
            () => getIt<StoreRepository>().deleteNeighborhood(cityId, neighborhood.id!),
        'Bairro "${neighborhood.name}" excluído com sucesso.',
      );
    }
  }

  void _toggleNeighborhoodActiveStatus(int cityId, StoreNeighborhood neighborhood) {
    final updatedNeighborhood = neighborhood.copyWith(isActive: !neighborhood.isActive);
    _performAction(
          () => getIt<StoreRepository>().saveNeighborhood(cityId, updatedNeighborhood),
      'Status do bairro "${neighborhood.name}" atualizado.',
    );
  }
}