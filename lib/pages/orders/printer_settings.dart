import 'package:flutter/material.dart';


class PrinterSettingsSidePanel extends StatelessWidget {
  final int storeId;

  const PrinterSettingsSidePanel({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // Reutiliza a lógica de tamanho do seu outro painel
    final isMobile = MediaQuery.of(context).size.width < 600;
    final panelWidth = isMobile
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * 0.3;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 12,
        child: Container(
          width: panelWidth,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Configurações de Impressão',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    // O Navigator.pop() fecha a rota atual (nosso painel)
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("Mapeamento de Impressoras"),
                      subtitle: Text("Aqui você irá associar os 'destinos' (ex: caixa, cozinha) com as impressoras instaladas neste computador."),
                    ),
                    // Você pode adicionar a lógica de mapeamento aqui no futuro
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


