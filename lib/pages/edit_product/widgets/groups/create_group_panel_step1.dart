import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/create_complement_cbit.dart';
import '../../cubit/create_complement_state.dart';


class CreateGroupStep1Panel extends StatefulWidget {


  const CreateGroupStep1Panel({
    super.key,

  });

  @override
  State<CreateGroupStep1Panel> createState() => _CreateGroupStep1PanelState();
}

class _CreateGroupStep1PanelState extends State<CreateGroupStep1Panel> {
  // Estado para controlar a seleção atual
  GroupType _selectedType = GroupType.ingredients;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(),
          const SizedBox(height: 24),
          _buildPanelBody(),

          // O Spacer garante que o rodapé fique fixo na parte inferior
          const Spacer(),

          _buildPanelFooter(),
        ],
      ),
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
                _buildStepIndicator(isActive: false),
                _buildStepIndicator(isActive: false),
                const SizedBox(width: 8),
                Text("Passo 1 de 3", style: TextStyle(color: Colors.grey[600])),
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

  /// Constrói o corpo principal com as opções
  Widget _buildPanelBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Primeiro, defina o grupo e suas informações principais",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          title: "Ingredientes",
          subtitle: "Dê a opção do cliente remover e adicionar ingredientes neste produto, ou também escolher entre um grupo de opções.",
          icon: Icons.restaurant_menu_outlined,
          value: GroupType.ingredients,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: "Especificações",
          subtitle: "Faça perguntas para que o cliente defina melhor o produto e seu modo de preparo.",
          icon: Icons.help_outline,
          value: GroupType.specifications,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: "Cross-sell",
          subtitle: "Aproveite para sugerir outros produtos e aumentar o valor do pedido.",
          icon: Icons.add_shopping_cart_outlined,
          value: GroupType.crossSell,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: "Descartáveis",
          subtitle: "Ao invés de enviar por padrão, economize e ajude o meio ambiente perguntando ao cliente se ele precisa de talheres...",
          icon: Icons.restaurant_outlined,
          value: GroupType.disposables,
        ),
      ],
    );
  }

  /// Constrói o rodapé com os botões de ação
  Widget _buildPanelFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: (){
            context.read<CreateComplementGroupCubit>().goBack();
          },
          child: const Text("Voltar"),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: (){
            // ✅ Chama o método para definir o tipo e avançar para o próximo passo
            context.read<CreateComplementGroupCubit>().selectGroupType(_selectedType);
          },
          child: const Text("Continuar"),
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

  /// Widget auxiliar para criar os cartões de opção (reutilizado da resposta anterior)
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required GroupType value,
  }) {
    final bool isSelected = _selectedType == value;
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600), maxLines: 3, overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            Radio<GroupType>(
              value: value,
              groupValue: _selectedType,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedType = newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}