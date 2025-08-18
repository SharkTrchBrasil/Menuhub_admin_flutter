import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/create_category_cubit.dart';
import 'cubit/create_category_state.dart';

class CreateCategoryPage extends StatelessWidget {
  const CreateCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateCategoryCubit(),
      child: const _CreateCategoryView(),
    );
  }
}

class _CreateCategoryView extends StatefulWidget {
  const _CreateCategoryView();

  @override
  State<_CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<_CreateCategoryView> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCategoryCubit, CreateCategoryState>(
      listener: (context, state) {
        // Listener para controlar o TabController do wizard de pizza
        if (state.selectedType == CategoryType.pizza) {
          if (_tabController == null) {
            _tabController = TabController(length: 5, vsync: this);
          }
          // Move para a aba correta quando o estado do cubit mudar
          _tabController?.animateTo(state.pizzaStep.index);
        } else {
          _tabController?.dispose();
          _tabController = null;
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateCategoryCubit>();

        return Scaffold(
          appBar: AppBar(
            // O botão voltar agora tem uma lógica inteligente
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (state.selectedType != null) {
                  cubit.changeType();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(state.selectedType == null ? 'Nova Categoria' : 'Criar Categoria'),
          ),
          body: state.selectedType == null
              ? _buildChoiceView(cubit) // Mostra a tela de escolha
              : _buildFormView(state, cubit), // Mostra o wizard de criação
          bottomNavigationBar: _buildBottomButtons(state, cubit),
        );
      },
    );
  }

  // O corpo da página quando um tipo foi selecionado
  Widget _buildFormView(CreateCategoryState state, CreateCategoryCubit cubit) {
    if (state.selectedType == CategoryType.mainItem) {
      return _buildMainItemForm(state, cubit);
    }

    if (state.selectedType == CategoryType.pizza) {
      return _buildPizzaWizard(state, cubit);
    }

    return const SizedBox.shrink();
  }

  // A UI do Wizard de Pizza com as Abas
  Widget _buildPizzaWizard(CreateCategoryState state, CreateCategoryCubit cubit) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(children: [
            const Text("Tipo da categoria: Pizza", style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: cubit.changeType, child: const Text("Alterar"))
          ]),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => cubit.goToPizzaStep(PizzaCreationStep.values[index]),
          tabs: const [
            Tab(text: 'Detalhes'),
            Tab(text: 'Tamanho'),
            Tab(text: 'Massa'),
            Tab(text: 'Borda'),
            Tab(text: 'Disponibilidade'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Desabilita o arrastar
            children: [
              _buildPizzaDetailsForm(state, cubit), // Formulário de Detalhes
              _buildPizzaSizeForm(), // Formulário de Tamanhos
              Center(child: Text("Formulário de Massa")),
              Center(child: Text("Formulário de Borda")),
              Center(child: Text("Formulário de Disponibilidade")),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para os botões de rodapé
  Widget _buildBottomButtons(CreateCategoryState state, CreateCategoryCubit cubit) {
    // Não mostra botões na tela de escolha inicial
    if (state.selectedType == null) return const SizedBox.shrink();

    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () {
              // Lógica de cancelar (voltar ou limpar estado)
              if (state.selectedType != null) cubit.changeType();
              else Navigator.of(context).pop();
            }, child: const Text("Cancelar")),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (state.selectedType == CategoryType.mainItem) {
                  cubit.saveCategory(); // Botão final para item principal
                } else {
                  cubit.nextPizzaStep(); // Botão "Continuar" para o wizard de pizza
                }
              },
              child: Text(
                  state.selectedType == CategoryType.pizza && state.pizzaStep != PizzaCreationStep.availability
                      ? "Continuar"
                      : "Criar Categoria"
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets de Formulário (placeholders para simplicidade)
  Widget _buildChoiceView(CreateCategoryCubit cubit) {
    return Center(child: TextButton(onPressed: () => cubit.selectType(CategoryType.mainItem), child: Text("Escolher 'Itens Principais'")));
  }
  Widget _buildMainItemForm(CreateCategoryState state, CreateCategoryCubit cubit) {
    return Padding(padding: const EdgeInsets.all(16.0), child: TextField(
      onChanged: cubit.updateCategoryName,
      decoration: InputDecoration(labelText: 'Nome da Categoria'),
    ));
  }
  Widget _buildPizzaDetailsForm(CreateCategoryState state, CreateCategoryCubit cubit) {
    return Padding(padding: const EdgeInsets.all(16.0), child: TextField(
      onChanged: cubit.updateCategoryName,
      decoration: InputDecoration(labelText: 'Nome da Categoria de Pizza'),
    ));
  }
  Widget _buildPizzaSizeForm() {
    return Center(child: Text("Aqui vai o complexo formulário de Tamanhos de Pizza, com inputs e lista."));
  }
}