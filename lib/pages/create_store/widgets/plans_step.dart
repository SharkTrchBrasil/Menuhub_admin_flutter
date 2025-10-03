// lib/pages/create_store/widgets/plans_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup-state.dart';

class PlansStep extends StatelessWidget {
  const PlansStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                      // Features Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildModernFeatureRow(
                        context: context,
                        icon: Icons.card_giftcard_rounded,
                        title: '30 Dias Grátis',
                        subtitle: 'Todas as funcionalidades liberadas para testar',
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildModernFeatureRow(
                        context: context,
                        icon: Icons.credit_card_off_rounded,
                        title: 'Sem Cartão',
                        subtitle: 'Ative agora e pague só se quiser continuar',
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildModernFeatureRow(
                        context: context,
                        icon: Icons.cancel_outlined,
                        title: 'Cancele Quando Quiser',
                        subtitle: 'Sem fidelidade ou taxas escondidas',
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        );
      },
    );
  }

  Widget _buildModernFeatureRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with gradient background
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}