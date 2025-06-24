import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';
import 'package:collection/collection.dart'; // Import para firstWhereOrNull

import '../../core/app_list_controller.dart';
import '../../core/di.dart';

import '../../models/page_status.dart';
import '../../models/store_city.dart';
import '../../models/store_neig.dart';
import '../../repositories/store_repository.dart';
import '../base/BasePage.dart';
import '../../services/dialog_service.dart'; // Certifique-se de que este serviço pode lidar com confirmações de exclusão

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

  AppListController<StoreNeighborhood>? _neighborhoodsController;

  StoreCity? _selectedCity;

  bool _isLoadingInitialData = true;
  bool _isLoadingCities = false;
  bool _isLoadingNeighborhoods = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    citiesController.addListener(_onCitiesChange);
  }

  @override
  void dispose() {
    citiesController.removeListener(_onCitiesChange);
    _neighborhoodsController?.removeListener(_onNeighborhoodsChange);
    citiesController.dispose();
    _neighborhoodsController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Locais de entrega'.tr()),
      mobileBuilder: (BuildContext context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildMobileLayout();
      },
      desktopBuilder: (BuildContext context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildDesktopLayout(context);
      },
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () => _showAddCityDialog(),
          tooltip: 'Nova cidade'.tr(),
          elevation: 0,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final cities = citiesController.items;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: Column(
        children: [
          ListTile(
            title: Text('Cidades'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCityDialog(),
            ),
          ),
          if (_isLoadingCities) const LinearProgressIndicator(),
          Expanded(
            child: cities.isEmpty && !_isLoadingInitialData
                ? Center(child: Text('Nenhuma cidade encontrada.'.tr()))
                : ListView.builder(
              itemCount: cities.length,
              itemBuilder: (_, index) {
                final city = cities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    key: ValueKey(city.id),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                        _onCitySelected(city);
                      }
                    },
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Novo bairro'.tr(), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        onTap: () => _showAddNeighborhoodDialog(city.id!),
                      ),
                      if (_selectedCity?.id == city.id && _isLoadingNeighborhoods)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator.adaptive(),
                        )),
                      if (_selectedCity?.id == city.id && _neighborhoodsController != null)
                        AnimatedBuilder(
                          animation: _neighborhoodsController!,
                          builder: (context, _) {
                            final neighborhoods = _neighborhoodsController!.items;
                            if (neighborhoods.isEmpty && !_isLoadingNeighborhoods) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Nenhum bairro encontrado para esta cidade.'.tr()),
                              );
                            }
                            return Column(
                              children: neighborhoods.map((neighborhood) {
                                return ListTile(
                                  title: Text(neighborhood.name),
                                  // --- MENU DE 3 PONTOS PARA BAIRROS (MOBILE) ---
                                  trailing: _buildNeighborhoodActionsMenu(city.id!, neighborhood),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      // --- MENU DE 3 PONTOS PARA CIDADES (MOBILE) ---
                      _buildCityActionsMenu(city),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final cities = citiesController.items;

    return Row(
      children: [
        /// CIDADES
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    title: Text('Cidades'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddCityDialog(),
                    ),
                  ),
                  if (_isLoadingCities) const LinearProgressIndicator(),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: citiesController,
                      builder: (_, __) {
                        if (cities.isEmpty && !_isLoadingInitialData) {
                          return Center(child: Text('Nenhuma cidade encontrada.'.tr()));
                        }
                        if (cities.isNotEmpty && _selectedCity == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _onCitySelected(cities.first);
                          });
                        } else if (_selectedCity != null && !cities.any((c) => c.id == _selectedCity!.id)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _selectedCity = cities.isNotEmpty ? cities.first : null;
                              if (_selectedCity != null) {
                                _onCitySelected(_selectedCity!);
                              } else {
                                _disposeNeighborhoodsController();
                              }
                            }
                          });
                        }

                        return ListView.builder(
                          itemCount: cities.length,
                          itemBuilder: (_, index) {
                            final city = cities[index];
                            return ListTile(
                              title: Text(city.name),
                              selected: _selectedCity?.id == city.id,
                              onTap: () => _onCitySelected(city),
                              // --- MENU DE 3 PONTOS PARA CIDADES (DESKTOP) ---
                              trailing: _buildCityActionsMenu(city),
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
        ),

        /// BAIRROS
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      _selectedCity != null
                          ? 'Bairros de ${_selectedCity!.name}'.tr()
                          : 'Selecione uma cidade'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: _selectedCity != null
                        ? IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddNeighborhoodDialog(_selectedCity!.id!),
                    )
                        : null,
                  ),
                  if (_isLoadingNeighborhoods) const LinearProgressIndicator(),
                  Expanded(
                    child: _selectedCity == null
                        ? Center(child: Text('Nenhuma cidade selecionada.'.tr()))
                        : _neighborhoodsController == null
                        ? Center(child: Text('Carregando bairros...'.tr()))
                        : AnimatedBuilder(
                      animation: _neighborhoodsController!,
                      builder: (context, _) {
                        final neighborhoods = _neighborhoodsController!.items;
                        if (neighborhoods.isEmpty && !_isLoadingNeighborhoods) {
                          return Center(child: Text('Nenhum bairro encontrado para esta cidade.'.tr()));
                        }
                        return ListView.builder(
                          itemCount: neighborhoods.length,
                          itemBuilder: (context, index) {
                            final neighborhood = neighborhoods[index];
                            return ListTile(
                              title: Text(neighborhood.name),
                              // --- MENU DE 3 PONTOS PARA BAIRROS (DESKTOP) ---
                              trailing: _buildNeighborhoodActionsMenu(_selectedCity!.id!, neighborhood),
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
        ),
      ],
    );
  }

  // --- Funções para Construir os Pop-up Menus ---

  Widget _buildCityActionsMenu(StoreCity city) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          _showAddCityDialog(cityId: city.id);
        } else if (value == 'delete') {
          _deleteCity(city);
        } else if (value == 'toggle_active') {
          _toggleCityActiveStatus(city);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('Editar'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Excluir'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'toggle_active',
          child: Text(city.isActive ? 'Desativar'.tr() : 'Ativar'.tr()),
        ),
      ],
    );
  }

  Widget _buildNeighborhoodActionsMenu(int cityId, StoreNeighborhood neighborhood) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          _showAddNeighborhoodDialog(cityId, neighborhoodId: neighborhood.id);
        } else if (value == 'delete') {
          _deleteNeighborhood(cityId, neighborhood);
        } else if (value == 'toggle_active') {
          _toggleNeighborhoodActiveStatus(cityId, neighborhood);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('Editar'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Excluir'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'toggle_active',
          child: Text(neighborhood.isActive ? 'Desativar'.tr() : 'Ativar'.tr()),
        ),
      ],
    );
  }



  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingInitialData = true);
    try {
      await citiesController.refresh(); // Carrega cidades na inicialização
      if (citiesController.items.isNotEmpty) {
        _onCitySelected(citiesController.items.first);
      } else {
        _selectedCity = null;
        _disposeNeighborhoodsController();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados iniciais: ${e.toString()}'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }
  void _disposeNeighborhoodsController() {
    _neighborhoodsController?.removeListener(_onNeighborhoodsChange);
    _neighborhoodsController?.dispose();
    _neighborhoodsController = null;
  }
  void _onCitiesChange() {
    if (!mounted) return;
    if (_selectedCity != null &&
        !citiesController.items.any((c) => c.id == _selectedCity!.id)) {
      _selectedCity = citiesController.items.isNotEmpty
          ? citiesController.items.first
          : null;
      if (_selectedCity != null) {
        _onCitySelected(_selectedCity!);
      } else {
        _disposeNeighborhoodsController();
      }
    }
    setState(() {});
  }
  void _onNeighborhoodsChange() {
    if (mounted) {
      setState(() {});
    }
  }
  void _onCitySelected(StoreCity city) {
    if (!mounted) return;


    if (_selectedCity?.id == city.id && _neighborhoodsController != null &&
        (_neighborhoodsController!.status is PageStatusSuccess || _isLoadingNeighborhoods)) {

      return;
    }


    setState(() {
      _selectedCity = city;
      _disposeNeighborhoodsController(); // Limpa e dispõe o controller antigo


      _neighborhoodsController = AppListController<StoreNeighborhood>(
        fetch: () => getIt<StoreRepository>().getNeighborhoods(city.id!),
      );
      _neighborhoodsController!.addListener(_onNeighborhoodsChange);

      _refreshNeighborhoods();
    });
  }
  void _addOrUpdateCityLocally(StoreCity newCity) {
    final index = citiesController.items.indexWhere((c) => c.id == newCity.id);
    if (index != -1) {
      citiesController.items[index] = newCity;
    } else {
      citiesController.items.add(newCity);
      citiesController.items.sort((a, b) => a.name.compareTo(b.name));
    }
    citiesController.updateLocally(); // ESSENCIAL: Notifica a UI
  }
  void _addOrUpdateNeighborhoodLocally(StoreNeighborhood newNeighborhood) {
    if (_neighborhoodsController == null) {
      print('Erro: Nenhuma cidade selecionada para adicionar/editar bairro.');
      return;
    }
    final index = _neighborhoodsController!.items.indexWhere((n) => n.id == newNeighborhood.id);
    if (index != -1) {
      _neighborhoodsController!.items[index] = newNeighborhood;
    } else {
      _neighborhoodsController!.items.add(newNeighborhood);
      _neighborhoodsController!.items.sort((a, b) => a.name.compareTo(b.name));
    }
    _neighborhoodsController!.updateLocally(); // ESSENCIAL: Notifica a UI
  }
  Future<void> _handleCitySaved(dynamic city) async {
    if (!mounted) return;
    setState(() => _isLoadingCities = true);
    try {
      if (city is StoreCity) {
        _addOrUpdateCityLocally(city); // Atualiza localmente e notifica `citiesController`

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // SE VOCÊ QUISER QUE A CIDADE RECÉM-CRIADA/EDITADA SEJA SELECIONADA AUTOMATICAMENTE:
          final newlyCreatedOrEditedCity = citiesController.items.firstWhereOrNull(
                (c) => c.id == city.id,
          );
          if (newlyCreatedOrEditedCity != null) {
            _onCitySelected(newlyCreatedOrEditedCity);
          } else if (citiesController.items.isNotEmpty) {
            _onCitySelected(citiesController.items.first);
          } else {
            setState(() {
              _selectedCity = null;
            });
            _disposeNeighborhoodsController();
          }
          if (mounted) setState(() => _isLoadingCities = false); // Mova para dentro do callback
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar cidade: ${e.toString()}'.tr())),
        );
      }
      if (mounted) setState(() => _isLoadingCities = false); // Aqui também
    }
    // Remove o finally
  }
  Future<void> _handleNeighborhoodSaved(dynamic neighborhood) async {
    if (!mounted) return;
    setState(() => _isLoadingNeighborhoods = true);
    try {
      if (neighborhood is StoreNeighborhood) {
        _addOrUpdateNeighborhoodLocally(neighborhood); // Atualiza localmente e notifica `_neighborhoodsController`
        // REMOVA A LINHA ABAIXO:
        // await _refreshNeighborhoods(); // <-- REMOVER ESTA LINHA
        // A chamada `_addOrUpdateNeighborhoodLocally` já usa `_neighborhoodsController!.updateLocally()`,
        // que notifica o AnimatedBuilder. Não precisa recarregar do backend aqui.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar bairro: ${e.toString()}'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNeighborhoods = false);
      }
    }
  }
  Future<void> _deleteCity(StoreCity city) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content: 'Tem certeza que deseja excluir a cidade "${city.name}" e todos os seus bairros associados?'.tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoadingCities = true);
      try {
        await getIt<StoreRepository>().deleteCity(widget.storeId, city.id!);
        citiesController.removeLocally((c) => c.id == city.id); // Remove localmente e notifica.

        // As operações que alteram o estado e podem causar relayout
        // devem ser agendadas para o próximo frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return; // Garante que o widget ainda está montado

          // Se a cidade excluída era a selecionada, precisamos ajustar a seleção.
          if (_selectedCity?.id == city.id) {
            final newSelectedCity = citiesController.items.isNotEmpty
                ? citiesController.items.first
                : null;

            if (newSelectedCity != null) {
              _onCitySelected(newSelectedCity);
            } else {
              setState(() {
                _selectedCity = null;
              });
              _disposeNeighborhoodsController();
            }
          } else {
            // Se a cidade excluída NÃO era a selecionada, mas ainda há uma cidade selecionada,
            // garantimos que o controller de bairros da cidade *atual* seja revalidado/recarregado.
            if (_selectedCity != null) {
              _onCitySelected(_selectedCity!);
            }
          }

          // O setState final para _isLoadingCities deve ser feito no mesmo callback
          // ou após as operações que causam o layout.
          if (mounted) setState(() => _isLoadingCities = false); // Mova para dentro do callback
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cidade "${city.name}" excluída com sucesso.'.tr())),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir cidade: ${e.toString()}'.tr())),
          );
        }
        // O setState para isLoadingCities = false também deve ser feito aqui em caso de erro
        if (mounted) setState(() => _isLoadingCities = false);
      }
      // Remove o finally pois o setState final foi movido para dentro do callback ou do catch
      // finally {
      //   if (mounted) {
      //     setState(() => _isLoadingCities = false);
      //   }
      // }
    }
  }
  Future<void> _toggleCityActiveStatus(StoreCity city) async {
    if (!mounted) return;
    setState(() => _isLoadingCities = true);
    try {
      final updatedCity = city.copyWith(isActive: !city.isActive); // Alterna o status
      await getIt<StoreRepository>().saveCity(widget.storeId, updatedCity);
      _addOrUpdateCityLocally(updatedCity); // Atualiza o status localmente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status da cidade "${city.name}" atualizado para ${updatedCity.isActive ? "Ativa" : "Inativa"}'.tr())),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status da cidade: ${e.toString()}'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }
  Future<void> _deleteNeighborhood(int cityId, StoreNeighborhood neighborhood) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content: 'Tem certeza que deseja excluir o bairro "${neighborhood.name}"?'.tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoadingNeighborhoods = true);
      try {
        await getIt<StoreRepository>().deleteNeighborhood(cityId, neighborhood.id!);
        _neighborhoodsController?.removeLocally((n) => n.id == neighborhood.id); // Remove localmente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bairro "${neighborhood.name}" excluído com sucesso.'.tr())),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir bairro: ${e.toString()}'.tr())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingNeighborhoods = false);
        }
      }
    }
  }
  Future<void> _toggleNeighborhoodActiveStatus(int cityId, StoreNeighborhood neighborhood) async {
    if (!mounted) return;
    setState(() => _isLoadingNeighborhoods = true);
    try {
      final updatedNeighborhood = neighborhood.copyWith(isActive: !neighborhood.isActive); // Alterna o status
      await getIt<StoreRepository>().saveNeighborhood(cityId, updatedNeighborhood);
      _addOrUpdateNeighborhoodLocally(updatedNeighborhood); // Atualiza o status localmente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status do bairro "${neighborhood.name}" atualizado para ${updatedNeighborhood.isActive ? "Ativo" : "Inativo"}'.tr())),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status do bairro: ${e.toString()}'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNeighborhoods = false);
      }
    }
  }
  Future<void> _showAddCityDialog({int? cityId}) async {
    await DialogService.showCityDialog(
      context,
      storeId: widget.storeId,
      cityId: cityId,
      onSaved: _handleCitySaved,
    );
  }
  Future<void> _refreshNeighborhoods() async {
    if (!mounted || _neighborhoodsController == null) {
      return;
    }

    setState(() => _isLoadingNeighborhoods = true);
    try {
      await _neighborhoodsController!.refresh(); // Este é o ponto onde o notifyListeners é chamado internamente
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao recarregar bairros: ${e.toString()}'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNeighborhoods = false);
      }
    }
  }
  Future<void> _showAddNeighborhoodDialog(int cityId, {int? neighborhoodId}) async {
    if (_selectedCity?.id != cityId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecione uma cidade para adicionar/editar bairros.'.tr())),
        );
      }
      return;
    }

    await DialogService.showNeighborhoodDialog(
      context,
      cityId: cityId,
      neighborhoodId: neighborhoodId,
      onSaved: _handleNeighborhoodSaved,
    );
  }




}