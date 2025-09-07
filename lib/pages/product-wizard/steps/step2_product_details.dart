
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/widgets/mobile_mockup.dart'; // Importe seu mockup


import 'package:flutter/services.dart';

import '../../../../core/enums/product_type.dart';
import '../../../../models/image_model.dart';
import '../../../../widgets/app_image_form_field.dart';

import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';


class Step2ProductDetails extends StatefulWidget {
  const Step2ProductDetails({super.key});

  @override
  State<Step2ProductDetails> createState() => _Step2ProductDetailsState();
}

class _Step2ProductDetailsState extends State<Step2ProductDetails> {
  // ✅ 1. Controladores locais para os campos do formulário
  late final TextEditingController _searchController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late final TextEditingController _stockQuantityController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductWizardCubit>();
    final initialProduct = cubit.state.productInCreation;

    _searchController = TextEditingController();
    _nameController = TextEditingController(text: initialProduct.name);
    _descriptionController = TextEditingController(text: initialProduct.description);
    _stockQuantityController = TextEditingController(text: initialProduct.stockQuantity.toString());

    // ✨ 1. ADICIONE LISTENERS PARA ATUALIZAR O CUBIT EM TEMPO REAL
    _nameController.addListener(() {
      cubit.updateProduct(cubit.state.productInCreation.copyWith(name: _nameController.text));
    });
    _descriptionController.addListener(() {
      cubit.updateProduct(cubit.state.productInCreation.copyWith(description: _descriptionController.text));
    });
    _stockQuantityController.addListener(() {
      final quantity = int.tryParse(_stockQuantityController.text) ?? 0;
      cubit.updateProduct(cubit.state.productInCreation.copyWith(stockQuantity: quantity));
    });


  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();

    _stockQuantityController.dispose();
    super.dispose();
  }


  void _syncControllersWithState(ProductWizardState state) {
    final product = state.productInCreation;
    if (_nameController.text != product.name) {
      _nameController.text = product.name;
    }
    if (_descriptionController.text != product.description) {
      _descriptionController.text = product.description ?? '';
    }


    // ✅ 4. ADICIONE O SYNC PARA A QUANTIDADE DE ESTOQUE
    final stockString = state.productInCreation.stockQuantity.toString();
    if (_stockQuantityController.text != stockString) {
      _stockQuantityController.text = stockString;
    }
  }




    @override
    Widget build(BuildContext context) {
      // Usamos o BlocConsumer para sincronizar os controllers quando o estado muda
      return BlocConsumer<ProductWizardCubit, ProductWizardState>(
        listener: (context, state) {

          // ✅ CORREÇÃO APLICADA AQUI
          // Limpa a busca APENAS QUANDO um produto do catálogo é efetivamente selecionado.
          if (state.catalogProductSelected) {
            _searchController.clear();
          }

          // Sincroniza os controllers com o estado mais recente
          _syncControllersWithState(state);
        },

        builder: (context, state) {
          final mainContent = _buildMainContent(context, state);

          return ResponsiveBuilder(
            mobileBuilder: (context, constraints) =>
                mainContent,
            desktopBuilder: (context, constraints) =>
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: mainContent,
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32.0, right: 32.0, left: 32),
                        child: ProductPhoneMockup(
                            product: state.productInCreation),
                      ),
                    ),
                  ],
                ),
          );

    },
  );
}

