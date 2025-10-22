import 'package:flutter/material.dart';

class IfoodStatsCards extends StatelessWidget {
  const IfoodStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Pedidos Concluídos do Mês',
          '0',
          'Mês atual',
          '0',
          'Mesmo período do mês anterior',
          Icons.shopping_bag_outlined,
          Colors.green,
        ),
        _buildStatCard(
          'Faturamento do Dia',
          'R\$ 0,00',
          'Hoje',
          'R\$ 0,00',
          'Ontem',
          Icons.attach_money,
          Colors.blue,
        ),
        _buildStatCard(
          'Tempo Médio de Preparo',
          '25 min',
          'Atual',
          '28 min',
          'Média anterior',
          Icons.timer,
          Colors.orange,
        ),
        _buildStatCard(
          'Avaliação dos Clientes',
          '4.5',
          '⭐ Estrelas',
          '+0.2',
          'Vs. último mês',
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      String currentValue,
      String currentLabel,
      String previousValue,
      String previousLabel,
      IconData icon,
      Color color,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone e título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Valor atual
          Text(
            currentValue,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            currentLabel,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          // Comparação com período anterior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  previousValue,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  previousLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}