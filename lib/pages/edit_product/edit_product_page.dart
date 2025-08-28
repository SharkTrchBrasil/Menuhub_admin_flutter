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

import '../../core/enums/cashback_type.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.storeId,
    this.id,
    this.product,
    this.category,
    this.onSaved,
    this.isInWizard = false, // ✅ 1. NOVO PARÂMETRO
  });

  final int storeId;
  final Category? category;
  final Product? product;
  final int? id;
  final void Function(Product)? onSaved;
  final bool isInWizard;

  @override
  // ✅ 2. STATE COM NOME PÚBLICO
  State<EditProductPage> createState() => EditProductPageState();
}


class EditProductPageState extends State<EditProductPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProductRepository repository = getIt();


  Product? _editedProduct; // Nossa ÚNICA cópia local para o formulário
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }


  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_editedProduct == null) return false;

    // A lógica de salvamento que já estava no seu botão
    final result = await repository.saveProduct(widget.storeId, _editedProduct!);

    return result.fold(
          (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: error")));
        return false; // Falha
      },
          (savedProduct) {
        widget.onSaved?.call(savedProduct);
        return true; // Sucesso
      },
    );
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
         // category: widget.category, // Pré-seleciona a categoria se vier dela
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
            final productFromState = currentState.activeStore?.relations.products.firstWhere((p) => p.id == widget.id);
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
    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, state) {
        if (state is StoresManagerLoaded && _editedProduct != null) {
          try {
            // ✅ 4. CORREÇÃO NO ACESSO AOS DADOS
            final updatedProduct = state.activeStore?.relations.products.firstWhere((p) => p.id == _editedProduct!.id);
            if (updatedProduct != null && updatedProduct != _editedProduct) {
              setState(() { _editedProduct = updatedProduct; });
            }
          } catch (e) {
            if (mounted) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este produto foi removido.")));
            }
          }
        }
      },
      // ✅ 5. BUILD CONDICIONAL
      child: widget.isInWizard
          ? _buildWizardContent()
          : _buildStandalonePage(),
    );
  }

  // MÉTODO PARA A PÁGINA COMPLETA (MODO NORMAL)
  Widget _buildStandalonePage() {
    if (_isLoading) return const Scaffold(body: Center(child: DotLoading()));
    if (_editedProduct == null) return const Scaffold(body: Center(child: Text("Produto não encontrado.")));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: ResponsiveBuilder.isMobile(context) ? AppBar(title: Text(_editedProduct!.name.isEmpty ? "Novo Produto" : _editedProduct!.name)) : null,
        backgroundColor: Colors.white,
        body: _buildWizardContent(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // MÉTODO PARA O CONTEÚDO DO FORMULÁRIO (REUTILIZADO)
  Widget _buildWizardContent() {
    if (_isLoading) return const Center(child: DotLoading());
    if (_editedProduct == null) return const Scaffold(body: Center(child: Text("Crie seu primeiro produto.")));

    final product = _editedProduct!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (ResponsiveBuilder.isDesktop(context) && !widget.isInWizard) _buildHeader(product),
          if (!widget.isInWizard) ...[ // Mostra abas apenas no modo standalone
            const TabBar(
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
          ] else ...[ // No modo wizard, mostra apenas o formulário principal
            Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildAboutProductTab(product)
                )
            )
          ]
        ],
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



        // ✅ --- INÍCIO DA NOVA SEÇÃO DE CASHBACK ---
        const Divider(height: 48),
        Text('Regra de Cashback', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        // Dropdown para selecionar o TIPO de cashback
        DropdownButtonFormField<CashbackType>(
          value: product.cashbackType,
          decoration: const InputDecoration(
            labelText: 'Tipo de Cashback',
            border: OutlineInputBorder(),
          ),
          items: CashbackType.values.map((type) {
            return DropdownMenuItem<CashbackType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              // Se mudar para 'none', zera o valor.
              final resetValue = (newValue == CashbackType.none) ? 0 : product.cashbackValue;
              setState(() {
                _editedProduct = product.copyWith(
                  cashbackType: newValue,
                  cashbackValue: resetValue,
                );
              });
            }
          },
        ),

        // O campo de VALOR só aparece se o tipo não for 'Nenhum'
        if (product.cashbackType != CashbackType.none) ...[
          const SizedBox(height: 24),
          AppTextField(
            // Usamos um `key` para forçar o widget a reconstruir quando o tipo muda,
            // atualizando assim o `initialValue` e os formatters.
            key: ValueKey('cashback_value_${product.cashbackType.name}'),

            // O valor inicial depende do tipo
            initialValue: product.cashbackType == CashbackType.fixed
                ? UtilBrasilFields.obterReal(product.cashbackValue / 100)
                : product.cashbackValue.toString(),

            // O título também é dinâmico
            title: product.cashbackType == CashbackType.fixed
                ? 'Valor Fixo (R\$)'
                : 'Percentual (%)',

            keyboardType: TextInputType.number,

            // O formatador também é dinâmico
            formatters: product.cashbackType == CashbackType.fixed
                ? [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)]
                : [FilteringTextInputFormatter.digitsOnly],

            onChanged: (value) {
              if (product.cashbackType == CashbackType.fixed) {
                final money = UtilBrasilFields.converterMoedaParaDouble(value ?? '');
                setState(() => _editedProduct = product.copyWith(cashbackValue: (money * 100).round()));
              } else {
                setState(() => _editedProduct = product.copyWith(cashbackValue: int.tryParse(value ?? '0')));
              }
            },
            hint: '',
          ),
        ],















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