// lib/pages/loading/loading_data_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart'; // Ou seu widget de loading

class LoadingDataPage extends StatelessWidget {
  const LoadingDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    // O BlocListener é perfeito aqui. Ele não reconstrói a UI, apenas escuta
    // por mudanças de estado e executa uma ação (neste caso, navegar).
    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, state) {
        // Quando o estado do StoresManagerCubit mudar para 'Carregado'...
        if (state is StoresManagerLoaded) {
          // ...redirecionamos para a primeira loja da lista.
    // Usamos 'context.go' para substituir a tela de loading na pilha de navegação.
    print('✅ StoresManager carregado. Redirecionando para a primeira loja: ${state.activeStoreId}');
    context.go('/stores/${state.activeStoreId}/dashboard');
  }
  // Quando o estado mudar para 'Vazio'...
  else if (state is StoresManagerEmpty) {
  // ...redirecionamos para a tela de criação de loja.
  print('✅ StoresManager carregado, sem lojas. Redirecionando para /stores/new');
  context.go('/stores/new');
  }
},
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DotLoading(), // Ou CircularProgressIndicator()
              SizedBox(height: 16),
              Text('Carregando suas lojas...'),
            ],
          ),
        ),
      ),
    );
  }
}