import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/product.dart';
import '../../../../models/variant.dart';
import '../../../../models/variant_option.dart';
import '../../cubit/create_complement_cbit.dart';
import '../../cubit/create_complement_state.dart';
import 'create_group_panel_step1.dart';



/// Widget para o Passo 3: Adicionar complementos ao grupo.
class CreateGroupStep3Panel extends StatefulWidget {
  final GroupType groupType;
  final String groupName;


  const CreateGroupStep3Panel({
    super.key,
    required this.groupType,
    required this.groupName,

  });

  @override
  State<CreateGroupStep3Panel> createState() => _CreateGroupStep3PanelState();
}

// Sub-estado para o modo Ingredientes/Especificações
enum IngredientMode { choice, create, copy }

class _CreateGroupStep3PanelState extends State<CreateGroupStep3Panel> {
  IngredientMode _ingredientMode = IngredientMode.choice;
  // ✅ Controller para o campo de busca
  final _searchController = TextEditingController();

  // ✅ NOVO: Controllers para o formulário de criação
  final _createNameController = TextEditingController();
  final _createPriceController = TextEditingController();
  final _createDescriptionController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    // ✅ NOVO: Fazer o dispose dos novos controllers
    _createNameController.dispose();
    _createPriceController.dispose();
    _createDescriptionController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(context, widget.groupName),


          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24),
              child: _buildPanelBody(),
            ),
          ),

          _buildAddedComplementsList(),

          _buildPanelFooter(),
        ],
      ),
    );
  }
  /// ✅ NOVO: Widget que lê o estado do Cubit e mostra a lista de complementos
  Widget _buildAddedComplementsList() {
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        if (state.complements.isEmpty) {
          return const SizedBox.shrink(); // Não mostra nada se a lista estiver vazia
        }
        return Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${state.complements.length} complementos adicionados:", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Exibe a lista de complementos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.complements.length,
                itemBuilder: (context, index) {
                  final complement = state.complements[index];
                  return ListTile(
                    title: Text(complement.resolvedName),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        context.read<CreateComplementGroupCubit>().removeComplement(complement);
                      },
                    ),
                  );
                },
              ),
              const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Constrói o corpo do painel com base no GroupType
  Widget _buildPanelBody() {
    switch (widget.groupType) {
      case GroupType.ingredients:
      case GroupType.specifications:
        return _buildIngredientsOrSpecsUI();
      case GroupType.crossSell:
        return _buildCrossSellUI();
      case GroupType.disposables:
        return _buildDisposablesUI();
      default:
        return const Center(child: Text("Tipo de grupo não reconhecido."));
    }
  }

  /// UI para Ingredientes e Especificações (com a escolha Criar/Copiar)
  Widget _buildIngredientsOrSpecsUI() {
    switch (_ingredientMode) {
      case IngredientMode.choice:
        return Column(
          children: [
            _buildChoiceCard(
              title: "Criar novo complemento",
              subtitle: "Crie um produto novo ou um produto industrializado.",
              icon: Icons.add_circle_outline,
              onTap: () => setState(() => _ingredientMode = IngredientMode.create),
            ),
            const SizedBox(height: 16),
            _buildChoiceCard(
              title: "Copiar complemento",
              subtitle: "Reaproveite produtos que já existem no seu cardápio.",
              icon: Icons.copy_outlined,
              onTap: () => setState(() => _ingredientMode = IngredientMode.copy),
            ),
          ],
        );
      case IngredientMode.create:
        return _buildCreateComplementForm();
      case IngredientMode.copy:
        return _buildCopyComplementUI("Reaproveite produtos que já existem");
    }
  }

  /// UI para Cross-Sell (direto para a tela de cópia/seleção)
  Widget _buildCrossSellUI() {
    return _buildCopyComplementUI("Selecione itens do seu cardápio para sugerir");
  }

  /// UI para Descartáveis (lista de opções configuráveis)
  Widget _buildDisposablesUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Configure as opções de descartáveis para o cliente:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        _buildDisposableOptionCard("Precisa de talheres?"),
        _buildDisposableOptionCard("Precisa de guardanapo?"),
        _buildDisposableOptionCard("Precisa de sachês? (sal, pimenta, etc)"),
      ],
    );
  }

  /// Constrói o formulário para criar um novo complemento
  Widget _buildCreateComplementForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _ingredientMode = IngredientMode.choice),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Voltar para a seleção"),
        ),
        const SizedBox(height: 16),
        // ✅ Conectado ao controller
        TextField(
          controller: _createNameController,
          decoration: const InputDecoration(labelText: "Nome do Produto*", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        // ✅ Conectado ao controller
        TextField(
          controller: _createDescriptionController,
          decoration: const InputDecoration(labelText: "Descrição", border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () { /* TODO: Lógica para pegar imagem */ },
          icon: const Icon(Icons.image_outlined),
          label: const Text("Adicionar uma imagem"),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 16),
        // ✅ Conectado ao controller
        TextField(
          controller: _createPriceController,
          decoration: const InputDecoration(labelText: "Preço (R\$)*", border: OutlineInputBorder(), prefixText: "R\$ "),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_createNameController.text.isNotEmpty && _createPriceController.text.isNotEmpty) {

                // ✅ AJUSTE AQUI: Crie o VariantOption com os campos corretos
                final newComplement = VariantOption(
                  // O id e variant_id serão nulos, pois é um novo item

                  // O schema `VariantOptionCreate` espera estes campos:
                  name_override: _createNameController.text,
                  price_override: ((double.tryParse(_createPriceController.text.replaceAll(',', '.')) ?? 0) * 100).toInt(),
                  available: true,
                  resolvedName: '',
                  resolvedPrice: null, // Valor padrão
                );

                context.read<CreateComplementGroupCubit>().addComplement(newComplement);

                // Limpa os campos e volta para a tela de escolha
                _createNameController.clear();
                _createPriceController.clear();
                _createDescriptionController.clear();
                setState(() => _ingredientMode = IngredientMode.choice);
              }
            },
            child: const Text("Adicionar ao grupo"),
          ),
        ),
      ],
    );
  }



  /// Constrói a UI de busca e seleção de complementos (para Copiar e Cross-Sell)
  Widget _buildCopyComplementUI(String title) {
    final groupType = widget.groupType; // Pega o tipo de grupo do widget principal

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupType == GroupType.ingredients || groupType == GroupType.specifications)
          TextButton.icon(
            onPressed: () => setState(() => _ingredientMode = IngredientMode.choice),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Voltar para a seleção"),
          ),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),

        // ✅ Campo de busca funcional
        TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<CreateComplementGroupCubit>().searchItemsToCopy(value);
          },
          decoration: const InputDecoration(
            labelText: "Buscar item...",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Lista dinâmica construída a partir do estado do Cubit
        BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
          builder: (context, state) {
            if (state.itemsAvailableToCopy.isEmpty && _searchController.text.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text("Nenhum item encontrado.")),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.itemsAvailableToCopy.length,
              itemBuilder: (context, index) {
                final item = state.itemsAvailableToCopy[index];

                // Extrai os dados, seja de um Product ou de um Variant
                final int itemId = (item is Product) ? item.id! : (item as Variant).id!;
                final String itemName = item.name;

                final isSelected = state.selectedToCopyIds.contains(itemId);

                return RadioListTile<int?>(
                  value: item.id,
                  groupValue: state.selectedVariantToCopy?.id,
                  onChanged: (_) {
                    // ✅ Chama o novo método do Cubit para guardar a seleção
                    context.read<CreateComplementGroupCubit>().selectVariantToCopy(item);
                  },
                  title: Text(item.name),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),

        // ✅ Botão para adicionar os itens selecionados
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<CreateComplementGroupCubit>().addSelectedItemsToGroup();
              // Volta para a tela de escolha se for o fluxo de ingredientes
              if (groupType == GroupType.ingredients || groupType == GroupType.specifications) {
                setState(() => _ingredientMode = IngredientMode.choice);
              }
            },
            child: const Text("Adicionar Selecionados"),
          ),
        ),
      ],
    );
  }






  /// Constrói um card de opção para a tela de Descartáveis
  Widget _buildDisposableOptionCard(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                TextButton(onPressed: (){}, child: const Text("Alterar")),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Text("Aplicativo iFood", style: TextStyle(color: Colors.grey))),
                SizedBox(
                  width: 100,
                  child: TextField(decoration: InputDecoration(prefixText: "R\$ ")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Cole estes métodos dentro da classe _CreateGroupStep3PanelState

  Widget _buildPanelHeader(BuildContext context, String groupName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Criar novo grupo", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Agora, adicione complementos ao grupo "$groupName"'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: true),
                const SizedBox(width: 8),
                Text("Passo 3 de 3", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        IconButton(onPressed: (){
          context.read<CreateComplementGroupCubit>().goBack();
        }, icon: const Icon(Icons.close)),
      ],
    );
  }

  /// Constrói o rodapé com botões conectados ao Cubit
  Widget _buildPanelFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => context.read<CreateComplementGroupCubit>().goBack(),
            child: const Text("Voltar"),
          ),
          const SizedBox(width: 16),
          // ✅ Botão de salvar agora mostra um estado de loading
          BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.status == FormStatus.loading
                    ? null // Desabilita o botão enquanto carrega
                    : () => context.read<CreateComplementGroupCubit>().saveGroup(),
                child: state.status == FormStatus.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Salvar Grupo"),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            )),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para o indicador de passo (as barrinhas)
  Widget _buildStepIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}