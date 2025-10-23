import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';

class IfoodDashboardPanel extends StatelessWidget {
  final Store? activeStore;
  final List<OrderDetails> orders;

  const IfoodDashboardPanel({
    super.key,
    required this.activeStore,
    required this.orders,
  });

  // ✅ Calcular dados reais dos pedidos
  Map<String, dynamic> _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    // Pedidos de hoje
    final todayOrders = orders.where((o) =>
    o.createdAt.isAfter(today) &&
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    // Pedidos de ontem
    final yesterdayOrders = orders.where((o) =>
    o.createdAt.isAfter(yesterday) &&
        o.createdAt.isBefore(today) &&
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    // Pedidos do mês atual
    final currentMonthOrders = orders.where((o) =>
    o.createdAt.isAfter(startOfMonth) &&
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    // Pedidos do mês passado
    final lastMonthOrders = orders.where((o) =>
    o.createdAt.isAfter(lastMonth) &&
        o.createdAt.isBefore(endOfLastMonth) &&
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    // Faturamento de hoje
    final todayRevenue = todayOrders.fold<double>(
        0, (sum, order) => sum + (order.totalPrice / 100)
    );

    // Faturamento de ontem
    final yesterdayRevenue = yesterdayOrders.fold<double>(
        0, (sum, order) => sum + (order.totalPrice / 100)
    );

    // Tempo médio de preparo (pedidos concluídos)
    final completedOrders = orders.where((o) =>
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    double avgPrepTime = 0;
    if (completedOrders.isNotEmpty) {
      final totalMinutes = completedOrders.fold<int>(0, (sum, order) {
        // Calcula diferença entre criação e conclusão em minutos
        final duration = order.updatedAt.difference(order.createdAt);
        return sum + duration.inMinutes;
      });
      avgPrepTime = totalMinutes / completedOrders.length;
    }

    // Status da loja
    final isOpen = activeStore?.relations.storeOperationConfig?.isStoreOpen ?? false;
    final openStatus = isOpen ? 'Aberto' : 'Fechado';

    return {
      'todayOrdersCount': todayOrders.length,
      'todayRevenue': todayRevenue,
      'yesterdayRevenue': yesterdayRevenue,
      'currentMonthOrders': currentMonthOrders.length,
      'lastMonthOrders': lastMonthOrders.length,
      'avgPrepTime': avgPrepTime,
      'isOpen': isOpen,
      'openStatus': openStatus,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Saudação + Carrossel
          _buildWelcomeSection(),

          // Métricas rápidas
          const SizedBox(height: 16),
          _buildQuickStats(stats),

          // Cartões de métricas
          const SizedBox(height: 16),
          Expanded(
            child: _buildStatsCards(stats, currencyFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
      child: Column(
        children: [
          // Saudação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0)),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEA1D2C),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👋 Olá, ${activeStore?.core.name ?? 'Operador'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gerencie seus pedidos e acompanhe as métricas',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Carrossel (simplificado)
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCarouselItem(
                  'Automatize o atendimento',
                  'Converse com clientes no WhatsApp',
                  Colors.blue,
                ),
                _buildCarouselItem(
                  'Aumente suas vendas',
                  'Promoções e ofertas especiais',
                  const Color(0xFFEA1D2C),
                ),
                _buildCarouselItem(
                  'Gestão de cardápio',
                  'Atualize seus produtos',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(String title, String subtitle, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Métricas rápidas com dados reais
  Widget _buildQuickStats(Map<String, dynamic> stats) {
    final isOpen = stats['isOpen'] as bool;
    final openStatus = stats['openStatus'] as String;

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            'Horário de funcionamento',
            'Hoje • $openStatus',
            Icons.access_time,
            isOpen ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            'Pedidos Ativos',
            '${orders.where((o) => !['delivered', 'finalized', 'canceled'].contains(o.orderStatus)).length} pedidos',
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Cards de estatísticas com dados reais
  Widget _buildStatsCards(Map<String, dynamic> stats, NumberFormat currencyFormat) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Pedidos Concluídos do Mês',
          '${stats['currentMonthOrders']}',
          'Mês atual',
          '${stats['lastMonthOrders']}',
          'Mesmo período do mês anterior',
          Icons.shopping_bag_outlined,
          Colors.green,
        ),
        _buildStatCard(
          'Faturamento do Dia',
          currencyFormat.format(stats['todayRevenue']),
          'Hoje',
          currencyFormat.format(stats['yesterdayRevenue']),
          'Ontem',
          Icons.attach_money,
          Colors.blue,
        ),
        _buildStatCard(
          'Tempo Médio de Preparo',
          '${stats['avgPrepTime'].toStringAsFixed(0)} min',
          'Média atual',
          '--',
          'Calculado em tempo real',
          Icons.timer,
          Colors.orange,
        ),
        _buildStatCard(
          'Total de Pedidos',
          '${orders.length}',
          'Todos os status',
          '${orders.where((o) => ['delivered', 'finalized'].contains(o.orderStatus)).length}',
          'Concluídos',
          Icons.receipt_long,
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