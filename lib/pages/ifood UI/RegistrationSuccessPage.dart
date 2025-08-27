import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationSuccessPage extends StatelessWidget {
  final VoidCallback onConfigureStore;

  const RegistrationSuccessPage({
    super.key,
    required this.onConfigureStore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status "Cadastro Concluído"
                Chip(
                  label: const Text(
                    'Cadastro concluído',
                    style: TextStyle(
                      color: Color(0xFF1A4D2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFFD1FAE5),
                  avatar: const Icon(Icons.check_circle, color: Color(0xFF1A4D2E)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                const SizedBox(height: 32),

                // Ilustração
                SvgPicture.asset(
                  'assets/images/success_illustration.svg', // Use um SVG seu aqui
                  height: 180,
                  placeholderBuilder: (context) => const SizedBox(
                    height: 180,
                    child: Icon(Icons.storefront_outlined, size: 100, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),

                // Título Principal
                const Text(
                  'Agora é só configurar sua loja e começar a vender!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Clique abaixo para seguir para o Portal do Parceiro e deixar tudo pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Botão de Ação
                ElevatedButton(
                  onPressed: onConfigureStore,
                  style: ElevatedButton.styleFrom(

                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Configurar minha loja!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
