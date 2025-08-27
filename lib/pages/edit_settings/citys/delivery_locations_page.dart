// lib/pages/edit_settings/citys/delivery_locations_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/scaffold_ui_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/city_card..dart';

import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/locations_filter_bar.dart';
import 'package:totem_pro_admin/widgets/appbarcode.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../../../core/di.dart';
import '../../../models/store_city.dart';
import '../../../models/store_neig.dart';
import '../../../repositories/store_repository.dart';
import '../../../services/dialog_service.dart';
import '../../../widgets/mobileappbar.dart';

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

    // ✅ PASSO 1: Informar ao AppShell qual AppBar e FAB usar
    // Usamos addPostFrameCallback para garantir que o Cubit esteja disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uiCubit = context.read<ScaffoldUiCubit>();
      uiCubit.setFab(
        FloatingActionButton(
          onPressed: _showAddCityDialog,
          tooltip: 'Nova cidade'.tr(),
          child: const Icon(Icons.add),
        ),
      );
      // O AppBarCode já está sendo adicionado pelo AppShell no desktop.
      // Para o mobile, podemos definir um aqui se quisermos um título específico.
      uiCubit.setAppBar(AppBarCustom(title: 'Locais de Entrega'.tr()));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // ✅ Limpa a configuração da UI ao sair da página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScaffoldUiCubit>().clearAll();
      }
    });
    super.dispose();
  }

  // ✅ PASSO 2: O método build agora retorna APENAS o conteúdo
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: DotLoading());
        }

        final allCities = state.activeStore?.relations.cities ?? [];
        final allNeighborhoods = allCities.expand((city) => city.neighborhoods).toList();

        final searchedNeighborhoods = _searchText.isEmpty
            ? allNeighborhoods
            : allNeighborhoods.where((n) => n.name.toLowerCase().contains(_searchText)).toList();

        final visibleCityIds = searchedNeighborhoods.map((n) => n.cityId).toSet();

        final visibleCities = _searchText.isEmpty
            ? allCities
            : allCities.where((c) => visibleCityIds.contains(c.id)).toList();

        // O conteúdo da página (a lista rolável) é retornado diretamente.
        // O Scaffold, AppBar e FAB são gerenciados pelo AppShell.
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FixedHeader(
                        title: 'Locais de Entrega',
                        subtitle: 'Gerencie as cidades e bairros onde sua loja realiza entregas.',
                        actions: [
                          DsButton(
                            label: 'Cadastrar cidade',
                            onPressed: _showAddCityDialog,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverFilterBarDelegate(
                  child: LocationsFilterBar(searchController: _searchController),
                ),
              ),
              if (visibleCities.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchText.isEmpty
                              ? 'Nenhum local de entrega cadastrado.'
                              : 'Nenhum local encontrado para "${_searchController.text}"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_searchText.isEmpty)
                          DsButton(
                            label: 'Cadastrar cidade',
                            onPressed: _showAddCityDialog,
                          )
                      ],
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