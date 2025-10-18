
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/widgets/mobile_mockup.dart'; // Importe seu mockup


import 'package:flutter/services.dart';

import '../../../../core/enums/product_type.dart';


import '../../product_edit/widgets/product_details_form.dart';

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


  @override
  void initState() {
    super.initState();


    _searchController = TextEditingController();

  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
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
                      flex: 4,
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
       if(ResponsiveBuilder.isDesktop(context))
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

  // O seu método _buildProductFormFields agora fica assim:
  Widget _buildProductFormFields(BuildContext context, ProductWizardState state) {
    final cubit = context.read<ProductWizardCubit>();
    final product = state.productInCreation;

    return Column(
       // padding: EdgeInsets.zero,
      children: [

        ProductDetailsForm(
          product: product,
          isImported: state.isImported,
          onNameChanged: (name) => cubit.updateProduct(product.copyWith(name: name)),
          onDescriptionChanged: (desc) => cubit.updateProduct(product.copyWith(description: desc)),
          onControlStockToggled: cubit.controlStockToggled,
          onStockQuantityChanged: cubit.stockQuantityChanged,
          onServesUpToChanged: cubit.servesUpToChanged,
          onWeightChanged: cubit.weightChanged,
          onUnitChanged: cubit.unitChanged,
          onDietaryTagToggled: cubit.toggleDietaryTag,
          onBeverageTagToggled: cubit.toggleBeverageTag,
          videoUrl: product.videoUrl,
          onVideoUrlChanged: (url) => cubit.updateProduct(product.copyWith(videoUrl: url)),


          images: product.images,

          onImagesChanged: (newImages) => cubit.onImagesChanged(newImages),


          onVideoChanged: cubit.videoChanged,

        ),



      ],
    );



  }
}
