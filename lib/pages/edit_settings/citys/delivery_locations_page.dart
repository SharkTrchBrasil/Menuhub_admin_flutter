import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/city_card..dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/locations_filter_bar.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../../core/di.dart';
import '../../../models/store_city.dart';
import '../../../models/store_neig.dart';
import '../../../repositories/store_repository.dart';
import '../../../widgets/dot_loading.dart';
import '../../base/BasePage.dart';
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
    return BasePage(

      mobileAppBar: AppBarCustom(title: 'Locais de entrega'.tr()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCityDialog,
        tooltip: 'Nova cidade'.tr(),
        child: const Icon(Icons.add),
      ),
      desktopBuilder: _buildContent,
      mobileBuilder: _buildContent,
    );
  }


  Widget _buildContent(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: DotLoading());
        }

        // --- INÍCIO DA NOVA LÓGICA DE FILTRO ---

        // PASSO 1: Pegar os dados completos do Cubit.
        final allCities = state.activeStore?.relations.cities ?? [];
        // Assumindo que o Store tem uma lista separada de todos os bairros.
        final allNeighborhoods = state.activeStore?.relations.neighborhoods ?? [];

        // PASSO 2: Filtrar os "itens" (bairros) pelo texto da busca.
        final searchedNeighborhoods = _searchText.isEmpty
            ? allNeighborhoods
            : allNeighborhoods
            .where((n) => n.name.toLowerCase().contains(_searchText))
            .toList();

        // PASSO 3: Descobrir a quais "grupos" (cidades) os itens filtrados pertencem.
        final visibleCityIds = searchedNeighborhoods.map((n) => n.cityId).toSet();

        // PASSO 4: Filtrar os "grupos" (cidades) para exibir.
        final visibleCities = _searchText.isEmpty
            ? allCities // Se a busca está vazia, mostra todas as cidades.
            : allCities.where((c) => visibleCityIds.contains(c.id)).toList();

        // --- FIM DA NOVA LÓGICA DE FILTRO ---

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: CustomScrollView(
              slivers: [
                // 1. Cabeçalho da Página (continua igual)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Locais de Entrega',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gerencie as cidades e bairros onde sua loja realiza entregas.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Barra de Filtro Fixa (continua igual)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverFilterBarDelegate(
                    child: LocationsFilterBar(searchController: _searchController),
                  ),
                ),

                // 3. Conteúdo da Lista (agora usa as listas filtradas)
                if (visibleCities.isEmpty)
                  SliverFillRemaining(
                    // ... seu widget de lista vazia com botão (continua igual)
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final city = visibleCities[index];
                          // Para cada cidade visível, pegamos apenas os bairros que passaram na busca.
                          final neighborhoodsForThisCity = searchedNeighborhoods
                              .where((n) => n.cityId == city.id)
                              .toList();

                          return CityCard(
                            storeId: widget.storeId,
                            city: city,
                            neighborhoods: neighborhoodsForThisCity, // Passa a lista já filtrada
                            onAddNeighborhood: _showAddNeighborhoodDialog,
                            onEditCity: (city) => _showAddCityDialog(cityId: city.id),
                            onDeleteCity: _deleteCity,
                            onToggleCityStatus: _toggleCityActiveStatus,
                            onEditNeighborhood: (cityId, neighborhood) {
                              _showAddNeighborhoodDialog(cityId, neighborhoodId: neighborhood.id);
                            },
                            onDeleteNeighborhood: _deleteNeighborhood,
                            onToggleNeighborhoodStatus: _toggleNeighborhoodActiveStatus,
                          );
                        },
                        childCount: visibleCities.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _performAction(Future<void> Function() action, String successMessage) async {
    try {
      await action();
      if (mounted) {
      //  await context.read<StoresManagerCubit>().reloadActiveStore();
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

  // CIDADES
  void _showAddCityDialog({int? cityId}) {
    DialogService.showCityDialog(
      context,
      storeId: widget.storeId,
      cityId: cityId,
      onSaved: (city) => _performAction(
            () async {}, // Ação já foi feita no dialog, aqui só recarregamos
        cityId == null ? 'Cidade criada com sucesso!' : 'Cidade atualizada com sucesso!',
      ),
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

  // BAIRROS
  void _showAddNeighborhoodDialog(int cityId, {int? neighborhoodId}) {
    DialogService.showNeighborhoodDialog(
      context,
      cityId: cityId,
      neighborhoodId: neighborhoodId,
      onSaved: (neighborhood) => _performAction(
            () async {}, // Ação já foi feita no dialog, aqui só recarregamos
        neighborhoodId == null ? 'Bairro criado com sucesso!' : 'Bairro atualizado com sucesso!',
      ),
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