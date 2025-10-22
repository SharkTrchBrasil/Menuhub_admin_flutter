import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/services/preference_service.dart';
import 'package:totem_pro_admin/core/di.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  bool _skipNextTime = false;

  @override
  void initState() {
    super.initState();
    _loadSkipPreference();
  }

  Future<void> _loadSkipPreference() async {
    try {
      final shouldSkip = await getIt<PreferenceService>().getSkipHubPreference();
      setState(() {
        _skipNextTime = shouldSkip;
      });
    } catch (e) {
      print('Erro ao carregar preferência: $e');
    }
  }

  void _handleSkipChange(bool? value) {
    if (value == null) return;

    final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;

    if (storeId != null) {
      setState(() {
        _skipNextTime = value;
      });

      getIt<PreferenceService>().saveSkipHubPreference(value, storeId).catchError((e) {
        print('Erro ao salvar preferência: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;

    if (storeId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhuma loja ativa selecionada.'),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<StoresManagerCubit, StoresManagerState>(
                  builder: (context, state) {
                    return Text(
                      state.activeStore?.core.name ?? 'Sua Loja',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'O que você gostaria de fazer?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                _HubCard(
                  title: 'Gerenciar Loja',
                  subtitle: 'Produtos, categorias, horários e mais',
                  icon: Icons.store_mall_directory_outlined,
                  onTap: () => context.go('/stores/$storeId/dashboard'),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                _HubCard(
                  title: 'Gerenciar Pedidos',
                  subtitle: 'Acompanhe e gerencie os pedidos em tempo real',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => context.go('/stores/$storeId/orders'),
                  color: Colors.orange,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _skipNextTime,
                        onChanged: _handleSkipChange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pular tela de hub na próxima vez',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}