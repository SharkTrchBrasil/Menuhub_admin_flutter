// ARQUIVO: lib/pages/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/dot_loading.dart';
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ REMOVEMOS O BLOCLISTENER. A tela agora é "burra".
    // Apenas exibe a UI de splash. O GoRouter cuida do resto.
    return  Scaffold(
      body: Center(
        child:  Image.asset("assets/images/logo.png",),
      ),
    );
  }
}