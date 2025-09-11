import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';


import '../../../widgets/ds_primary_button.dart';
import '../cubit/category_link_cubit.dart';

class CategoryLinkWizard extends StatelessWidget {
  final Product product;
  final List<Category> allCategories;

  const CategoryLinkWizard({
    super.key,
    required this.product,
    required this.allCategories,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryLinkCubit(product: product),
      child: BlocListener<CategoryLinkCubit, CategoryLinkState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            context.pop(state.linkData);
          }
        },
        child: const _CategoryLinkWizardView(),
      ),
    );
  }
}

class _CategoryLinkWizardView extends StatefulWidget {
  const _CategoryLinkWizardView();
  @override
  State<_CategoryLinkWizardView> createState() => _CategoryLinkWizardViewState();
}

class _CategoryLinkWizardViewState extends State<_CategoryLinkWizardView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryLinkCubit, CategoryLinkState>(
      listener: (context, state) {
        if (_pageController.page?.round() != state.currentStep - 1) {
          _pageController.animateToPage(state.currentStep - 1,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CategoryLinkCubit>();
        return Scaffold(
          appBar: _buildAppBar(context, state, cubit),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Step1SelectCategory(
                allCategories: (context.findAncestorWidgetOfExactType<CategoryLinkWizard>())!.allCategories,
                product: state.linkData.product!,
              ),
              _Step2SetPriceAndDetails(link: state.linkData),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state, cubit),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CategoryLinkState state, CategoryLinkCubit cubit) {
    return AppBar(
      title: const Text("Adicionar a Categoria"),
      leading: state.currentStep == 1
          ? IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())
          : IconButton(icon: const Icon(Icons.arrow_back), onPressed: cubit.previousStep),
    );
  }

  Widget _buildBottomBar(BuildContext context, CategoryLinkState state, CategoryLinkCubit cubit) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (state.currentStep == 1)
            DsButton(
              onPressed: state.linkData.category != null ? cubit.nextStep : null,
              label: 'Continuar',
             // style: DsButtonStyle.secondary,

            ),
          if (state.currentStep == 2)
            DsButton(
              onPressed: cubit.submitLink,
              label: 'Concluir',

            ),
        ],
      ),
    );
  }
}


// ================== PASSO 1 ==================
class _Step1SelectCategory extends StatelessWidget {
  final List<Category> allCategories;
  final Product product;

  const _Step1SelectCategory({required this.allCategories, required this.product});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryLinkCubit>();

    // ✅ 1. PEGA OS IDs DAS CATEGORIAS ONDE O PRODUTO JÁ ESTÁ
    final existingCategoryIds = product.categoryLinks.map((link) => link.categoryId).toSet();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text("Escolha uma categoria do seu cardápio", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        // Constrói a lista de categorias
        ...allCategories.map((category) {
          // ✅ 2. VERIFICA SE A CATEGORIA ATUAL DA LISTA JÁ FOI ADICIONADA
          final isAlreadyAdded = existingCategoryIds.contains(category.id);

          return ListTile(
            title: Text(category.name),

            // ✅ 3. DESABILITA O ITEM SE JÁ FOI ADICIONADO
            enabled: !isAlreadyAdded,


            // ✅ 5. SÓ PERMITE O CLIQUE SE NÃO FOI ADICIONADO
            onTap: isAlreadyAdded ? null : () => cubit.categorySelected(category),
          );
        }).toList(),
      ],
    );
  }
}

// ================== PASSO 2 ==================
class _Step2SetPriceAndDetails extends StatefulWidget {
  final ProductCategoryLink link;
  const _Step2SetPriceAndDetails({required this.link});

  @override
  State<_Step2SetPriceAndDetails> createState() => _Step2SetPriceAndDetailsState();
}

class _Step2SetPriceAndDetailsState extends State<_Step2SetPriceAndDetails> {
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: UtilBrasilFields.obterReal(widget.link.price / 100));
    _pdvController = TextEditingController(text: widget.link.posCode ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryLinkCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Defina preço e código PDV para '${widget.link.product?.name ?? ""}' na categoria '${widget.link.category!.name}'", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Preço', border: OutlineInputBorder(), prefixText: 'R\$ '),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
            onChanged: cubit.priceChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pdvController,
            decoration: const InputDecoration(labelText: 'Código PDV (Opcional)', border: OutlineInputBorder()),
            onChanged: cubit.posCodeChanged,
          ),
          // Adicione aqui os campos de preço promocional se desejar
        ],
      ),
    );
  }
}