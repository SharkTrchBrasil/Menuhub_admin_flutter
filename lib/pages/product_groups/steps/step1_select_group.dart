import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/variant.dart';


import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';
import '../widgets/wizard_header.dart';

// ✨ 1. Convertido para StatefulWidget para gerenciar a busca e a seleção
class Step1SelectGroup extends StatefulWidget {
  const Step1SelectGroup({super.key});

  @override
  State<Step1SelectGroup> createState() => _Step1SelectGroupState();
}

class _Step1SelectGroupState extends State<Step1SelectGroup> {
  // ✨ 2. Variáveis de estado para controlar a busca e o item selecionado
  final _searchController = TextEditingController();
  Variant? _selectedGroup;
  List<Variant> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    // Inicializa a lista com todos os grupos disponíveis
    _filteredGroups = context.read<CreateComplementGroupCubit>().state.itemsAvailableToCopy.cast<Variant>();
    // Adiciona um listener para filtrar a lista em tempo real
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra a lista de grupos com base no texto da busca
  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    final allGroups = context.read<CreateComplementGroupCubit>().state.itemsAvailableToCopy.cast<Variant>();

    setState(() {
      if (query.isEmpty) {
        _filteredGroups = allGroups;
      } else {
        _filteredGroups = allGroups
            .where((group) => group.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ 3. Header reutilizável integrado
            WizardHeader(
              title: "Copiar grupo",
              currentStep: 1,
              totalSteps: 2,
              onClose: () => Navigator.of(context).pop(),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Primeiro, selecione o grupo que deseja reutilizar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // ✨ 4. Campo de busca adicionado
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Buscar grupos de complementos",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✨ 5. Lista agora usa a lista filtrada e o novo item de grupo
                    Expanded(
                      child: BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
                        builder: (context, state) {
                          if (state.itemsAvailableToCopy.isEmpty) {
                            return const Center(child: Text("Nenhum grupo para copiar."));
                          }
                          if (_filteredGroups.isEmpty) {
                            return const Center(child: Text("Nenhum grupo encontrado."));
                          }
                          return ListView.builder(
                            itemCount: _filteredGroups.length,
                            itemBuilder: (ctx, index) {
                              final variant = _filteredGroups[index];
                              return _buildGroupItem(variant);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✨ 6. Footer reutilizável e inteligente
            WizardFooter(
              showBackButton: true,
              onBack: () => context.read<CreateComplementGroupCubit>().goBack(),
              // O botão só fica ativo se um grupo for selecionado
              onContinue: _selectedGroup == null
                  ? null
                  : () {
                context.read<CreateComplementGroupCubit>().selectGroupToCopy(_selectedGroup!);
              },
            )
          ],
        ),
      ),
    );
  }

  /// Constrói o novo item da lista, agora mais interativo
  Widget _buildGroupItem(Variant group) {
    final bool isSelected = _selectedGroup == group;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGroup = group;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              // Usamos um Radio para garantir que apenas um item seja selecionado
              Radio<Variant>(
                value: group,
                groupValue: _selectedGroup,
                onChanged: (Variant? value) {
                  setState(() {
                    _selectedGroup = value;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Disponível em ${group.productLinks?.length ?? 0} produtos",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}