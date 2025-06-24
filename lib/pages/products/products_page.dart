import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

import '../../ConstData/typography.dart';
import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/mobileappbar.dart';

class CategoryProductPage extends StatefulWidget {
  final int storeId;

  const CategoryProductPage({super.key, required this.storeId});

  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  late final AppListController<Product> productsController =
      AppListController<Product>(
        fetch: () => getIt<ProductRepository>().getProducts(widget.storeId),
      );

  late final AppListController<Category> categoriesController =
      AppListController<Category>(
        fetch: () => getIt<CategoryRepository>().getCategories(widget.storeId),
      );

  bool _isLoadingInitialData = true;
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;

  Category? _selectedCategory;
  final Map<int, List<Product>> _categoryProductsMap = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    productsController.addListener(_onProductsChange);
    categoriesController.addListener(_onCategoriesChange);
  }

  @override
  void dispose() {
    productsController.removeListener(_onProductsChange);
    categoriesController.removeListener(_onCategoriesChange);
    productsController.dispose();
    categoriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileAppBar: AppBarCustom(title: 'Produtos'.tr()),
      mobileBuilder: (context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildMobileLayout();
      },
      desktopBuilder: (context) {
        if (_isLoadingInitialData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildDesktopLayout(context);
      },
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showCategoryDialog(
              context,
              widget.storeId,
              onSaved: _handleCategorySaved,
            );
          },
          tooltip: 'Nova categoria'.tr(),
          elevation: 0,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final categories = categoriesController.items;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const SizedBox(height: 8),
              if (_isLoadingCategories || _isLoadingProducts)
                const LinearProgressIndicator(),
              if (categories.isEmpty && !_isLoadingInitialData)
                Center(child: Text('Nenhuma categoria encontrada.'.tr())),
              ...categories.map((category) {
                final products = _categoryProductsMap[category.id] ?? [];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    key: ValueKey(category.id),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    children: [
                      if (products.isEmpty && !_isLoadingProducts)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Nenhum produto nesta categoria.'.tr()),
                        ),
                      if (_isLoadingProducts &&
                          _selectedCategory?.id == category.id)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                      ...products.map((product) {
                        return _buildProductCard(product);
                      }),
                      _buildMobileActionRow(category),
                    ],
                  ),
                );
              }), // Adicione .toList() aqui
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionRow(Category category) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Row(
              children: [
                const Icon(Icons.add, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Novo produto'.tr(), overflow: TextOverflow.ellipsis),
              ],
            ),
            onTap: () {
              DialogService.showProductDialog(
                context,
                widget.storeId,
                category: category,
                onSaved: _handleProductSaved,
              );
            },
          ),
        ),
        Expanded(
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Editar categoria'.tr(), overflow: TextOverflow.ellipsis),
              ],
            ),
            onTap: () {
              DialogService.showCategoryDialog(
                context,
                widget.storeId,
                categoryId: category.id,
                onSaved: _handleCategorySaved,
              );
            },
          ),
        ),
        Expanded(
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const SizedBox(width: 8),
                Text('Excluir categoria'.tr(), overflow: TextOverflow.ellipsis),
              ],
            ),
            onTap: () => _deleteCategory(category),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        /// CATEGORIAS
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
                    title: Text(
                      'Categorias'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        DialogService.showCategoryDialog(
                          context,
                          widget.storeId,
                          onSaved: _handleCategorySaved,
                        );
                      },
                    ),
                  ),
                  if (_isLoadingCategories) const LinearProgressIndicator(),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: categoriesController,
                      builder: (_, __) {
                        final items = categoriesController.items;
                        if (_selectedCategory == null && items.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(() => _selectedCategory = items.first);
                          });
                        } else if (_selectedCategory != null &&
                            !items.any((c) => c.id == _selectedCategory!.id)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(
                                () =>
                                    _selectedCategory =
                                        items.isNotEmpty ? items.first : null,
                              );
                          });
                        }

                        if (items.isEmpty) {
                          return Center(
                            child: Text('Nenhuma categoria encontrada.'.tr()),
                          );
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final category = items[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child:
                                    category.image?.url != null
                                        ? Image.network(
                                          category.image!.url!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                            );
                                          },
                                        )
                                        : Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                              ),
                              title: Text(category.name),
                              selected: _selectedCategory?.id == category.id,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    DialogService.showCategoryDialog(
                                      context,
                                      widget.storeId,
                                      categoryId: category.id,
                                      onSaved: _handleCategorySaved,
                                    );
                                  } else if (value == 'delete') {
                                    _deleteCategory(category);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [

                                            const Icon(
                                              Icons.edit,

                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),

                                            Text('Editar categoria'.tr()),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text('Excluir categoria'.tr()),
                                          ],
                                        ),
                                      ),
                                    ],
                                icon: const Icon(Icons.more_vert),
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

        /// PRODUTOS
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      _selectedCategory != null
                          ? _selectedCategory!.name.tr()
                          : 'Selecione uma categoria'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing:
                        _selectedCategory != null
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  fixedSize: const Size.fromHeight(48),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  DialogService.showProductDialog(
                                    context,
                                    widget.storeId,
                                    category: _selectedCategory,
                                    onSaved: _handleProductSaved,
                                  );
                                },

                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/plus+.svg",
                                      height: 20,
                                      width: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "NOVO PRODUTO",
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : null,
                  ),
                  if (_isLoadingProducts) const LinearProgressIndicator(),
                  Expanded(
                    child:
                        _selectedCategory == null
                            ? Center(
                              child: Text(
                                'Nenhuma categoria selecionada.'.tr(),
                              ),
                            )
                            : AnimatedBuilder(
                              animation: productsController,
                              builder: (context, child) {
                                final List<Product> filteredProducts =
                                    _selectedCategory == null
                                        ? <Product>[]
                                        : (_categoryProductsMap[_selectedCategory!
                                                .id] ??
                                            []);

                                if (filteredProducts.isEmpty &&
                                    !_isLoadingProducts) {
                                  return Center(
                                    child: Text(
                                      'Nenhum produto encontrado para esta categoria.'
                                          .tr(),
                                    ),
                                  );
                                }

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = 1;
                                    if (constraints.maxWidth >= 1200) {
                                      crossAxisCount = 4;
                                    } else if (constraints.maxWidth >= 900) {
                                      crossAxisCount = 3;
                                    } else if (constraints.maxWidth >= 600) {
                                      crossAxisCount = 2;
                                    }

                                    return GridView.count(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      padding: const EdgeInsets.all(12),
                                      childAspectRatio: 3.5,
                                      children:
                                          filteredProducts
                                              .map(_buildProductCard)
                                              .toList(),
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


  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08), // Borda sutil
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent, // Evita sobrepor o fundo do Container
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12), // Borda suave na imagem
              child: SizedBox(
                width: 64,
                height: 120,
                child: product.image?.url != null
                    ? Image.network(
                  product.image!.url!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 30),
                  ),
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 30),
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    NumberFormat.simpleCurrency(locale: 'pt-BR')
                        .format((product.basePrice ?? 0) / 100),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  product.available ? "Ativo".tr() : "Inativo".tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: product.available ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              tooltip: '',
              onSelected: (value) {
                if (value == 'edit') {
                  DialogService.showProductDialog(
                    context,
                    widget.storeId,
                    productId: product.id,
                    onSaved: _handleProductSaved,
                  );
                } else if (value == 'delete') {
                  _deleteProduct(product);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('Editar produto'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Excluir produto'.tr()),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingInitialData = true);
    try {
      await categoriesController.refresh();
      await productsController.refresh();
      _mapProductsToCategories();
      if (categoriesController.items.isNotEmpty && _selectedCategory == null) {
        _selectedCategory = categoriesController.items.first;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar dados iniciais: ${e.toString()}'.tr(),
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

  void _onProductsChange() {
    _mapProductsToCategories();
    if (mounted) {
      setState(() {});
    }
  }

  void _onCategoriesChange() {
    if (_selectedCategory != null &&
        !categoriesController.items.any((c) => c.id == _selectedCategory!.id)) {
      _selectedCategory =
          categoriesController.items.isNotEmpty
              ? categoriesController.items.first
              : null;
    }
    _mapProductsToCategories();
    if (mounted) {
      setState(() {});
    }
  }

  void _mapProductsToCategories() {
    _categoryProductsMap.clear();
    for (var product in productsController.items) {
      final categoryId = product.category?.id;
      if (categoryId != null) {
        _categoryProductsMap.putIfAbsent(categoryId, () => []).add(product);
      }
    }
  }

  void _addOrUpdateCategoryLocally(Category newCategory) {
    final index = categoriesController.items.indexWhere(
      (c) => c.id == newCategory.id,
    );

    if (index != -1) {
      categoriesController.items[index] = newCategory;
    } else {
      categoriesController.items.add(newCategory);
      categoriesController.items.sort((a, b) => a.name.compareTo(b.name));
    }

    if (_selectedCategory?.id != newCategory.id) {
      _selectedCategory = newCategory;
      if (mounted) {
        setState(() {
          _mapProductsToCategories();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _mapProductsToCategories();
        });
      }
    }
  }

  void _addOrUpdateProductLocally(Product newProduct) {
    final index = productsController.items.indexWhere(
      (p) => p.id == newProduct.id,
    );

    if (index != -1) {
      productsController.items[index] = newProduct;
    } else {
      productsController.items.add(newProduct);
      productsController.items.sort((a, b) => a.name.compareTo(b.name));
    }
    productsController.updateLocally();
  }

  Future<void> _handleCategorySaved(dynamic category) async {
    if (mounted) {
      setState(() => _isLoadingCategories = true);
    }
    try {
      if (category is Category) {
        _addOrUpdateCategoryLocally(category);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar categoria: ${e.toString()}'.tr()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _handleProductSaved(dynamic product) async {
    if (mounted) {
      setState(() => _isLoadingProducts = true);
    }
    try {
      if (product is Product) {
        _addOrUpdateProductLocally(product);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: ${e.toString()}'.tr()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content:
          'Tem certeza que deseja excluir a categoria "${category.name}" e todos os seus produtos associados?'
              .tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = true);

      try {
        await getIt<CategoryRepository>().deleteCategory(
          widget.storeId,
          category.id!,
        );

        categoriesController.removeLocally((c) => c.id == category.id);

        final productsToRemove =
            productsController.items
                .where((p) => p.category?.id == category.id)
                .toList();
        for (var product in productsToRemove) {
          productsController.removeLocally((p) => p.id == product.id);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (_selectedCategory?.id == category.id) {
            _selectedCategory =
                categoriesController.items.isNotEmpty
                    ? categoriesController.items.first
                    : null;
          }
          _mapProductsToCategories();

          if (mounted) {
            setState(() {
              _isLoadingCategories = false;
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Categoria "${category.name}" excluída com sucesso.'.tr(),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir categoria: ${e.toString()}'.tr()),
            ),
          );
        }
        if (mounted) setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content:
          'Tem certeza que deseja excluir o produto "${product.name}"?'.tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoadingProducts = true);

      try {
        await getIt<ProductRepository>().deleteProduct(
          widget.storeId,
          product.id!,
        );

        productsController.removeLocally((p) => p.id == product.id);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _mapProductsToCategories();
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produto "${product.name}" excluído com sucesso.'.tr(),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir produto: ${e.toString()}'.tr()),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingProducts = false);
        }
      }
    }
  }
}

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:totem_pro_admin/pages/base/BasePage.dart';
// import 'package:totem_pro_admin/services/dialog_service.dart';
//
// import '../../core/app_list_controller.dart';
//
// import '../../core/di.dart';
// import '../../models/category.dart';
// import '../../models/product.dart';
// import '../../repositories/category_repository.dart';
// import '../../repositories/product_repository.dart';
// import '../../widgets/mobileappbar.dart';
//
// class CategoryProductPage extends StatefulWidget {
//   final int storeId;
//
//   const CategoryProductPage({super.key, required this.storeId});
//
//   @override
//   State<CategoryProductPage> createState() => _CategoryProductPageState();
// }
//
// class _CategoryProductPageState extends State<CategoryProductPage> {
//   late final AppListController<Product> productsController =
//   AppListController<Product>(
//     fetch: () => getIt<ProductRepository>().getProducts(widget.storeId),
//   );
//
//   late final AppListController<Category> categoriesController =
//   AppListController<Category>(
//     fetch: () => getIt<CategoryRepository>().getCategories(widget.storeId),
//   );
//
//   bool _isLoadingInitialData = true; // Para o carregamento inicial completo
//   bool _isLoadingCategories = false; // Para o refresh de categorias
//   bool _isLoadingProducts = false; // Para o refresh de produtos
//
//   Category? _selectedCategory;
//   final Map<int, List<Product>> _categoryProductsMap = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     // Listeners para atualizar a UI quando os dados mudam nos controllers
//     productsController.addListener(_onProductsChange);
//     categoriesController.addListener(_onCategoriesChange);
//   }
//
//   @override
//   void dispose() {
//     productsController.removeListener(_onProductsChange);
//     categoriesController.removeListener(_onCategoriesChange);
//     productsController.dispose();
//     categoriesController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadInitialData() async {
//     if (!mounted) return;
//     setState(() => _isLoadingInitialData = true);
//     try {
//       await categoriesController.refresh();
//       await productsController.refresh();
//       _mapProductsToCategories();
//       if (categoriesController.items.isNotEmpty && _selectedCategory == null) {
//         _selectedCategory = categoriesController.items.first;
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao carregar dados iniciais: ${e.toString()}'.tr())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingInitialData = false);
//       }
//     }
//   }
//
//   void _onProductsChange() {
//     _mapProductsToCategories();
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   void _onCategoriesChange() {
//     // Lógica para reajustar a categoria selecionada se ela foi removida
//     if (_selectedCategory != null &&
//         !categoriesController.items.any((c) => c.id == _selectedCategory!.id)) {
//       _selectedCategory = categoriesController.items.isNotEmpty
//           ? categoriesController.items.first
//           : null;
//     }
//     _mapProductsToCategories(); // Recalcula o mapa de produtos para categorias
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   void _mapProductsToCategories() {
//     _categoryProductsMap.clear();
//     for (var product in productsController.items) {
//       final categoryId = product.category?.id;
//       if (categoryId != null) {
//         _categoryProductsMap.putIfAbsent(categoryId, () => []).add(product);
//       }
//     }
//   }
//
//
// // Adiciona ou atualiza uma categoria na lista localmente
//   void _addOrUpdateCategoryLocally(Category newCategory) {
//     final index = categoriesController.items.indexWhere((c) => c.id == newCategory.id);
//
//     if (index != -1) {
//       // Se a categoria já existe, atualiza
//       categoriesController.items[index] = newCategory;
//     } else {
//       // Se é uma nova categoria, adiciona
//       categoriesController.items.add(newCategory);
//       categoriesController.items.sort((a, b) => a.name.compareTo(b.name));
//     }
//
//     // Define a nova categoria como a selecionada se ela não for a já selecionada,
//     // ou se _selectedCategory for nulo (primeira categoria).
//     // Isso garante que a categoria recém-criada/editada seja o foco.
//     if (_selectedCategory?.id != newCategory.id) {
//       _selectedCategory = newCategory;
//       // Força a reconstrução da UI para refletir a nova categoria selecionada
//       // e os produtos associados.
//       if (mounted) {
//         setState(() {
//           // Quando a categoria selecionada muda, precisamos garantir que o mapa de produtos
//           // seja atualizado para a nova seleção. Embora _onProductsChange e _onCategoriesChange
//           // já chamem _mapProductsToCategories(), chamá-lo aqui garante que a UI
//           // tenha os produtos corretos imediatamente após a mudança de categoria selecionada.
//           _mapProductsToCategories();
//         });
//       }
//     } else {
//       // Se a categoria já estava selecionada (caso de edição), apenas atualiza
//       // o estado para garantir que a UI reflita a mudança (ex: nome, imagem).
//       if (mounted) {
//         setState(() {
//           // Se a categoria selecionada foi editada, precisamos garantir que o mapa
//           // de produtos seja recalculado, caso a edição tenha afetado a categorização.
//           _mapProductsToCategories();
//         });
//       }
//     }
//
//     // O categoriesController.notifyListeners() não é necessário aqui,
//     // pois o setState já força a reconstrução do widget e o AnimatedBuilder
//     // escutando categoriesController reagirá automaticamente às mudanças em `items`.
//   }
//
//
//
//   // A função _addOrUpdateProductLocally permanece a mesma, pois ela apenas manipula a lista
//   void _addOrUpdateProductLocally(Product newProduct) {
//     final index = productsController.items.indexWhere((p) => p.id == newProduct.id);
//
//     if (index != -1) {
//       productsController.items[index] = newProduct;
//     } else {
//       productsController.items.add(newProduct);
//       // Opcional: Para manter a lista de produtos ordenados após adicionar um novo
//       productsController.items.sort((a, b) => a.name.compareTo(b.name));
//     }
//     // Não é necessário chamar notifyListeners() aqui, o _handleProductSaved fará a notificação.
//   }
//
//   // Método para atualizar categorias - agora chamado com o item salvo
//   Future<void> _handleCategorySaved(dynamic category) async {
//     if (mounted) {
//       setState(() => _isLoadingCategories = true);
//     }
//     try {
//       if (category is Category) {
//         _addOrUpdateCategoryLocally(category);
//         // Se o desejo é que a lista de categorias seja atualizada
//         // com o dado do backend, descomente a linha abaixo.
//         // Se a mudança local é suficiente e a tela de categorias já é atualizada,
//         // pode manter comentado para performance.
//         // await categoriesController.refresh();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao salvar categoria: ${e.toString()}'.tr())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingCategories = false);
//       }
//     }
//   }
//
//   // Método para atualizar produtos - AQUI ESTÁ A MUDANÇA PRINCIPAL
//   Future<void> _handleProductSaved(dynamic product) async {
//     if (mounted) {
//       setState(() => _isLoadingProducts = true);
//     }
//     try {
//       if (product is Product) {
//         _addOrUpdateProductLocally(product); // Adiciona/atualiza o produto na lista local
//
//         // --- AQUI ESTÁ A SOLUÇÃO FINAL ---
//         // Notifica o productsController que sua lista interna foi atualizada.
//         // Isso fará com que o AnimatedBuilder reaja e a UI seja reconstruída
//         // sem precisar fazer um fetch completo do backend.
//         productsController.updateLocally();
//
//         // Opcional: Se você quiser garantir que o `_categoryProductsMap`
//         // seja recalculado imediatamente após a atualização local,
//         // você pode chamar `_mapProductsToCategories()` e `setState({})` aqui.
//         // No entanto, como `_onProductsChange` já chama `_mapProductsToCategories()`
//         // quando `productsController` notifica, não é estritamente necessário.
//         // Se a UI não estiver atualizando de imediato, pode descomentar:
//         // if (mounted) {
//         //   _mapProductsToCategories();
//         //   setState(() {});
//         // }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao salvar produto: ${e.toString()}'.tr())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingProducts = false);
//       }
//     }
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BasePage(
//       mobileAppBar: AppBarCustom(title: 'Produtos'.tr()),
//       mobileBuilder: (context) {
//         if (_isLoadingInitialData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return _buildMobileLayout();
//       },
//       desktopBuilder: (context) {
//         if (_isLoadingInitialData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return _buildDesktopLayout(context);
//       },
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 18.0),
//         child: FloatingActionButton(
//           onPressed: () {
//             DialogService.showCategoryDialog(
//               context,
//               widget.storeId,
//               onSaved: _handleCategorySaved, // Agora chama o novo handler
//             );
//           },
//           tooltip: 'Nova categoria'.tr(),
//           elevation: 0,
//           child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMobileLayout() {
//     final categories = categoriesController.items;
//
//     return RefreshIndicator(
//       onRefresh: _loadInitialData,
//       child: Stack( // Usar Stack para sobrepor o LinearProgressIndicator
//         children: [
//           ListView(
//             padding: const EdgeInsets.all(8),
//             children: [
//               const SizedBox(height: 8),
//               // LinearProgressIndicator agora aparece sempre que alguma das duas listas estiver carregando
//               if (_isLoadingCategories || _isLoadingProducts)
//                 const LinearProgressIndicator(),
//               if (categories.isEmpty && !_isLoadingInitialData)
//                 Center(child: Text('Nenhuma categoria encontrada.'.tr())),
//               ...categories.map((category) {
//                 final products = _categoryProductsMap[category.id] ?? [];
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: ExpansionTile(
//                     key: ValueKey(category.id), // Adicionado para melhor identificação
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     tilePadding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 12),
//                     title: Text(category.name,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16)),
//                     childrenPadding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                     children: [
//                       if (products.isEmpty && !_isLoadingProducts) // Exibe mensagem se não houver produtos E não estiver carregando
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text('Nenhum produto nesta categoria.'.tr()),
//                         ),
//                       // Mostrar loading de produtos dentro da ExpansionTile
//                       if (_isLoadingProducts && _selectedCategory?.id == category.id)
//                         const Center(child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: CircularProgressIndicator.adaptive(),
//                         )),
//                       // Produtos serão renderizados aqui
//                       ...products.map((product) {
//                         return _buildProductCard(product);
//                       }),
//                       _buildMobileActionRow(category),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMobileActionRow(Category category) {
//     return Row(
//       children: [
//         Expanded(
//           child: ListTile(
//             contentPadding: EdgeInsets.zero,
//             dense: true,
//             title: Row(
//               children: [
//                 const Icon(Icons.add, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 Text('Novo produto'.tr(), overflow: TextOverflow.ellipsis),
//               ],
//             ),
//             onTap: () {
//               DialogService.showProductDialog(
//                 context,
//                 widget.storeId,
//                 category: category,
//                 onSaved: _handleProductSaved, // Chama o novo handler
//               );
//             },
//           ),
//         ),
//         Expanded(
//           child: ListTile(
//             dense: true,
//             contentPadding: EdgeInsets.zero,
//             title: Row(
//               children: [
//                 const Icon(Icons.edit, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 Text('Editar categoria'.tr(), overflow: TextOverflow.ellipsis),
//               ],
//             ),
//             onTap: () {
//               DialogService.showCategoryDialog(
//                 context,
//                 widget.storeId,
//                 categoryId: category.id,
//                 onSaved: _handleCategorySaved, // Chama o novo handler
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDesktopLayout(BuildContext context) {
//     return Row(
//       children: [
//         /// CATEGORIAS
//         Expanded(
//           flex: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Material(
//               borderRadius: BorderRadius.circular(12),
//               elevation: 1,
//               child: Column(
//                 children: [
//                   ListTile(
//                     title: Text('Categorias'.tr(),
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.add),
//                       onPressed: () {
//                         DialogService.showCategoryDialog(
//                           context,
//                           widget.storeId,
//                           onSaved: _handleCategorySaved, // Chama o novo handler
//                         );
//                       },
//                     ),
//                   ),
//                   if (_isLoadingCategories)
//                     const LinearProgressIndicator(),
//                   Expanded(
//                     child: AnimatedBuilder(
//                       animation: categoriesController,
//                       builder: (_, __) {
//                         final items = categoriesController.items;
//                         // Lógica para selecionar a primeira categoria se nenhuma estiver selecionada
//                         if (_selectedCategory == null && items.isNotEmpty) {
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (mounted) setState(() => _selectedCategory = items.first);
//                           });
//                         } else if (_selectedCategory != null &&
//                             !items.any((c) => c.id == _selectedCategory!.id)) {
//                           // Se a categoria selecionada foi removida, seleciona a primeira ou limpa
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (mounted) setState(() => _selectedCategory = items.isNotEmpty ? items.first : null);
//                           });
//                         }
//
//                         if (items.isEmpty) {
//                           return Center(
//                               child: Text('Nenhuma categoria encontrada.'.tr()));
//                         }
//
//                         return ListView.builder(
//                           itemCount: items.length,
//                           itemBuilder: (_, index) {
//                             final category = items[index];
//                             return ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(4),
//                                 child: category.image?.url != null
//                                     ? Image.network(
//                                   category.image!.url!,
//                                   width: 40,
//                                   height: 40,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return const Icon(Icons.image_not_supported);
//                                   },
//                                 )
//                                     : Container(
//                                   width: 40,
//                                   height: 40,
//                                   color: Colors.grey[300],
//                                   child: const Icon(Icons.image_not_supported),
//                                 ),
//                               ),
//                               title: Text(category.name),
//                               selected: _selectedCategory?.id == category.id,
//                               onTap: () {
//                                 setState(() {
//                                   _selectedCategory = category;
//                                 });
//                               },
//                               trailing: IconButton(
//                                 icon: const Icon(Icons.edit),
//                                 onPressed: () {
//                                   DialogService.showCategoryDialog(
//                                     context,
//                                     widget.storeId,
//                                     categoryId: category.id,
//                                     onSaved: _handleCategorySaved, // Chama o novo handler
//                                   );
//                                 },
//                                 tooltip: 'Editar categoria'.tr(),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         /// PRODUTOS
//         Expanded(
//           flex: 5,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Material(
//               borderRadius: BorderRadius.circular(12),
//               elevation: 1,
//               child: Column(
//                 children: [
//                   ListTile(
//                     title: Text(
//                       _selectedCategory != null
//                           ? 'Produtos de ${_selectedCategory!.name}'.tr()
//                           : 'Selecione uma categoria'.tr(),
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     trailing: _selectedCategory != null
//                         ? IconButton(
//                       icon: const Icon(Icons.add),
//                       onPressed: () {
//                         DialogService.showProductDialog(
//                           context,
//                           widget.storeId,
//                           category: _selectedCategory,
//                           onSaved: _handleProductSaved, // Chama o novo handler
//                         );
//                       },
//                     )
//                         : null,
//                   ),
//                   if (_isLoadingProducts)
//                     const LinearProgressIndicator(),
//                   Expanded(
//                     child: _selectedCategory == null
//                         ? Center(child: Text('Nenhuma categoria selecionada.'.tr()))
//                         : AnimatedBuilder( // Envolvendo com AnimatedBuilder para reagir a productsController
//                       animation: productsController,
//                       builder: (context, child) {
//                         final List<Product> filteredProducts = _selectedCategory == null
//                             ? <Product>[]
//                             : (_categoryProductsMap[_selectedCategory!.id] ?? []);
//
//                         if (filteredProducts.isEmpty && !_isLoadingProducts)
//                           return Center(child: Text('Nenhum produto encontrado para esta categoria.'.tr()));
//
//                         return LayoutBuilder(
//                           builder: (context, constraints) {
//                             int crossAxisCount = 1;
//                             if (constraints.maxWidth >= 1200) {
//                               crossAxisCount = 4;
//                             } else if (constraints.maxWidth >= 900) {
//                               crossAxisCount = 3;
//                             } else if (constraints.maxWidth >= 600) {
//                               crossAxisCount = 2;
//                             }
//
//                             return GridView.count(
//                               crossAxisCount: crossAxisCount,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                               padding: const EdgeInsets.all(12),
//                               childAspectRatio: 3.5,
//                               children: filteredProducts
//                                   .map(_buildProductCard)
//                                   .toList(),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProductCard(Product product) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Material(
//         elevation: 1,
//         borderRadius: BorderRadius.circular(12),
//         child: ListTile(
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           leading: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: product.image?.url != null
//                 ? Image.network(product.image!.url!,
//                 width: 48, height: 48, fit: BoxFit.cover)
//                 : Container(
//               width: 48,
//               height: 48,
//               color: Colors.grey[300],
//               child: const Icon(Icons.image_not_supported),
//             ),
//           ),
//           title: Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: Text(
//               product.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           subtitle: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   NumberFormat.simpleCurrency(locale: 'pt-BR')
//                       .format((product.basePrice ?? 0) / 100),
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//               Text(
//                 product.available ? "Ativo".tr() : "Inativo".tr(),
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: product.available ? Colors.green : Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           trailing: IconButton(
//             icon: const Icon(Icons.edit, size: 20),
//             onPressed: () {
//               DialogService.showProductDialog(
//                 context,
//                 widget.storeId,
//                 productId: product.id,
//                 onSaved: _handleProductSaved, // Chama o novo handler
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
