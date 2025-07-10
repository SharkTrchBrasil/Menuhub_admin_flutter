import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Mantido caso precise para o botão, como no CategoryProductPage
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/pages/variants/widgets/associate_product_dialg.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

import '../../ConstData/typography.dart'; // Mantido para estilos de texto
import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/variant.dart'; // Usamos Variant aqui
import '../../models/variant_option.dart';
import '../../repositories/product_repository.dart'; // O ProductRepository lida com Variants
import '../../widgets/fixed_header.dart'; // Para o layout desktop
import '../../widgets/mobileappbar.dart';
import '../../widgets/app_primary_button.dart'; // Se for usar um botão primário no desktop
import '../edit_variant/widgets/variant_option_list_item.dart'; // Para listar as opções

class VariantsPage extends StatefulWidget {
  final int storeId;

  const VariantsPage({super.key, required this.storeId});

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {




  late final AppListController<Variant> variantsController =
  AppListController<Variant>(
    fetch: () => getIt<ProductRepository>().getVariantsByStore(widget.storeId),
  );

  bool _isLoadingInitialData = true;
  bool _isLoadingVariants = false; // Indicador de carregamento para as variantes
  bool _isLoadingOptions = false; // Indicador para carregamento de opções (se fosse separado)

  Variant? _selectedVariant; // A variante selecionada no painel esquerdo (desktop)
  bool _showInactiveOptions = false; // Estado para o switch de opções inativas

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    variantsController.addListener(_onVariantsChange);
  }

  @override
  void dispose() {
    variantsController.removeListener(_onVariantsChange);
    variantsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingInitialData = true);
    try {
      await variantsController.refresh();
      if (variantsController.items.isNotEmpty && _selectedVariant == null) {
        // Seleciona a primeira variante se houver e nenhuma estiver selecionada
        _selectedVariant = variantsController.items.first;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar adicionais: ${e.toString()}'.tr(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }

  void _onVariantsChange() {
    // Garante que a variante selecionada ainda exista na lista após uma mudança
    if (_selectedVariant != null &&
        !variantsController.items.any((v) => v.id == _selectedVariant!.id)) {
      _selectedVariant = variantsController.items.isNotEmpty
          ? variantsController.items.first
          : null;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(
        title: 'Adicionais'.tr(),
        showLeadingButton: false,
      ),
      mobileBuilder: (context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return _buildMobileLayout();
      },
      desktopBuilder: (context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return Column(
          children: [
            FixedHeader(
              title: 'Gerenciamento de Adicionais'.tr(),
              actions: [

                // AppPrimaryButton(
                //   label: 'Adicionar Adicional'.tr(),
                //   onPressed: () {
                //     DialogService.showVariantsDialog(
                //       context,
                //       widget.storeId,
                //       onSaved: (_) => variantsController.refresh(), // Atualiza a lista após salvar
                //     );
                //   },
                // ),
              ],
            ),
            Expanded(
              child: _buildDesktopLayout(context),
            ),
          ],
        );
      },
      floatingActionButton:
      MediaQuery.of(context).size.width < 600 // Apenas para mobile
          ? Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showVariantsDialog(
              context,
              widget.storeId,
              onSaved: (_) => variantsController.refresh(),
            );
          },
          tooltip: 'Novo adicional'.tr(),
          elevation: 4,
          child: Icon(Icons.add,
              color: Theme.of(context).colorScheme.onPrimary),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      )
          : null,
    );
  }

