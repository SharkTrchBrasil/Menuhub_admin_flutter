// Widget reutilizável para exibir a informação do tipo de categoria selecionado
import 'package:flutter/material.dart';

import '../../../core/enums/category_type.dart';
class CategoryTypeInfoCard extends StatelessWidget {
  // O widget recebe o tipo de categoria e a função para o botão "Alterar"
  final CategoryType? categoryType;
  final VoidCallback onPressed;
  final bool isEditMode;

  const CategoryTypeInfoCard({
    super.key,
    required this.categoryType,
    required this.onPressed,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✨ LÓGICA DINÂMICA ACONTECE AQUI ✨
    // Variáveis para guardar o conteúdo que vai mudar
    String title;
    String subtitle;
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    // Um switch para decidir o conteúdo com base no tipo da categoria
    switch (categoryType) {
      case CategoryType.CUSTOMIZABLE:
        title = "Categoria Customizável";
        subtitle = "Para itens montáveis como pizzas, açaís e pastéis.";
        iconData = Icons.local_pizza_outlined;
        iconColor = Colors.blue.shade700;
        backgroundColor = Colors.blue.shade50;
        break;

      case CategoryType.GENERAL:
      default: // O default garante que sempre teremos um valor
        title = "Itens principais";
        subtitle = "Categoria padrão para produtos diversos";
        iconData = Icons.fastfood_outlined;
        iconColor = Colors.orange.shade700;
        backgroundColor = Colors.orange.shade50;
        break;
    }

    // O layout do seu widget original, agora usando as variáveis dinâmicas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo da categoria',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor, // <- Usa a cor dinâmica
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData, // <- Usa o ícone dinâmico
                    color: iconColor, // <- Usa a cor dinâmica
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // <- Usa o título dinâmico
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle, // <- Usa o subtítulo dinâmico
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                //    Só mostra o botão se NÃO estiver em modo de edição.
                if (!isEditMode)
                TextButton(
                  onPressed: onPressed, // <- Usa a função recebida
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEB0033),
                  ),
                  child: const Text('Alterar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}