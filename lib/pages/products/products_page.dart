import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

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
  bool isLoading = true;

  Category? selectedCategory;

  Map<int, List<Product>> categoryProducts = {};

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndProducts();
  }

  Future<void> _loadCategoriesAndProducts() async {

    setState(() => isLoading = true);

    await categoriesController.refresh();
    await productsController.refresh();
    _mapProductsToCategories();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _mapProductsToCategories() {
    categoryProducts.clear();
    for (var product in productsController.items) {
      final categoryId = product.category?.id;
      if (categoryId != null) {
        categoryProducts.putIfAbsent(categoryId, () => []).add(product);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = productsController.items;
    final List<Product> filteredProducts = selectedCategory == null
        ? <Product>[]
        : allProducts
        .where((p) => p.category?.id == selectedCategory!.id)
        .toList();

    return BasePage(

      mobileAppBar: AppBarCustom(title: 'Produtos'),
      mobileBuilder: (context) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return
        _buildMobileLayout();

      },
      desktopBuilder: (context) {

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return
        _buildDesktopLayout(context, filteredProducts);
      },


      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FloatingActionButton(
          onPressed: () {
            DialogService.showCategoryDialog(
              context,
              widget.storeId,
              onSaved: (_) => _loadCategoriesAndProducts(),
            );



          },
          tooltip: 'Nova categoria',
          elevation: 0,
          child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        ),
      ),



    );
  }

  Widget _buildMobileLayout() {
    final categories = categoriesController.items;

    return RefreshIndicator(
      onRefresh: _loadCategoriesAndProducts,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 8),
          ...categories.map((category) {
            final products = categoryProducts[category.id] ?? [];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  ],
                ),

                  // Agora o ExpansionTile usa seu ícone padrão de expandir
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  ...products.map((product) {
                    return _buildProductCard(product);
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Novo produto', overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          onTap: () {
                            DialogService.showProductDialog(
                              context,
                              category: category,
                              widget.storeId,
                              onSaved: (_) => _loadCategoriesAndProducts(),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: ListTile(
                          dense:true,
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Editar categoria', overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                          onTap: () {
                            DialogService.showCategoryDialog(
                              context,
                              categoryId: category.id,
                              widget.storeId,
                              onSaved: (_) => _loadCategoriesAndProducts(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

          }),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, List<Product> filteredProducts) {
    return Row(
      children: [
        /// CATEGORIAS
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ListTile(
                title: const Text('Categorias',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    DialogService.showCategoryDialog(
                      context,
                      widget.storeId,
                      onSaved: (_) => _loadCategoriesAndProducts(),
                    );
                  },
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: categoriesController,
                  builder: (_, __) {
                    final items = categoriesController.items;
                    if (items.isNotEmpty && selectedCategory == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => selectedCategory = items.first);
                        }
                      });
                    }
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final category = items[index];
                        return ListTile(
                          title: Text(category.name),
                          selected: selectedCategory?.id == category.id,
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
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

        /// PRODUTOS
        Expanded(
          flex: 5,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  selectedCategory != null
                      ? 'Produtos de ${selectedCategory!.name}'
                      : 'Selecione uma categoria',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: selectedCategory != null
                    ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    DialogService.showProductDialog(
                      context,
                      category: selectedCategory,
                      widget.storeId,
                      onSaved: (_) => _loadCategoriesAndProducts(),
                    );
                  },
                )
                    : null,
              ),
              Expanded(
                child: selectedCategory == null
                    ? const Center(child: Text('Nenhuma categoria selecionada'))
                    : LayoutBuilder(
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
                      children: filteredProducts
                          .map(_buildProductCard)
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.image?.url != null
                ? Image.network(product.image!.url!,
                width: 48, height: 48, fit: BoxFit.cover)
                : Container(
              width: 48,
              height: 48,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  NumberFormat.simpleCurrency(locale: 'pt-BR')
                      .format(product.basePrice! / 100),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                product.available ? "Ativo" : "Inativo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: product.available ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              DialogService.showProductDialog(
                context,
                widget.storeId,
                productId: product.id,




                onSaved: (_) => _loadCategoriesAndProducts(),
              );

            },
          ),
        ),
      ),
    );
  }
}