  // --- LAYOUT MOBILE ---
  Widget _buildMobileLayout() {
    final variants = variantsController.items;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_isLoadingVariants) const LinearProgressIndicator(),
          if (variants.isEmpty && !_isLoadingInitialData && !_isLoadingVariants)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Nenhum adicional encontrado. Crie um para começar!'.tr()),
              ),
            ),
          ...variants.map((variant) {
            final options = variant.options ?? [];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ExpansionTile(
                key: ValueKey(variant.id),
                initiallyExpanded: _selectedVariant?.id == variant.id,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                title: Text(
                  variant.name,

                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Exibir inativos'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: _showInactiveOptions,
                          onChanged: (v) {
                            setState(() {
                              _showInactiveOptions = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (options.isEmpty && !_isLoadingOptions)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Nenhuma opção encontrada para este adicional.'.tr()),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: options.where((o) => _showInactiveOptions || o.available).map((option) {
                        return VariantOptionListItem(
                          option: option,
                          storeId: widget.storeId,
                          variantId: variant.id!,
                          onSaved: () => variantsController.refresh(),
                        );
                      }).toList(),
                    ),
                  _buildMobileActionRow(variant),
                ],
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    setState(() {
                      _selectedVariant = variant;
                    });
                  } else if (_selectedVariant?.id == variant.id) {
                    setState(() {
                      _selectedVariant = null;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMobileActionRow(Variant variant) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Nova opção'.tr(),
            color: Colors.blue,
            onTap: () {

              DialogService.showVariantsOptionsDialog(
                context,
                widget.storeId,
                variant.id!,
                onSaved: () => variantsController.refresh(),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.edit,
            label: 'Editar'.tr(),
            color: Colors.orange,
            onTap: () {
              DialogService.showVariantsDialog(
                context,
                variantId: variant.id,
                widget.storeId,
                onSaved: (_) => variantsController.refresh(),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.delete_forever,
            label: 'Excluir'.tr(),
            color: Colors.red,
            onTap: () => _deleteVariant(variant),
          ),
          _buildActionButton(
            icon: Icons.link,
            label: 'Associar Produtos'.tr(),
            color: Colors.purple,
            onTap: () {
              _showAssociateProductsDialog(variant);
            },
          ),

        ],
      ),
    );
  }

  void _showAssociateProductsDialog(Variant variant) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AssociateProductsDialog(
          storeId: widget.storeId,
          variantId: variant.id!,
          onSaved: () => variantsController.refresh(),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- LAYOUT DESKTOP (Mestre-Detalhe) ---
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        /// VARIANTS (Lado Esquerdo - Mestre)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Adicionais'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {

                        DialogService.showVariantsDialog(
                          context,
                          widget.storeId,
                          onSaved: (_) => variantsController.refresh(),
                        );


                      },
                    ),
                  ),
                  if (_isLoadingVariants) const LinearProgressIndicator(),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: variantsController,
                      builder: (_, __) {
                        final items = variantsController.items;

                        // Lógica para selecionar a primeira variante
                        if (_selectedVariant == null && items.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(() => _selectedVariant = items.first);
                          });
                        } else if (_selectedVariant != null &&
                            !items.any((v) => v.id == _selectedVariant!.id)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(
                                    () => _selectedVariant =
                                items.isNotEmpty ? items.first : null,
                              );
                          });
                        }

                        if (items.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Nenhum adicional encontrado.'.tr()),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final variant = items[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),

                              title: Text(
                                variant.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
                              ),
                              selected: _selectedVariant?.id == variant.id,
                              selectedTileColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              onTap: () {
                                setState(() {
                                  _selectedVariant = variant;
                                });
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    DialogService.showVariantsDialog(
                                      context,
                                      widget.storeId,
                                      variantId: variant.id,
                                      onSaved: (_) => variantsController.refresh(),
                                    );
                                  } else if (value == 'delete') {
                                    _deleteVariant(variant);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, size: 18),
                                        const SizedBox(width: 8),
                                        Text('Editar adicional'.tr()),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete,
                                            color: Colors.red),
                                        const SizedBox(width: 8),
                                        Text('Excluir adicional'.tr()),
                                      ],
                                    ),
                                  ),
                                ],
                                icon: Icon(Icons.more_vert,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6)),
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
        ),

        /// OPÇÕES DA VARIANTE (Lado Direito - Detalhe)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedVariant != null
                              ? 'Opções de "${_selectedVariant!.name}"'.tr()
                              : 'Selecione um adicional'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),

                        ),
                        if (_selectedVariant != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [


                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  DialogService.showVariantsOptionsDialog(
                                    context,
                                    widget.storeId,
                                    _selectedVariant!.id!,
                                    onSaved: () => variantsController.refresh(), // Atualiza as opções
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: Text('Nova Opção'.tr()),
                              ),

                              SizedBox(width: 8,),

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _showAssociateProductsDialog(_selectedVariant!);
                                },
                                icon: const Icon(Icons.link),
                                label: Text('Associar Produtos'.tr()),
                              ),
                            ],
                          ),


                      ],
                    ),
                  ),
                  if (_isLoadingOptions) const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Exibir inativos'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: _showInactiveOptions,
                          onChanged: (v) {
                            setState(() {
                              _showInactiveOptions = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _selectedVariant == null
                        ? Center(
                      child: Text(
                        'Por favor, selecione um adicional para ver suas opções.'
                            .tr(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    )
                        : AnimatedBuilder(
                      animation: variantsController,
                      builder: (context, child) {
                        // Encontra a variante selecionada na lista atual do controller
                        final currentSelectedVariant =
                        variantsController.items.firstWhereOrNull(
                                (v) => v.id == _selectedVariant!.id);

                        final List<VariantOption> filteredOptions =
                            currentSelectedVariant?.options
                                ?.where((o) =>
                            _showInactiveOptions ||
                                o.available)
                                .toList() ??
                                [];

                        if (filteredOptions.isEmpty &&
                            !_isLoadingOptions) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Nenhuma opção encontrada para este adicional. Crie uma nova!'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOptions.length,
                          itemBuilder: (context, index) {
                            final option = filteredOptions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0), // Espaçamento entre as opções
                              child: VariantOptionListItem(
                                option: option,
                                storeId: widget.storeId,
                                variantId: _selectedVariant!.id!,
                                onSaved: () => variantsController.refresh(),
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
        ),
      ],
    );
  }

  Future<void> _deleteVariant(Variant variant) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content:
      'Tem certeza que deseja excluir o adicional "${variant.name}" e todas as suas opções associadas?'
          .tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoadingVariants = true);

      try {
        await getIt<ProductRepository>().deleteVariant(
          widget.storeId,
          variant.id!,
        );

        variantsController.removeLocally((v) => v.id == variant.id);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (_selectedVariant?.id == variant.id) {
            _selectedVariant = variantsController.items.isNotEmpty
                ? variantsController.items.first
                : null;
          }

          if (mounted) {
            setState(() {
              _isLoadingVariants = false;
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Adicional "${variant.name}" excluído com sucesso.'.tr(),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir adicional: ${e.toString()}'.tr()),
            ),
          );
        }
        if (mounted) setState(() => _isLoadingVariants = false);
      }
    }
  }
}

// Extensão para encontrar o primeiro elemento que satisfaz uma condição ou null
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}