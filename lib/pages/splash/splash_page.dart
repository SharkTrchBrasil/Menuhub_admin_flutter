import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: DotLoading(),
      ),
    );
  }
}