import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/store/store_city.dart';
import 'package:totem_pro_admin/models/store/store_neig.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../../cubits/store_manager_cubit.dart';
class AddEditCityPage extends StatefulWidget {
  final int storeId;
  final StoreCity? initialCity;

  const AddEditCityPage({
    super.key,
    required this.storeId,
    this.initialCity,
  });

  @override
  State<AddEditCityPage> createState() => _AddEditCityPageState();
}

class _AddEditCityPageState extends State<AddEditCityPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cityNameController;
  late final TextEditingController _cityFeeController;
  late bool _isCityActive;

  // ✅ 1. CONTROLE DE ESTADO LOCAL PARA OS BAIRROS (CORRIGE O BUG DO TECLADO)
  // Usamos um ValueNotifier para atualizar a lista sem reconstruir a tela inteira.
  late final ValueNotifier<List<StoreNeighborhood>> _neighborhoodsNotifier;

  @override
  void initState() {
    super.initState();
    final city = widget.initialCity;
    _cityNameController = TextEditingController(text: city?.name ?? '');
    _cityFeeController = TextEditingController(text: city?.deliveryFee.toString() ?? '0');
    _isCityActive = city?.isActive ?? true;

    // Inicializa o ValueNotifier com uma cópia da lista de bairros.
    _neighborhoodsNotifier = ValueNotifier(
      city?.neighborhoods.map((n) => n.copyWith()).toList() ?? [],
    );
  }

  @override
  void dispose() {
    _cityNameController.dispose();
    _cityFeeController.dispose();
    _neighborhoodsNotifier.dispose();
    super.dispose();
  }

  void _addNeighborhood() {
    final currentList = _neighborhoodsNotifier.value;
    _neighborhoodsNotifier.value = [
      ...currentList,
      StoreNeighborhood(name: '', deliveryFee: 0, isActive: true),
    ];
  }

  void _removeNeighborhood(int index) {
    final currentList = List<StoreNeighborhood>.from(_neighborhoodsNotifier.value);
    currentList.removeAt(index);
    _neighborhoodsNotifier.value = currentList;
  }

  void _updateNeighborhood(int index, StoreNeighborhood updated) {
    final currentList = List<StoreNeighborhood>.from(_neighborhoodsNotifier.value);
    currentList[index] = updated;
    _neighborhoodsNotifier.value = currentList;
  }

  // ✅ 2. A FUNÇÃO DE SALVAR AGORA CHAMA O CUBIT DIRETAMENTE
  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cityToSave = StoreCity(
      id: widget.initialCity?.id,
      name: _cityNameController.text,
      deliveryFee: int.tryParse(_cityFeeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      isActive: _isCityActive,
      neighborhoods: _neighborhoodsNotifier.value,
    );

    // Chama o cubit para salvar e fecha o painel (se estiver em um)
    final success = await context.read<StoresManagerCubit>().saveCityWithNeighborhoods(widget.storeId, cityToSave);
    if (success && mounted) {
      Navigator.of(context).pop(); // Fecha o Side Panel
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // ✅ 3. UI MELHORADA: TÍTULO DINÂMICO
          isEditing ? 'Editar "${widget.initialCity!.name}"' : 'Adicionar Nova Cidade',
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body:

      Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCitySection(),
                    const SizedBox(height: 24),
                    _buildNeighborhoodsSection(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // O resto dos widgets de construção permanecem os mesmos, mas agora
  // a lista de bairros é construída a partir do ValueNotifier.
  Widget _buildNeighborhoodsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usamos ValueListenableBuilder para reconstruir apenas a contagem de bairros
            ValueListenableBuilder<List<StoreNeighborhood>>(
              valueListenable: _neighborhoodsNotifier,
              builder: (context, neighborhoods, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Text('Bairros', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (neighborhoods.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text('${neighborhoods.length} ${neighborhoods.length == 1 ? 'bairro' : 'bairros'}', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // E aqui para reconstruir a lista de bairros
            ValueListenableBuilder<List<StoreNeighborhood>>(
              valueListenable: _neighborhoodsNotifier,
              builder: (context, neighborhoods, child) {
                if (neighborhoods.isEmpty) return _buildEmptyNeighborhoodsState();
                return Column(
                  children: neighborhoods.asMap().entries.map((entry) {
                    final index = entry.key;
                    final neighborhood = entry.value;
                    return NeighborhoodEditRow(
                      key: ValueKey('neighborhood_$index'), // Usar o índice é mais estável aqui
                      neighborhood: neighborhood,
                      index: index, // Passamos o índice para exibição
                      onChanged: (updated) => _updateNeighborhood(index, updated),
                      onRemove: () => _removeNeighborhood(index),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Adicionar Bairro'),
              onPressed: _addNeighborhood,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.blue.shade700, side: BorderSide(color: Colors.blue.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCitySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Cidade',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _cityNameController,
              decoration: InputDecoration(
                labelText: 'Nome da Cidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cityFeeController,
              decoration: InputDecoration(
                labelText: 'Taxa de Entrega Padrão',
                hintText: 'Ex: R\$ 5,00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CentavosInputFormatter(moeda: true),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: SwitchListTile(
                title: Text(
                  'Cidade Ativa',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isCityActive,
                onChanged: (value) => setState(() => _isCityActive = value),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildEmptyNeighborhoodsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum bairro adicionado',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em "Adicionar Bairro" para começar',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: DsButton(
        label: 'Salvar Cidade e Bairros',
        onPressed: _save,
      ),
    );
  }
}

class NeighborhoodEditRow extends StatefulWidget {
  final StoreNeighborhood neighborhood;
  final VoidCallback onRemove;
  final int index; // ✅ Adicionado
  final ValueChanged<StoreNeighborhood> onChanged;

  const NeighborhoodEditRow({
    super.key,
    required this.neighborhood,
    required this.onRemove,
    required this.onChanged,
    required this.index,
  });

  @override
  State<NeighborhoodEditRow> createState() => _NeighborhoodEditRowState();
}

class _NeighborhoodEditRowState extends State<NeighborhoodEditRow> {
  late TextEditingController _nameController;
  late TextEditingController _feeController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _feeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.neighborhood.name);
    _feeController = TextEditingController(text: widget.neighborhood.deliveryFee.toString());

    _nameController.addListener(_notifyChanged);
    _feeController.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    final deliveryFee = int.tryParse(_feeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    widget.onChanged(widget.neighborhood.copyWith(
      name: _nameController.text,
      deliveryFee: deliveryFee,
    ));
  }

  @override
  void dispose() {
    _nameController.removeListener(_notifyChanged);
    _feeController.removeListener(_notifyChanged);
    _nameController.dispose();
    _feeController.dispose();
    _nameFocusNode.dispose();
    _feeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone e botão remover
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bairro ${_getNeighborhoodIndex() + 1}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Botão Remover
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                  onPressed: widget.onRemove,
                  tooltip: 'Remover Bairro',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo Nome do Bairro (linha única)
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              labelText: 'Nome do Bairro',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Campo Taxa
          TextFormField(
            controller: _feeController,
            focusNode: _feeFocusNode,
            decoration: InputDecoration(
              labelText: 'Taxa de Entrega',
              hintText: 'Ex: R\$ 5,00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CentavosInputFormatter(moeda: true),
            ],
          ),
        ],
      ),
    );
  }

  int _getNeighborhoodIndex() {
    // Esta função precisaria ser implementada para obter o índice real
    // Por enquanto retorna 0, você precisará passar o índice como parâmetro
    return 0;
  }
}

// Formatter para centavos (exemplo básico - ajuste conforme sua implementação)
class CentavosInputFormatter extends TextInputFormatter {
  final bool moeda;

  CentavosInputFormatter({this.moeda = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove todos os caracteres não numéricos
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Converte para inteiro
    int value = int.tryParse(cleanText) ?? 0;

    // Formata como moeda se necessário
    if (moeda) {
      double realValue = value / 100;
      String formattedText = 'R\$${realValue.toStringAsFixed(2).replaceAll('.', ',')}';

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    } else {
      return TextEditingValue(
        text: cleanText,
        selection: TextSelection.collapsed(offset: cleanText.length),
      );
    }
  }
}