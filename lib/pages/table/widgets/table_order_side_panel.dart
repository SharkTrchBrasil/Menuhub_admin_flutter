// lib/pages/tables/widgets/table_order_side_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/tables/table.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/repositories/table_repository.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';
import 'package:totem_pro_admin/pages/commands/widgets/create_command_dialog.dart'; // ✅ ADICIONADO
import 'package:collection/collection.dart';

import '../../../models/tables/command.dart';

class TableOrderSidePanel extends StatefulWidget {
  final TableModel table;
  final VoidCallback onClose;

  const TableOrderSidePanel({
    super.key,
    required this.table,
    required this.onClose,
  });

  @override
  State<TableOrderSidePanel> createState() => _TableOrderSidePanelState();
}

class _TableOrderSidePanelState extends State<TableOrderSidePanel> {
  final _tableRepository = GetIt.I<TableRepository>();
  final _searchController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedCommandId; // ✅ ADICIONADO
  final Map<int, CartItem> _tempCart = {}; // productId -> CartItem
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ✅ NOVO: Verifica se a mesa tem comanda ativa
    final activeCommand = widget.table.activeCommand;

    // Se mesa está OCUPADA e tem comanda com itens, mostra detalhes
    if (activeCommand != null && activeCommand.hasItems) {
      return _buildCommandDetailsView(activeCommand);
    }



    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final allCategories = state.activeStoreWithRole!.store.relations.categories;
        final allProducts = state.activeStoreWithRole!.store.relations.products;

        // Filtra produtos por busca e categoria
        final filteredProducts = _filterProducts(allProducts, allCategories);

        return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              // COLUNA ESQUERDA: CATEGORIAS
              _buildCategoriesColumn(allCategories),

