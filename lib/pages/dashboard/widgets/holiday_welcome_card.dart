import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';

// Classe principal para o card de boas-vindas que pode exibir o aviso de feriado
class HolidayWelcomeCard extends StatelessWidget {
  final DashboardInsight? holidayInsight; // Recebe o insight do feriado (pode ser nulo)
  final String userName;

  const HolidayWelcomeCard({
    Key? key,
    this.holidayInsight,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verifica se há um insight de feriado para exibir
    final bool isHolidayComing = holidayInsight != null && holidayInsight!.details is HolidayInsightDetails;

    // Define os textos e o ícone com base na existência do feriado
    final String title;
    final String subtitle;
    final IconData icon;

    if (isHolidayComing) {
      // Se um feriado está próximo, personaliza a mensagem
      final details = holidayInsight!.details as HolidayInsightDetails;
      initializeDateFormatting('pt_BR', null);
      final formattedDate = DateFormat('d ' 'de' ' MMMM', 'pt_BR').format(details.holidayDate);

      title = 'Feriado à Vista, ${userName.split(' ').first}!';
      subtitle = '${details.holidayName} será em ${formattedDate}. Prepare sua loja!';
      icon = Icons.campaign_rounded;
    } else {
      // Mensagem padrão para dias normais
      title = 'Bom Dia, ${userName.split(' ').first}!';
      subtitle = 'Aqui está um resumo do que acontece na sua loja hoje.';
      icon = Icons.wb_sunny_rounded;
    }

    return Card(
      elevation: 4.0,
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e título
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Subtítulo
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            // Ações (só aparecem se houver feriado)
            if (isHolidayComing) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão para criar promoção
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Navegar para a tela de criação de promoções
                    },
                    child: const Text('Criar Promoção'),
                  ),
                  const SizedBox(width: 12),
                  // Botão para ajustar horário
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Navegar para a tela de horários
                    },
                    child: const Text('Ajustar Horário'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}