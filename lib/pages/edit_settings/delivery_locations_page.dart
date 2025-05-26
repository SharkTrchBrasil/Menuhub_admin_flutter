import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/edit_settings/widgets/add_city_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/widgets/add_neig_dialog.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/store_city.dart';
import '../../models/store_neig.dart';
import '../../repositories/store_repository.dart';
import '../base/BasePage.dart';

class CityNeighborhoodPage extends StatefulWidget {
  const CityNeighborhoodPage({super.key, required this.storeId});
final int storeId;
  @override
  State<CityNeighborhoodPage> createState() => _CityNeighborhoodPageState();
}

class _CityNeighborhoodPageState extends State<CityNeighborhoodPage> {
  late final AppListController<StoreCity> citiesController = AppListController<StoreCity>(
    fetch: () => getIt<StoreRepository>().getCities(widget.storeId),
  );

  AppListController<StoreNeighborhood>? neighborhoodsController;

  StoreCity? selectedCity;



  void _onCitySelected(StoreCity city) {
    setState(() {
      selectedCity = city;
      neighborhoodsController = AppListController<StoreNeighborhood>(
        fetch: () => getIt<StoreRepository>().getNeighborhoods(city.id!),
      );
      neighborhoodsController!.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Locais de entrega'),

        mobileBuilder: (BuildContext context) {
          return Column(
            children: [
              ListTile(
                title: const Text('Cidades', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddCityDialog(
                        storeId: widget.storeId,
                        onSaved: (_) => citiesController.refresh(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: citiesController,
                  builder: (_, __) {
                    final items = citiesController.items;

                    if (items.isNotEmpty && selectedCity == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _onCitySelected(items.first);
                      });
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final city = items[index];
                        return ListTile(
                          title: Text(city.name),
                          selected: selectedCity?.id == city.id,
                          onTap: () {
                            _onCitySelected(city); // Carrega os bairros da cidade
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(title: Text('Bairros de ${city.name}')),
                                  body: Column(
                                    children: [
                                      ListTile(
                                        title: const Text('Bairros', style: TextStyle(fontWeight: FontWeight.bold)),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => addNeighborhood(city.id!),
                                        ),
                                      ),
                                      Expanded(
                                        child: AnimatedBuilder(
                                          animation: neighborhoodsController!,
                                          builder: (context, _) {
                                            final neighborhoods = neighborhoodsController!.items;
                                            if (neighborhoods.isEmpty) {
                                              return const Center(child: Text('Nenhum bairro encontrado'));
                                            }
                                            return ListView.builder(
                                              itemCount: neighborhoods.length,
                                              itemBuilder: (context, index) {
                                                final neighborhood = neighborhoods[index];
                                                return ListTile(
                                                  title: Text(neighborhood.name),
                                                  trailing: IconButton(
                                                    icon: const Icon(Icons.edit),
                                                    onPressed: () {
                                                      addNeighborhood(city.id!, neighborhoodId: neighborhood.id);
                                                    },
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => addCity(cityId: city.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },


        desktopBuilder: (BuildContext context) {
        return Row(
          children: [
            /// CIDADES
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Cidades', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddCityDialog(
                            storeId: widget.storeId,
                            onSaved: (category) {
                              citiesController.refresh();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: citiesController,
                      builder: (_, __) {
                        final items = citiesController.items;

                        if (items.isNotEmpty && selectedCity == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _onCitySelected(items.first);
                            }
                          });
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final city = items[index];
                            return ListTile(
                              title: Text(city.name),
                              selected: selectedCity?.id == city.id,
                              onTap: () => _onCitySelected(city),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      addCity(cityId: city.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(),

            /// BAIRROS
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      selectedCity != null
                          ? 'Bairros de ${selectedCity!.name}'
                          : 'Selecione uma cidade',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: selectedCity != null
                        ? IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        addNeighborhood(  selectedCity!.id!);
                      },
                    )
                        : null,
                  ),
                  Expanded(
                    child: neighborhoodsController == null
                        ? const Center(child: Text('Nenhuma cidade selecionada'))
                        : AnimatedBuilder(
                      animation: neighborhoodsController!,
                      builder: (context, _) {
                        final neighborhoods = neighborhoodsController!.items;
                        if (neighborhoods.isEmpty) {
                          return const Center(child: Text('Nenhum bairro encontrado'));
                        }
                        return ListView.builder(
                          itemCount: neighborhoods.length,
                          itemBuilder: (context, index) {
                            final neighborhood = neighborhoods[index];
                            return ListTile(
                              title: Text(neighborhood.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      addNeighborhood(selectedCity!.id!, neighborhoodId: neighborhood.id);
                                    },
                                  ),
                                ],
                              ),
                              // demais widgets para bairro...
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },


    );
  }
  Future<void> addCity({cityId}) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddCityDialog(storeId: widget.storeId, id: cityId,),
    );
    if(result != null && result && mounted) {
      citiesController.refresh();
    }
  }

  Future<void> addNeighborhood(int cityId, {int? neighborhoodId}) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddNeighborhoodDialog(
        id: neighborhoodId, // pode ser null para novo bairro
        cityId: cityId,
      ),
    );
    if (result != null && result && mounted) {
      neighborhoodsController!.refresh();
    }
  }


}
