import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/variant.dart';

import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';

class Step1SelectGroup extends StatefulWidget {
  const Step1SelectGroup({super.key});

  @override
  State<Step1SelectGroup> createState() => _Step1SelectGroupState();
}

class _Step1SelectGroupState extends State<Step1SelectGroup> {
  // ✅ O `_selectedGroup` foi REMOVIDO. O resto do estado local está ok.
  final _searchController = TextEditingController();
  // Variant? _selectedGroup; // ❌ REMOVIDO
  List<Variant> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    // ✅ O `initState` agora também inicializa o texto da busca com o que já estiver salvo
    final cubit = context.read<CreateComplementGroupCubit>();
    _filteredGroups = cubit.state.itemsAvailableToCopy.cast<Variant>();

    // Sincroniza o valor selecionado no Cubit com o controller (se houver)
    // Isso é opcional, mas uma boa prática
    _searchController.text = cubit.state.groupName; // Supondo que você queira salvar a busca

    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  void _filterGroups() {
    // ... (esta função não precisa de alterações)
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
    // ✅ Usamos `context.watch` para que a tela se reconstrua quando a seleção mudar no Cubit
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding( // Adicionado SafeArea e Padding aqui
          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Primeiro, selecione o grupo que deseja reutilizar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
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
              Expanded(
                child: Builder( // Usamos Builder para garantir que `state` seja o mais recente
                  builder: (context) {
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
                        // Passamos o grupo selecionado do Cubit e o próprio Cubit
                        return _buildGroupItem(context, variant, state.selectedVariantToCopy);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: WizardFooter(
        showBackButton: true,
        onBack: () => context.read<CreateComplementGroupCubit>().goBack(),
        // ✅ A condição agora verifica o estado do Cubit
        onContinue: state.selectedVariantToCopy == null
            ? null
            : () {
          // A ação de continuar agora usa o valor salvo no Cubit
          context.read<CreateComplementGroupCubit>().selectGroupToCopy(state.selectedVariantToCopy!);
        },
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, Variant group, Variant? selectedGroupFromState) {
    // ✅ A variável `isSelected` agora compara com o valor do estado do Cubit
    final bool isSelected = selectedGroupFromState == group;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          // ✅ `onTap` agora chama o método do Cubit para salvar a seleção
          context.read<CreateComplementGroupCubit>().setSelectedGroupToCopy(group);
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
              Radio<Variant>(
                value: group,
                // ✅ `groupValue` agora vem do estado do Cubit
                groupValue: selectedGroupFromState,
                onChanged: (Variant? value) {
                  // ✅ `onChanged` também chama o método do Cubit
                  context.read<CreateComplementGroupCubit>().setSelectedGroupToCopy(value);
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