              // COLUNA CENTRAL: PRODUTOS
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : _buildProductsGrid(filteredProducts),
                    ),
                  ],
                ),
              ),

              // COLUNA DIREITA: RESUMO DO PEDIDO
              _buildOrderSummary(allProducts, state.activeStoreWithRole!.store.core.id!),
            ],
          ),
        );
      },
    );
  }

  // ===== FILTROS =====

  List<Product> _filterProducts(List<Product> allProducts, List<Category> allCategories) {
    var products = allProducts;

    // Filtra por categoria selecionada
    if (_selectedCategoryId != null) {
      products = products.where((p) {
        return p.categoryLinks.any((link) => link.categoryId == _selectedCategoryId);
      }).toList();
    }

    // Filtra por busca
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      products = products.where((p) => p.name.toLowerCase().contains(searchText)).toList();
    }

    return products;
  }

  // ===== COLUNA DE CATEGORIAS =====

  Widget _buildCategoriesColumn(List<Category> categories) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          _buildPanelHeader(),
          // "Todas" as categorias
          ListTile(
            selected: _selectedCategoryId == null,
            selectedTileColor: Colors.orange.withOpacity(0.1),
            leading: Icon(
              Icons.grid_view,
              color: _selectedCategoryId == null ? Colors.orange : Colors.grey,
            ),
            title: Text(
              'Todas',
              style: TextStyle(
                fontWeight: _selectedCategoryId == null ? FontWeight.bold : FontWeight.normal,
                color: _selectedCategoryId == null ? Colors.orange : Colors.black87,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedCategoryId = null;
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategoryId == category.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.orange.withOpacity(0.1),
                  leading: Icon(
                    Icons.category,
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.orange : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.table.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Capacidade: ${widget.table.maxCapacity}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== BARRA DE BUSCA =====

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ===== GRID DE PRODUTOS =====

  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final cartItem = _tempCart[product.id];
    final quantity = cartItem?.quantity ?? 0;

    // Pega o primeiro link de categoria para mostrar o preço
    final firstLink = product.categoryLinks.firstOrNull;
    final priceInCents = firstLink?.price ?? product.price ?? 0;
    final formattedPrice = (priceInCents / 100).toStringAsFixed(2).replaceAll('.', ',');

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addProductToCart(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ProductImage(
                imageUrl: product.images.isNotEmpty ? product.images.first.url : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ $formattedPrice',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (quantity > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$quantity no carrinho',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== VISUALIZAÇÃO DE DETALHES DA COMANDA =====

  Widget _buildCommandDetailsView(Command command) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCommandDetailsHeader(command),
          Expanded(
            child: _buildCommandItemsList(command),
          ),
          _buildCommandFooter(command),
        ],
      ),
    );
  }

  Widget _buildCommandDetailsHeader(Command command) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command.customerName ?? widget.table.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${command.itemCount} ${command.itemCount == 1 ? "item" : "itens"} • ${widget.table.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Fecha o painel de detalhes e volta para o modo de adicionar itens
              setState(() {
                // Força o widget a reconstruir sem a visualização de detalhes
              });
              // Limpa a seleção de comanda para voltar ao grid de produtos
              _selectedCommandId = command.id;
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar Itens'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandItemsList(Command command) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: command.items.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = command.items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                ),
              )
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            // Detalhes do item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Text(
                        item.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[900],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${item.priceInReais.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total do item
            Text(
              'R\$ ${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommandFooter(Command command) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (command.notes != null && command.notes!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Observações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    command.notes!,
                    style: TextStyle(color: Colors.blue[900], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Resumo financeiro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 14)),
              Text(
                'R\$ ${command.totalInReais.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Descontos', style: TextStyle(fontSize: 14, color: Colors.green)),
              Text(
                'R\$ 0,00',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${command.totalInReais.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ===== RESUMO DO PEDIDO =====

  Widget _buildOrderSummary(List<Product> allProducts, int storeId) {
    final totalItems = _tempCart.values.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = _tempCart.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Pedido ($totalItems ${totalItems == 1 ? 'item' : 'itens'})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tempCart.isEmpty
                ? const Center(
              child: Text(
                'Nenhum item adicionado',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _tempCart.length,
              itemBuilder: (context, index) {
                final cartItem = _tempCart.values.elementAt(index);
                final product = allProducts.firstWhere((p) => p.id == cartItem.productId);

                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: ProductImage(
                      imageUrl: product.images.isNotEmpty ? product.images.first.url : null,
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('R\$ ${(cartItem.price / 100).toStringAsFixed(2).replaceAll('.', ',')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _decrementProduct(product.id!),
                        iconSize: 20,
                      ),
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _addProductToCart(product),
                        iconSize: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${(totalPrice / 100).toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _tempCart.isEmpty || _isSubmitting ? null : () => _confirmOrder(storeId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Confirmar Pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== AÇÕES DO CARRINHO =====

  void _addProductToCart(Product product) {
    final firstLink = product.categoryLinks.firstOrNull;
    final priceInCents = firstLink?.price ?? product.price ?? 0;
    final categoryId = firstLink?.categoryId ?? 0;

    setState(() {
      if (_tempCart.containsKey(product.id)) {
        _tempCart[product.id!] = _tempCart[product.id]!.copyWith(
          quantity: _tempCart[product.id]!.quantity + 1,
        );
      } else {
        _tempCart[product.id!] = CartItem(
          productId: product.id!,
          categoryId: categoryId,
          quantity: 1,
          price: priceInCents,
          note: null,
        );
      }
    });
  }

  void _decrementProduct(int productId) {
    setState(() {
      if (_tempCart[productId]!.quantity > 1) {
        _tempCart[productId] = _tempCart[productId]!.copyWith(
          quantity: _tempCart[productId]!.quantity - 1,
        );
      } else {
        _tempCart.remove(productId);
      }
    });
  }

  Future<void> _confirmOrder(int storeId) async {
    if (_tempCart.isEmpty) return;

    final activeCommands = widget.table.commands.where((c) => c.isActive).toList();

    int? commandId;

    // ✅ LÓGICA HÍBRIDA
    if (activeCommands.isEmpty) {
      // Mostra dialog perguntando SE QUER criar comanda automaticamente
      final shouldCreateCommand = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mesa sem comanda ativa'),
          content: const Text(
            'Esta mesa não possui uma comanda aberta. Deseja:\n\n'
                '• Criar comanda rápida (continuar pedido)\n'
                '• Abrir mesa com detalhes (nome, observações)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx, false);
                // ✅ USANDO CreateCommandDialog
                showDialog(
                  context: context,
                  builder: (_) => CreateCommandDialog(
                    storeId: storeId,
                    preselectedTableId: widget.table.id,
                  ),
                );
              },
              child: const Text('Abrir com Detalhes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Criar Rápida'),
            ),
          ],
        ),
      );

      if (shouldCreateCommand != true) return;

      // Cria comanda automática
      setState(() => _isSubmitting = true);

      final result = await _tableRepository.openTable(
        storeId: storeId,
        tableId: widget.table.id,
        customerName: null,
        notes: 'Comanda criada automaticamente',
      );

      if (result.isLeft) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar comanda: ${result.left}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      // Extrai o command_id da resposta
      commandId = result.right['command_id'] as int?;

      if (commandId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Comanda criada mas ID não retornado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      // Aguarda socket atualizar
      await Future.delayed(const Duration(milliseconds: 300));
    } else if (activeCommands.length == 1) {
      commandId = activeCommands.first.id;
    } else {
      // Múltiplas comandas - precisa selecionar
      if (_selectedCommandId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma comanda antes de confirmar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      commandId = _selectedCommandId;
    }

    // Agora prossegue com a adição dos itens
    setState(() => _isSubmitting = true);

    try {
      for (final cartItem in _tempCart.values) {
        final result = await _tableRepository.addItemToTable(
          storeId: storeId,
          tableId: widget.table.id,
          commandId: commandId!,
          productId: cartItem.productId,
          categoryId: cartItem.categoryId,
          quantity: cartItem.quantity,
          note: cartItem.note,
          variants: [],
        );

        if (result.isLeft) {
          throw Exception(result.left);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Itens adicionados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// ===== MODEL AUXILIAR =====

class CartItem {
  final int productId;
  final int categoryId;
  final int quantity;
  final int price; // Em centavos
  final String? note;

  CartItem({
    required this.productId,
    required this.categoryId,
    required this.quantity,
    required this.price,
    this.note,
  });

  CartItem copyWith({
    int? quantity,
    String? note,
  }) {
    return CartItem(
      productId: productId,
      categoryId: categoryId,
      quantity: quantity ?? this.quantity,
      price: price,
      note: note ?? this.note,
    );
  }
}