import 'package:flutter/material.dart';

import '../../../../../models/option_item.dart';



class PizzaSizeItemCard extends StatefulWidget {
  final OptionItem item;

  final ValueChanged<OptionItem> onUpdate;
  final VoidCallback onRemove;

  const PizzaSizeItemCard({
    required this.item,

    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  State<PizzaSizeItemCard> createState() => PizzaSizeItemCardState();
}

class PizzaSizeItemCardState extends State<PizzaSizeItemCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;
  late final TextEditingController _slicesController; // Para Pedaços

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: (widget.item.price / 100).toStringAsFixed(2));
    _pdvController = TextEditingController(text: widget.item.externalCode);
    _slicesController = TextEditingController(text: widget.item.slices?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    _slicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: _buildImageUploader()),
                Flexible(child: _buildNameField()),

              ],
            ),
            const SizedBox(height: 16),

            // --- Linha 2: Campos Condicionais (Pizza vs. Outros) ---
            Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                // ✅ CAMPO DE PEDAÇOS (SÓ APARECE SE FOR MODO PIZZA)
               _buildSlicesField(),

                // ✅ CAMPO DE SABORES (SÓ APARECE SE FOR MODO PIZZA)
               _buildFlavorsSelector(),

                _buildPdvField(),
              ],
            ),
            const SizedBox(height: 8),
            // --- Linha 3: Status ---
            _buildStatusSwitch(),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---
  // Widget para upload de imagem (novo)
  Widget _buildImageUploader() {
    return InkWell(
      onTap: () {
        // TODO: Implementar lógica para selecionar imagem
      },
      child: Container(
        width: 120,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: Colors.grey.shade500, size: 32),
            const SizedBox(height: 8),
            Text(
              "Adicionar",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Nome da Opção', hintText: 'Ex: Pequena, Média, Catupiry...'),
      onChanged: (value) => widget.onUpdate(widget.item.copyWith(name: value)),
    );
  }

  Widget _buildPriceField() {
    return SizedBox(
      width: 120,
      child: TextFormField(
        controller: _priceController,
        decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          final priceInCents = ((double.tryParse(value.replaceAll(',', '.')) ?? 0) * 100).round();
          widget.onUpdate(widget.item.copyWith(price: priceInCents));
        },
      ),
    );
  }

  Widget _buildSlicesField() {
    return SizedBox(
      width: 120,
      child: TextFormField(
        controller: _slicesController,
        decoration: const InputDecoration(labelText: 'Qtd. Pedaços'),
        keyboardType: TextInputType.number,
        onChanged: (value) => widget.onUpdate(widget.item.copyWith(slices: int.tryParse(value) ?? 0)),
      ),
    );
  }

  Widget _buildFlavorsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qtd. Sabores', style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        ToggleButtons(
          isSelected: [
            widget.item.maxFlavors == 1,
            widget.item.maxFlavors == 2,
            widget.item.maxFlavors == 3,
            widget.item.maxFlavors == 4,
          ],
          onPressed: (index) {
            widget.onUpdate(widget.item.copyWith(maxFlavors: index + 1));
          },
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
          children: const [Text('1'), Text('2'), Text('3'), Text('4')],
        ),
      ],
    );
  }

  Widget _buildPdvField() {
    return SizedBox(
      width: 120,
      child: TextFormField(
        controller: _pdvController,
        decoration: const InputDecoration(labelText: 'Cód. PDV'),
        onChanged: (value) => widget.onUpdate(widget.item.copyWith(externalCode: value)),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return SwitchListTile(
      title: const Text("Ativo"),
      value: widget.item.isActive,
      onChanged: (value) => widget.onUpdate(widget.item.copyWith(isActive: value)),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}














//
// import 'package:flutter/material.dart';
// import '../../../../../models/pizza_model.dart';
//
// class PizzaSizeCard extends StatefulWidget {
//   final PizzaSize size;
//   final ValueChanged<PizzaSize> onUpdate;
//   final VoidCallback onRemove;
//
//   const PizzaSizeCard({
//     required this.size,
//     required this.onUpdate,
//     required this.onRemove,
//     super.key,
//   });
//
//   @override
//   State<PizzaSizeCard> createState() => PizzaSizeCardState();
// }
//
// class PizzaSizeCardState extends State<PizzaSizeCard> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _piecesController;
//   late final TextEditingController _pdvController;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.size.name);
//     _piecesController = TextEditingController(text: widget.size.slices.toString());
//     _pdvController = TextEditingController(text: widget.size.externalCode);
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _piecesController.dispose();
//     _pdvController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         // ✅ 1. O LAYOUTBUILDER É O "CÉREBRO" DA RESPONSIVIDADE
//         // Ele verifica a largura disponível e decide qual layout construir.
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             // Definimos um "ponto de quebra". Se a largura for maior que 700, usamos o layout de desktop.
//             if (constraints.maxWidth > 700) {
//               return _buildDesktopLayout();
//             } else {
//               // Senão, usamos o layout otimizado para mobile.
//               return _buildMobileLayout();
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   // ✅ 2. LAYOUT HORIZONTAL PARA DESKTOP (O QUE VOCÊ JÁ TINHA)
//   Widget _buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildImageUploader(),
//         const SizedBox(width: 16),
//         Expanded(flex: 3, child: _buildNameField()),
//         const SizedBox(width: 16),
//         Expanded(flex: 2, child: _buildPiecesField()),
//         const SizedBox(width: 16),
//         _buildFlavorsSelector(),
//         const SizedBox(width: 16),
//         Expanded(flex: 2, child: _buildPdvField()),
//         const SizedBox(width: 16),
//         // ✅ ADICIONADO O SWITCH NO LAYOUT DE DESKTOP
//         _buildStatusSwitch(),
//         _buildRemoveButton(),
//       ],
//     );
//   }
//
// // Em lib/pages/categories/screens/tabs/widgets/sizes_cards.dart
//
//   // ✅ 3. NOVO LAYOUT VERTICAL PARA MOBILE (CORRIGIDO)
//   Widget _buildMobileLayout() {
//     // A Column agora não tem mais um Expanded dentro dela.
//     // Ela vai simplesmente ocupar a altura necessária para seus filhos.
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min, // Faz a Column "abraçar" seu conteúdo
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildImageUploader(),
//             const SizedBox(width: 16),
//             // O Expanded aqui funciona, pois está dentro de uma Row,
//             // que tem largura limitada pela tela.
//             Expanded(
//               child: Column(
//                 children: [
//                   _buildNameField(),
//                   const SizedBox(height: 12),
//                   _buildPiecesField(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildFlavorsSelector(),
//         const SizedBox(height: 16),
//         _buildPdvField(),
//         const SizedBox(height: 8), // Pequeno espaço antes dos botões
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _buildStatusSwitch(),
//             _buildRemoveButton(),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ✅ NOVO WIDGET AUXILIAR PARA O SWITCH DE STATUS
//   Widget _buildStatusSwitch() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Switch(
//           value: widget.size.isActive,
//           onChanged: (value) {
//             // Chama o callback onUpdate para notificar o CUBIT da mudança
//             widget.onUpdate(widget.size.copyWith(isActive: value));
//           },
//         ),
//       ],
//     );
//   }
//
//   // ✅ 4. WIDGETS AUXILIARES REUTILIZÁVEIS PARA CADA CAMPO
//   // Isso evita repetição de código entre os layouts de desktop e mobile.
//
//   Widget _buildImageUploader() {
//     return InkWell(
//       onTap: () { /* TODO: Adicionar lógica para escolher imagem */ },
//       child: Container(
//         width: 120,
//         height: 110,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey.shade200,
//           image: widget.size.imageUrl != null
//               ? DecorationImage(
//             image: NetworkImage(widget.size.imageUrl!),
//             fit: BoxFit.cover,
//           )
//               : null,
//         ),
//         child: widget.size.imageUrl == null
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
//               const SizedBox(height: 4),
//               Text("Adicionar", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
//             ],
//           ),
//         )
//             : null,
//       ),
//     );
//   }
//
//   Widget _buildNameField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Nome do tamanho', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: _nameController,
//           decoration: const InputDecoration(hintText: 'Ex: Pequena'),
//           onChanged: (value) => widget.onUpdate(widget.size.copyWith(name: value)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPiecesField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Qtd. Pedaços', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: _piecesController,
//           decoration: const InputDecoration(hintText: 'Ex: 4'),
//           keyboardType: TextInputType.number,
//           onChanged: (value) => widget.onUpdate(widget.size.copyWith(slices: int.tryParse(value) ?? 0)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFlavorsSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Qtd. Sabores', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         ToggleButtons(
//           isSelected: [
//             widget.size.flavors == 1,
//             widget.size.flavors == 2,
//             widget.size.flavors == 3,
//             widget.size.flavors == 4,
//           ],
//           onPressed: (index) {
//             widget.onUpdate(widget.size.copyWith(flavors: index + 1));
//           },
//           borderRadius: BorderRadius.circular(20),
//           constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
//           children: const [Text('1'), Text('2'), Text('3'), Text('4')],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPdvField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Cód. PDV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: _pdvController,
//           decoration: const InputDecoration(hintText: 'Código'),
//           onChanged: (value) => widget.onUpdate(widget.size.copyWith(externalCode: value)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRemoveButton() {
//     return IconButton(
//       onPressed: widget.onRemove,
//       icon: const Icon(Icons.delete_outline, color: Colors.red),
//       tooltip: "Remover tamanho",
//     );
//   }
// }