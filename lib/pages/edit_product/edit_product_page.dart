// ARQUIVO: edit_product_page.dart (VERSÃO CORRIGIDA E SIMPLIFICADA)

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/edit_product/widgets/tabs/complement_tab.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/mobile_mockup.dart';
import 'package:brasil_fields/brasil_fields.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.storeId,
    this.id,
    this.product,
    this.category,
    this.onSaved,
  });

  final int storeId;
  final Category? category;
  final Product? product; // Objeto recebido via 'extra' do go_router
  final int?  id;
  final void Function(Product)? onSaved;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProductRepository repository = getIt();


  Product? _editedProduct; // Nossa ÚNICA cópia local para o formulário
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final bool isCreateMode = widget.id == null;

    if (isCreateMode) {
      // MODO CRIAR: Começamos com um objeto Product novo e vazio.
      setState(() {
        _editedProduct = Product(
          name: '',
          description: '',
          available: true,
          category: widget.category, // Pré-seleciona a categoria se vier dela
          // Defina outros valores padrão aqui se necessário
        );
        _isLoading = false;
      });
    } else {
      // MODO EDITAR: Usa a lógica que já tínhamos.
      if (widget.product != null) {
        // Usa o produto passado via 'extra' para um carregamento rápido.
        setState(() {
          _editedProduct = widget.product;
          _isLoading = false;
        });
      } else {
        // Fallback: busca o produto no Cubit pelo ID (para links diretos).
        final currentState = context.read<StoresManagerCubit>().state;
        if (currentState is StoresManagerLoaded) {
          try {
            final productFromState = currentState.activeStore?.products.firstWhere((p) => p.id == widget.id);
            setState(() {
              _editedProduct = productFromState;
              _isLoading = false;
            });
          } catch (e) {
            // Trata o erro se o produto não for encontrado
            setState(() { _isLoading = false; });
            if (mounted) context.pop();
          }
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // O BlocListener mantém a página sincronizada com o estado global
    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, state) {
        if (state is StoresManagerLoaded && _editedProduct != null) {
          try {
            final updatedProduct = state.activeStore?.products.firstWhere((p) => p.id == _editedProduct!.id);
            if (updatedProduct != null && updatedProduct != _editedProduct) {
              print("🔄 EditProductPage: Recebendo atualização externa e atualizando a UI.");
              setState(() {
                _editedProduct = updatedProduct;
              });
            }
          } catch (e) {
            print("Produto ID ${_editedProduct!.id} foi excluído externamente. Fechando a tela.");
            if (mounted) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este produto foi removido.")));
            }
          }
        }
      },
      // ✅ 3. BUILD SIMPLIFICADO
      // Removemos AnimatedBuilder e AppPageStatusBuilder
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: DotLoading()));
    }
    if (_editedProduct == null) {
      return const Scaffold(body: Center(child: Text("Produto não encontrado.")));
    }
    final product = _editedProduct!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: ResponsiveBuilder.isMobile(context) ? AppBar(title: Text(product.name.isEmpty ? "Novo Produto" : product.name)) : null,
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: Column(
            children: [
              if (ResponsiveBuilder.isDesktop(context)) _buildHeader(product),
              const TabBar(
                labelColor: Colors.black, indicatorColor: Colors.red, isScrollable: true, tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Sobre o produto'), Tab(text: 'Grupo de complementos'), Tab(text: 'Opções Avançadas'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAboutProductTab(product),
                    ComplementGroupsScreen(product: product),
                    _buildOptionsTab(product),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO ---

  Widget _buildHeader(Product product) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(product.name.isEmpty ? "Novo Produto" : product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAboutProductTab(Product product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formFields = _buildProductFormFields(product);
        if (constraints.maxWidth < 800) {
          return SingleChildScrollView(padding: const EdgeInsets.all(24), child: formFields);
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: formFields),
                  Expanded(flex: 3, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: ProductPhoneMockup(product: product),
                  )),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // ✅ 4. ONCHANGED AGORA SÓ USA setState
  Widget _buildProductFormFields(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          initialValue: product.name,
          title: 'Nome do produto',
          validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
          onChanged: (name) => setState(() => _editedProduct = product.copyWith(name: name ?? '')), hint: '',
        ),
        const SizedBox(height: 20),
        const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: product.description,
          minLines: 3, maxLines: 5,
          decoration: InputDecoration(hintText: 'Descreva seu produto', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          onChanged: (desc) => setState(() => _editedProduct = product.copyWith(description: desc)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                initialValue: UtilBrasilFields.obterReal((product.basePrice ?? 0) / 100),
                title: 'Preço',
                formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                onChanged: (value) {
                  final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                  setState(() => _editedProduct = product.copyWith(basePrice: (money * 100).floor()));
                }, hint: '',
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AppTextField(
                initialValue: UtilBrasilFields.obterReal((product.costPrice ?? 0) / 100),
                title: 'Custo do produto',
                formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                onChanged: (value) {
                  final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                  setState(() => _editedProduct = product.copyWith(costPrice: (money * 100).floor()));
                }, hint: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),


        AppProductImageFormField(
          initialValue: product.image,
          title: 'Imagem',
          onChanged: (newImageModel) {
            setState(() {
              // ✅ CORREÇÃO: Passando o valor diretamente, sem a função
              _editedProduct = product.copyWith(image: newImageModel);
            });
          },
          validator: (imageModel) {
            if (imageModel == null && _editedProduct?.image == null) {
              return 'Selecione uma imagem';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsTab(Product product) {
    return ListView( // Usar ListView para garantir a rolagem se houver muitos itens
      padding: const EdgeInsets.all(24),
      children: [
        SwitchListTile(
          title: const Text('Promoção?'),
          value: product.activatePromotion,
          onChanged: (value) => setState(() => _editedProduct = product.copyWith(activatePromotion: value)),
        ),
        if (product.activatePromotion)
          AppTextField(
            initialValue: UtilBrasilFields.obterReal((product.promotionPrice ?? 0) / 100),
            title: 'Preço promocional',
            formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
            onChanged: (value) {
              final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
              setState(() => _editedProduct = product.copyWith(promotionPrice: (money * 100).floor()));
            }, hint: '',
          ),
        SwitchListTile(
          title: const Text('Em destaque'),
          value: product.featured,
          onChanged: (value) => setState(() => _editedProduct = product.copyWith(featured: value)),
        ),
        SwitchListTile(
          title: const Text('Produto disponível no cardápio?'),
          value: product.available,
          onChanged: (value) => setState(() => _editedProduct = product.copyWith(available: value)),
        ),
        SwitchListTile(
          title: const Text('Controlar estoque'),
          value: product.controlStock,
          onChanged: (value) => setState(() => _editedProduct = product.copyWith(controlStock: value)),
        ),
        if (product.controlStock) ...[
          AppTextField(
            initialValue: product.stockQuantity.toString(),
            title: 'Estoque',
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => _editedProduct = product.copyWith(stockQuantity: int.tryParse(value ?? ''))), hint: '',
          ),
          AppTextField(
            initialValue: product.minStock.toString(),
            title: 'Estoque Mínimo',
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => _editedProduct = product.copyWith(minStock: int.tryParse(value ?? ''))), hint: '',
          ),
        ],
        AppTextField(
          initialValue: product.ean,
          title: 'EAN/GTIN',
          onChanged: (value) => setState(() => _editedProduct = product.copyWith(ean: value)), hint: '',
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (ResponsiveBuilder.isDesktop(context))
            TextButton(onPressed: () => context.pop(), child: const Text("Cancelar")),
          const SizedBox(width: 16),
          Expanded(
            child: AppPrimaryButton(
              // ✅ 5. BOTÃO SALVAR USA O ESTADO LOCAL
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final result = await repository.saveProduct(widget.storeId, _editedProduct!);

                  result.fold(
                        (error) {
                      // Tratar erro

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: error")));

                    },
                        (savedProduct) {
                      widget.onSaved?.call(savedProduct);
                      if (mounted) context.pop();
                    },
                  );
                }
              },
              label: "Salvar alterações",
            ),
          ),
        ],
      ),
    );
  }
}