

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/pizza_model.dart';

class PizzaSizeSummaryCard extends StatelessWidget {
  final PizzaSize size;
  final ValueChanged<bool> onStatusChanged;

  const PizzaSizeSummaryCard({
    super.key,
    required this.size,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder é a chave para a responsividade
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ponto de quebra: se o card tiver menos de 250px de largura,
        // ele assume que está numa lista vertical (mobile).
        bool isMobileLayout = constraints.maxWidth < 250;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: isMobileLayout ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        );
      },
    );
  }

  // Em pizza_size_summary_card.dart

  // ✅ LAYOUT DESKTOP CORRIGIDO
  Widget _buildDesktopLayout() {
    // A SizedBox que define a largura do card fica aqui, dentro do layout que a usa.
    return SizedBox(
      width: 250, // Aumentei um pouco a largura para melhor espaçamento
      child: Center(
        child: Column(
          // ✅ CORREÇÃO PRINCIPAL:
          // Removemos o Spacer e usamos MainAxisAlignment para distribuir os itens.
          // spaceAround dá um espaço igual entre cada item, e metade disso nas pontas.
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(),
            _buildInfoTexts(),
            // const Spacer(), // <--- REMOVIDO!
            _buildStatusSwitch(),
          ],
        ),
      ),
    );
  }

  // Layout para MOBILE (Vertical, um embaixo do outro)
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildImage(),
          const SizedBox(width: 16),
          Expanded(child: _buildInfoTexts()),
          const SizedBox(width: 16),
          _buildStatusSwitch(),
        ],
      ),
    );
  }

  // Widgets auxiliares para evitar repetição de código

  Widget _buildImage() {
    return SizedBox(
      width: 40,
      height: 40,
      child: size.imageUrl != null && size.imageUrl!.isNotEmpty
          ? Image.network(
        size.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
      )
          : const Icon(Icons.local_pizza_outlined, color: Colors.grey),
    );
  }

  Widget _buildInfoTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          size.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Cortada em ${size.slices} pedaço${size.slices != 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Aceita até ${size.flavors} sabor${size.flavors != 1 ? 'es' : ''}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Column(
      children: [
        Text(
          size.isActive ? "Ativado" : "Pausado",
          style: TextStyle(
            fontSize: 14,
            color: size.isActive ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Switch(
          value: size.isActive,
          onChanged: onStatusChanged,
          activeColor: const Color(0xFFEA1D2C),
        ),
      ],
    );
  }
}