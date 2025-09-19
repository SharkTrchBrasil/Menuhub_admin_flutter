import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../cubit/create_complement_cubit.dart';




class ComplementCopyList extends StatefulWidget {
  final VoidCallback onBack;
  const ComplementCopyList({super.key, required this.onBack});

  @override
  State<ComplementCopyList> createState() => _ComplementCopyListState();
}

class _ComplementCopyListState extends State<ComplementCopyList> {
  @override
  void initState() {
    super.initState();
    // ✨ 1. Chama a busca inicial assim que a tela é construída
    // Usamos um postFrameCallback para garantir que o Cubit esteja pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateComplementGroupCubit>().fetchInitialItemsToCopy();
    });
  }

  // Em lib/.../widgets/complement_copy_list.dart

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateComplementGroupCubit>();
    final groupType = cubit.state.groupType!;
    final groupName = cubit.state.groupName ?? 'seu grupo';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, groupName,

          onClear: () {
            // 1. Limpa a seleção no Cubit
            cubit.clearSelectedItems();

            // 2. Chama a função de 'voltar' que já existe no widget,
            //    exatamente como o botão "Voltar" original faria.
            widget.onBack();
          },

         ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            onChanged: (value) => cubit.searchItemsToCopy(value, type: groupType),
            decoration: const InputDecoration(
              hintText: "Escreva o nome do produto",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ✨ CORREÇÃO APLICADA AQUI ✨
        // O Expanded foi removido.
        BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
          builder: (context, state) {
            if (state.itemsAvailableToCopy.isEmpty) {
              return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("Nenhum complemento encontrado para copiar."),
                  ));
            }

            // ✨ 1. A conversão forçada (.cast) foi REMOVIDA
            final groupedItems = _groupItems(state.itemsAvailableToCopy);

            return ListView.builder(
              // ✨ 1. Adicionamos estas duas propriedades
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: groupedItems.keys.length,
              itemBuilder: (context, index) {
                final groupTitle = groupedItems.keys.elementAt(index);
                final itemsInGroup = groupedItems[groupTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        groupTitle,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
                      ),
                    ),
                    // Usamos um `Column` aqui em vez de `...map` para evitar problemas de layout aninhado
                    Column(
                      children: itemsInGroup.map((item) {
                        final isSelected = state.selectedToCopyIds.contains(item.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildItemCard(context, item, isSelected),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),

        BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: state.selectedToCopyIds.isEmpty
                      ? null
                      : () {
                    cubit.addSelectedItemsToGroup();
                    widget.onBack();
                  },
                  child: Text("Adicionar ${state.selectedToCopyIds.length} Itens"),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  /// ✨ 2. A função agora aceita uma List<dynamic> e trata os dois tipos.
  Map<String, List<dynamic>> _groupItems(List<dynamic> items) {
    final Map<String, List<dynamic>> map = {};
    for (final item in items) {
      String groupName;

      // Verifica se o item é um Variant e tenta pegar o nome do grupo pai
      if (item is Variant) {
        // Você precisará garantir que seu modelo 'Variant' tenha essa informação.
        // Se não tiver, o nome do próprio Variant pode ser um bom substituto.
        groupName = item.name ?? item.name;
      }
      // Se for um produto (para Cross-Sell), agrupamos em uma categoria genérica
      else if (item is Product) {
        groupName = 'Outros Produtos';
      }
      // Fallback para qualquer outro caso
      else {
        groupName = 'Desconhecido';
      }

      if (map[groupName] == null) {
        map[groupName] = [];
      }
      map[groupName]!.add(item);
    }
    return map;
  }


  /// Constrói o cabeçalho da tela
// ✨ Adicionamos um novo parâmetro opcional {VoidCallback? onClear}
  Widget _buildHeader(BuildContext context, String groupName, {VoidCallback? onClear}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Ajuste no padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // O título ocupa o espaço disponível à esquerda
              Expanded(
                child: Text(
                  "Adicione complementos ao grupo \"$groupName\"",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Só mostra a lixeira se a função onClear for fornecida
              if (onClear != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                  tooltip: "Limpar selecionados",
                  onPressed: onClear,
                ),
            ],
          ),
        ],
      ),
    );
  }
  /// Constrói o card de item customizado
  Widget _buildItemCard(BuildContext context, dynamic item, bool isSelected) {
    final cubit = context.read<CreateComplementGroupCubit>();
    final imageUrl = (item is Product && item.images.isNotEmpty)
        ? item.images.first.url
        : null;

    final isPrincipal = (item is Product);

    return InkWell(
      onTap: () => cubit.toggleItemForCopy(item),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) => cubit.toggleItemForCopy(item),
              ),
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    imageUrl,
                    width: 75,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildItemTag(isPrincipal ? "Item principal" : "Complemento"),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Disponível em: Bebidas",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a tag "Item principal" ou "Complemento"
  Widget _buildItemTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }
}