import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';
import '../widgets/wizard_header.dart';

/// Widget para o Passo 2 da criação de um grupo de complementos.
class Step2GroupDetails extends StatefulWidget {
  final GroupType groupType;

  const Step2GroupDetails({super.key, required this.groupType});

  @override
  State<Step2GroupDetails> createState() => _Step2GroupDetailsState();
}

class _Step2GroupDetailsState extends State<Step2GroupDetails> {
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
    return Column(
      children: [

        WizardHeader(
          title: "Criar novo grupo",
          currentStep: 2,
          totalSteps: 3,
          onClose: () => Navigator.of(context).pop(),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
            ),
            child: Form(
              key: _formKey,
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
                  if (widget.groupType == GroupType.specifications ||
                      widget.groupType == GroupType.disposables)
                    _buildRecommendations(),

                  const SizedBox(height: 24),
                  // --- Campos do Formulário ---
                  // CÓDIGO NOVO E CORRIGIDO
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormLabel("Nome do grupo*"), // Nosso novo label
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          // Trocamos labelText por hintText para dar uma dica dentro do campo
                          hintText: "Ex: Ingredientes extras do lanche",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "O nome do grupo é obrigatório.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildRulesSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        WizardFooter(
            onBack: () => context.read<CreateComplementGroupCubit>().goBack(),
            onContinue: _submit

        ),


      ],
    );
  }


  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Um pouco mais de destaque
          color: Colors.black87,
        ),
      ),
    );
  }



  // DENTRO DA CLASSE _Step2GroupDetailsState

  Widget _buildRulesSection() {
    // WIDGETS PRINCIPAIS (código inalterado)
    final dropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel("Este grupo é obrigatório ou opcional?"),
        // Nosso novo label
        DropdownButtonFormField<bool>(
          value: _isRequired,
          decoration: const InputDecoration(
            // Removemos o labelText daqui para não duplicar
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: false, child: Text("Opcional")),
            DropdownMenuItem(value: true, child: Text("Obrigatório")),
          ],
          onChanged: (newSelection) {
            if (newSelection == null) return;
            setState(() {
              _isRequired = newSelection;
              if (_isRequired) {
                if (_minQty < 1) _minQty = 1;
                if (_maxQty < 1) _maxQty = 1;
              } else {
                _minQty = 0;
              }
            });
          },
        ),
      ],
    );

    final minStepper = _buildQuantityStepper(
      "Qtd. mínima", // 👈 Texto reescrito
      _minQty,
          (newValue) {
        setState(() {
          _minQty = newValue;
          _isRequired = newValue > 0;
          if (_maxQty < _minQty) {
            _maxQty = _minQty;
          }
        });
      },
    );

    final maxStepper = _buildQuantityStepper(
      "Qtd. máxima", // 👈 Texto reescrito
      _maxQty,
          (newValue) {
        if (newValue >= _minQty) {
          setState(() => _maxQty = newValue);
        }
      },
    );

    // ✨ Decisão semântica e centralizada usando seu próprio helper
    if (ResponsiveBuilder.isDesktop(context)) {
      // Em telas largas (desktop), usa uma Row com Expanded.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: dropdown),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: minStepper),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: maxStepper),
        ],
      );
    } else {
      // Em telas estreitas (mobile), usa uma Column SEM Expanded.
      return Column(
        children: [
          dropdown,
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(child: minStepper),    SizedBox(width: 44,), Flexible(child: maxStepper),
            ],
          ),


        ],
      );
    }
  }
















  Widget _buildRecommendations() {
    // Define quais recomendações mostrar com base no tipo
    final recommendations =
        widget.groupType == GroupType.specifications
            ? ["Ponto da carne", "Tamanho"]
            : ["Deseja descartáveis?"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recomendações inteligentes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                recommendations.map((rec) {
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

  // No seu arquivo Step2GroupDetails.dart

  // ✅ SUBSTITUA O MÉTODO INTEIRO POR ESTE
  Widget _buildRequiredOptionalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O label pode ser o do próprio campo
        // const Text("Este grupo é obrigatório ou opcional?"),
        // const SizedBox(height: 8),

        // Usamos DropdownButtonFormField para ter a borda e o label
        DropdownButtonFormField<bool>(
          value: _isRequired,
          // O label agora fica dentro da decoração do campo
          decoration: const InputDecoration(
            labelText: "Este grupo é obrigatório ou opcional?",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          // As opções são os DropdownMenuItems
          items: const [
            DropdownMenuItem(value: false, child: Text("Opcional")),
            DropdownMenuItem(value: true, child: Text("Obrigatório")),
          ],
          // O onChanged atualiza o estado local, a lógica é a mesma
          onChanged: (newSelection) {
            if (newSelection != null) {
              setState(() {
                _isRequired = newSelection;
                // A mesma lógica para ajustar as quantidades
                if (_isRequired && _minQty < 1) {
                  _minQty = 1;
                  if (_maxQty < 1) _maxQty = 1;
                } else if (!_isRequired) {
                  _minQty = 0;
                }
              });
            }
          },
        ),
      ],
    );
  }



  Widget _buildQuantityStepper(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
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
                // ✅ Lógica de validação melhorada
                onPressed: () {
                  final newValue = value - 1;
                  // Para o mínimo, não pode ser menor que 0
                  // Para o máximo, não pode ser menor que o mínimo
                  if (label == "Qtd. mínima" && newValue >= 0) {
                    onChanged(newValue);
                  } else if (label == "Qtd. máxima" && newValue >= _minQty) {
                    onChanged(newValue);
                  }
                },
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final newValue = value + 1;
                  // Para o mínimo, não pode ser maior que o máximo
                  if (label == "Qtd. mínima" && newValue <= _maxQty) {
                    onChanged(newValue);
                  } else if (label == "Qtd. máxima") {
                    onChanged(newValue);
                  }
                },
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
            const Text(
              "Criar novo grupo",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Indicador de progresso
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: true),
                _buildStepIndicator(isActive: false),
                const SizedBox(width: 8),
                Text("Passo 2 de 3", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          // O botão de fechar pode funcionar como "Voltar"
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
