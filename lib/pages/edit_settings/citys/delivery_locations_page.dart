import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store_city.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/add_edit_city_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/city_card..dart';

import 'package:totem_pro_admin/pages/edit_settings/citys/widgets/locations_filter_bar.dart'; // ✅ Importado
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../../../core/di.dart';
import '../../../core/helpers/sidepanel.dart';
import '../../../repositories/store_repository.dart';
import '../../../services/dialog_service.dart';
import '../../product_groups/helper/side_panel_helper.dart';


class CityNeighborhoodPage extends StatefulWidget {
  const CityNeighborhoodPage({super.key, required this.storeId, required this.isInWizard});
  final int storeId;
  final bool isInWizard;

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

  void _showCityEditorPanel({StoreCity? city}) {
    StoreCity? cityToEdit;

    if (city?.id != null) {
      cityToEdit = context.read<StoresManagerCubit>().getCityFromState(city!.id!);
      if (cityToEdit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar dados da cidade.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    showResponsiveSidePanel(
      context,
      AddEditCityPage(
        storeId: widget.storeId,
        initialCity: cityToEdit,
      ),
    );
  }

  void _deleteCity(StoreCity city) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      content: 'Deseja excluir a cidade "${city.name}" e todos os seus bairros?',
    );
    if (confirmed == true && mounted) {
      await getIt<StoreRepository>().deleteCity(widget.storeId, city.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cidade "${city.name}" excluída com sucesso.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. ADICIONADO SCAFFOLD PARA SUPORTAR O FAB
    return Scaffold(
      body: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return const Center(child: DotLoading());
          }

          final allCities = state.activeStore?.relations.cities ?? [];

          if (allCities.isEmpty && _searchText.isEmpty) {
            return _buildEmptyState();
          }

          return _buildLoadedState(allCities);
        },
      ),

    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_city_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Nenhum local de entrega cadastrado', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          DsButton(
            label: 'Cadastrar cidade',
            onPressed: _showCityEditorPanel,
          )
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<StoreCity> allCities) {
    final visibleCities = _searchText.isEmpty
        ? allCities
        : allCities.where((c) =>
    c.name.toLowerCase().contains(_searchText) ||
        c.neighborhoods.any((n) => n.name.toLowerCase().contains(_searchText))
    ).toList();

    return CustomScrollView(
      slivers: [

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: FixedHeader(
                showActionsOnMobile: true,
                title: 'Locais de Entrega',
                subtitle: 'Gerencie as cidades e bairros onde sua loja realiza entregas.',
                // O botão aqui é um atalho útil em telas maiores, podemos mantê-lo.
                actions: [
                  DsButton(
                    label: 'Cadastrar cidade',
                    style: DsButtonStyle.secondary,
                    onPressed: _showCityEditorPanel,
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
        if (visibleCities.isEmpty && _searchText.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              alignment: Alignment.center,
              child: Text('Nenhum local encontrado para "$_searchText"', style: Theme.of(context).textTheme.titleMedium),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 88), // Espaço extra no final para o FAB não cobrir
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final city = visibleCities[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CityCard(
                      city: city,
                      neighborhoods: city.neighborhoods,
                      onEdit: () => _showCityEditorPanel(city: city),
                      onDelete: () => _deleteCity(city),
                    ),
                  );
                },
                childCount: visibleCities.length,
              ),
            ),
          ),
      ],
    );
  }
}