import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/create_complement_cbit.dart';
import '../../cubit/create_complement_state.dart';
import 'create_group_panel_step1.dart';

/// Widget para o Passo 2 da criação de um grupo de complementos.
class CreateGroupStep2Panel extends StatefulWidget {
  final GroupType groupType;


  const CreateGroupStep2Panel({
    super.key,
    required this.groupType,

  });

  @override
  State<CreateGroupStep2Panel> createState() => _CreateGroupStep2PanelState();
}

class _CreateGroupStep2PanelState extends State<CreateGroupStep2Panel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool _isRequired = false;
  int _minQty = 0;
  int _maxQty = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Função para lidar com o clique no botão de continuar
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {

      context.read<CreateComplementGroupCubit>().setGroupDetails(
        name: _nameController.text,
        isRequired: _isRequired,
        min: _minQty,
        max: _maxQty,
      );


    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPanelHeader(),
            // Usamos Expanded + SingleChildScrollView para evitar overflow com o teclado
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "Agora, defina o grupo e suas informações principais",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // --- Seção Condicional de Recomendações ---
                    if (widget.groupType == GroupType.specifications || widget.groupType == GroupType.disposables)
                      _buildRecommendations(),

                    // --- Campos do Formulário ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome do Grupo*",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "O nome do grupo é obrigatório.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildRequiredOptionalSelector(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildQuantityStepper("Qtd. mínima", _minQty, (newValue) => setState(() => _minQty = newValue))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildQuantityStepper("Qtd. máxima", _maxQty, (newValue) => setState(() => _maxQty = newValue))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildPanelFooter(),
          ],
        ),
      ),
    );
  }

  /// Constrói a seção de "Recomendações Inteligentes"
  Widget _buildRecommendations() {
    // Define quais recomendações mostrar com base no tipo
    final recommendations = widget.groupType == GroupType.specifications
        ? ["Ponto da carne", "Tamanho"]
        : ["Deseja descartáveis?"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recomendações inteligentes", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: recommendations.map((rec) {
              return ActionChip(
                label: Text(rec),
                onPressed: () {
                  setState(() {
                    _nameController.text = rec;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Constrói o seletor "Obrigatório / Opcional"
  Widget _buildRequiredOptionalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Este grupo é obrigatório ou opcional?"),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: false, label: Text("Opcional")),
            ButtonSegment<bool>(value: true, label: Text("Obrigatório")),
          ],
          selected: {_isRequired},
          onSelectionChanged: (newSelection) {
            setState(() {
              _isRequired = newSelection.first;
              // Lógica simples para ajustar quantidades ao mudar
              if (_isRequired && _minQty < 1) {
                _minQty = 1;
                if (_maxQty < 1) _maxQty = 1;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildPanelFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // DENTRO DE _buildPanelFooter()
          TextButton(
            onPressed: () {
              context.read<CreateComplementGroupCubit>().goBack();
            },
            child: const Text("Voltar"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(onPressed: _submit, child: const Text("Continuar")),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o cabeçalho do painel
  Widget _buildPanelHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Criar novo grupo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Indicador de progresso
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: false),
                const SizedBox(width: 8),
                Text("Passo 2 de 3", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed:(){
            context.read<CreateComplementGroupCubit>().goBack();
          }, // O botão de fechar pode funcionar como "Voltar"
          icon: const Icon(Icons.close),
        ),
      ],
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