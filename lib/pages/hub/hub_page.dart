import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/services/preference_service.dart';

import '../../cubits/store_manager_cubit.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  final _preferenceService = getIt<PreferenceService>();
  bool _skipScreenPreference = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final storedPreference = await _preferenceService.getSkipHubPreference();
    if (mounted) {
      setState(() {
        _skipScreenPreference = storedPreference;
      });
    }
  }

  Future<void> _updatePreference(bool newValue) async {
    setState(() {
      _skipScreenPreference = newValue;
    });
    await _preferenceService.saveSkipHubPreference(newValue);
  }

  void _navigateTo(String route) {
    // Salva a rota como a última acessada ANTES de navegar
    _preferenceService.saveLastAccessedRoute(route);
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    // ... (O resto do build é idêntico ao que te passei antes)
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Olá!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Por onde deseja começar?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 48),

              // Opção 1: Gestão de Loja
              _buildNavigationCard(
                context,
                icon: Icons.storefront,
                title: 'Gestão de Loja',
                subtitle: 'Confira aqui seus repasses, avaliações, cardápio e outros.',
                onTap: () {

                  final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;
                  _navigateTo('/stores/$storeId/dashboard');
                },
              ),
              const SizedBox(height: 24),

              // Opção 2: Gestão de Pedidos
              _buildNavigationCard(
                context,
                icon: Icons.receipt_long,
                title: 'Gestão de Pedidos',
                subtitle: 'Acompanhe aqui os pedidos que sua loja recebe.',
                onTap: () {
                  final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;
                  _navigateTo('/stores/$storeId/orders');
                },
              ),
              const Spacer(),
              _buildSkipToggle(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap,}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Pular esta tela e ir direto para a última opção acessada na próxima vez',
            ),
          ),
          const SizedBox(width: 16),
          CupertinoSwitch(
            value: _skipScreenPreference,
            onChanged: _updatePreference,
          )
        ],
      ),
    );
  }
}