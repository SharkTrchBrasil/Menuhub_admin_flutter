import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/page_status.dart'; // Supondo que você tenha este import

import '../cubit/store_setup_cubit.dart';
import '../cubit/store_setup-state.dart';

class PlansStep extends StatelessWidget {
  const PlansStep({super.key});

  // Widget auxiliar para criar cada linha de limite, evitando repetição de código
  Widget _buildLimitRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o BlocBuilder para reagir ao estado de carregamento dos planos
    return BlocBuilder<StoreSetupCubit, StoreSetupState>(
      // buildWhen: (previous, current) => previous.plansStatus != current.plansStatus,
      builder: (context, state) {
        final status = state.plansStatus;

        if (status is PageStatusLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status is PageStatusError) {
          return Center(
            child: Text('Erro ao carregar planos: ${status.message}'),
          );
        }

        // ✅ ALTERAÇÃO AQUI: Adicionamos a verificação do preço.
        // Busca pelo plano cujo nome é 'Plano Empreendedor' OU cujo preço é 0.
        final freePlan = state.plansList.firstWhereOrNull(
          (p) => p.planName == 'Plano Empreendedor' || p.price == 0,
        );

        if (freePlan == null) {
          return const Center(child: Text('Nenhum plano gratuito encontrado.'));
        }

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Badge overlay
                  Positioned(
                    top: 0,
                    right: 20,
                    child: Container(
                      height: 24,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3E5FC),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'RECOMENDADO',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount tag


                        const SizedBox(height: 8),

                        // Title
                        Text(
                          freePlan.planName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),



                        // Free months offer
                        Text(
                          '12 meses grátis',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),




                        const SizedBox(height: 16),

                        // Renewal price
                        Text(
                          'Você poderá fazer o upgrade para um plano superior a qualquer momento no seu painel.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 26),
                        const Divider(height: 1),

                        const SizedBox(height: 36),
                        // Features
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Usando o widget auxiliar para exibir os limites
                            _buildLimitRow(
                              context,
                              icon: Icons.inventory_2_outlined,
                              title: 'Limite de Produtos',
                              value: freePlan.productLimit?.toString() ?? 'Ilimitado',
                            ),
                            _buildLimitRow(
                              context,
                              icon: Icons.receipt_long_outlined,
                              title: 'Pedidos por Mês',
                              value:
                              freePlan.monthlyOrderLimit?.toString() ?? 'Ilimitado',
                            ),
                            _buildLimitRow(
                              context,
                              icon: Icons.people_outline,
                              title: 'Limite de Usuários',
                              value: freePlan.userLimit?.toString() ?? 'Ilimitado',
                            ),
                            _buildLimitRow(
                              context,
                              icon: Icons.business_outlined,
                              title: 'Unidades da Loja',
                              value: freePlan.locationLimit?.toString() ?? 'Ilimitada',
                            ),





                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),































          ],
        );
      },
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required Color color,
    bool hasTooltip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child:
                hasTooltip
                    ? Tooltip(
                      message: 'Informação adicional',
                      child: Text(
                        text,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dashed,
                        ),
                      ),
                    )
                    : Text(text),
          ),
        ],
      ),
    );
  }
}
