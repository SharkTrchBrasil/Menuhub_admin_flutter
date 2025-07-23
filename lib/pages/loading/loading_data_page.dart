import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

// REMOVIDO: Todos os imports do BLoC e GoRouter, pois não são mais necessários aqui.

class LoadingDataPage extends StatelessWidget {
  const LoadingDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    // REMOVIDO: O BlocListener foi completamente removido.
    // A página agora é apenas um indicador visual.
    return const Scaffold(
      body: Center(
        child: DotLoading(),
      ),
    );
  }
}