// Método novo para criar os controles de estoque
  Widget _buildStockControls(BuildContext context, ProductWizardState state) {
    final product = state.productInCreation;
    final cubit = context.read<ProductWizardCubit>();
    final bool isStockControlled = product.controlStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text('Estoque', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),


        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            TextButton.icon(

              icon: Icon(isStockControlled ? Icons.inventory : Icons.add_business_outlined),
              label: Text(isStockControlled ? 'Gerenciando' : 'Ativar'),
              style: TextButton.styleFrom(
                foregroundColor: isStockControlled ? Colors.green : Theme.of(context).primaryColor,
              ),
              onPressed: () {
                // Ao clicar, inverte o valor de `controlStock` no Cubit
                cubit.updateProduct(
                  product.copyWith(controlStock: !isStockControlled),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Campo de quantidade que só aparece se o estoque estiver ativado
        if (isStockControlled)
          TextFormField(
            controller: _stockQuantityController,
            decoration: const InputDecoration(
              labelText: 'Quantidade em estoque',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Aceita apenas números
            onTapOutside: (_) {
              final quantity = int.tryParse(_stockQuantityController.text) ?? 0;
              cubit.updateProduct(product.copyWith(stockQuantity: quantity));
            },
          ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ProductWizardState state) {
    bool shouldShowSearch = state.productType == ProductType.INDUSTRIALIZED &&
        !state.catalogProductSelected;

    return SingleChildScrollView( // Adicionado
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: shouldShowSearch
            ? _buildSearchInterface(context, state)
            : _buildProductFormFields(context, state),
      ),
    );
  }


// --- INTERFACE DE BUSCA SIMPLIFICADA ---
  Widget _buildSearchInterface(BuildContext context, ProductWizardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Busque no catálogo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
            'Encontre um produto industrializado pelo nome ou código de barras para preencher as informações automaticamente.',
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        TextField(
          controller: _searchController,
          onChanged: (query) {
            context.read<ProductWizardCubit>().onSearchQueryChanged(query);
          },
          decoration: const InputDecoration(
            labelText: 'Nome do produto ou código de barras (EAN)',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 24),

        // Lógica de exibição dos resultados...
        if (state.searchStatus == SearchStatus.loading)
          const Center(child: Padding(padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator())),

        if (state.searchStatus == SearchStatus.failure)
          const Center(child: Text('Erro ao buscar. Tente novamente.',
              style: TextStyle(color: Colors.red))),

        if (state.searchStatus == SearchStatus.success &&
            state.searchResults.isEmpty && _searchController.text.length >= 3)
          Center(child: Text(
              'Nenhum produto encontrado para "${_searchController.text}".')),

        if (state.searchStatus == SearchStatus.success)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.searchResults.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, index) {
              final product = state.searchResults[index];
              return ListTile(
                // ✅ CORREÇÃO AQUI
                // Envolvemos a imagem em um SizedBox para garantir um tamanho fixo.
                leading: SizedBox(
                  width: 56, // Largura padrão do leading do ListTile
                  height: 56, // Altura padrão do leading do ListTile
                  child: product.imagePath != null
                      ? ClipRRect( // Adiciona bordas arredondadas para um visual melhor
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imagePath!.url!,
                      fit: BoxFit.cover,
                      // Garante que a imagem preencha o espaço
                      // Tratamento de erro para a imagem
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported,
                            color: Colors.grey);
                      },
                    ),
                  )
                      : const Icon(
                      Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
                title: Text(product.name),
                subtitle: Text(product.brand ?? 'Marca não informada'),
                trailing: ElevatedButton(
                  child: const Text('Selecionar'),
                  onPressed: () =>
                      context.read<ProductWizardCubit>().selectCatalogProduct(
                          product),
                ),
              );
            },
          ),
      ],
    );
  }

  // --- FORMULÁRIO DE DETALHES DO PRODUTO (PERFORMÁTICO) ---
  Widget _buildProductFormFields(BuildContext context, ProductWizardState state) {
    final product = state.productInCreation;
    final cubit = context.read<ProductWizardCubit>();
    final bool isReadOnly = state.isImported;

    return Form( // Envolva sua Column com um Form
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes do Produto', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // --- CAMPO NOME ---
          TextFormField(
            controller: _nameController, // ✅ Usa controller
            readOnly: isReadOnly,
            decoration: InputDecoration(
              labelText: 'Nome do produto*',
              filled: isReadOnly,
              fillColor: isReadOnly ? Colors.grey[200] : null,
              suffixIcon: isReadOnly
                  ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => cubit.resetToSearch(),
              )
                  : null,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,



          ),





          const SizedBox(height: 20),

          // --- CAMPO DESCRIÇÃO ---
          const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController, // ✅ Usa controller
            readOnly: isReadOnly,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Descreva seu produto',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: isReadOnly,
              fillColor: isReadOnly ? Colors.grey[200] : null,
            ),

          ),
          const SizedBox(height: 20),


          _buildStockControls(context, state),
          const SizedBox(height: 20),

          // --- CAMPO IMAGEM ---
          if (isReadOnly) ...[
            // ... (código para mostrar a imagem importada, sem alterações)
          ] else ...[
            AppProductImageFormField(
              initialValue: product.image,
              title: 'Imagem',
              onChanged: (newImageModel) {
                cubit.onImageChanged(newImageModel ?? ImageModel());
              },
              validator: (imageModel) {
                if (product.image?.file == null && (product.image?.url == null || product.image!.url!.isEmpty)) {
                  return 'Selecione uma imagem';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
