import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../ConstData/typography.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key, required this.storeId});

  final int storeId;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  // Aqui, organizei as opções como listas por seção,
  // com título, rota e ícone (SVG path)
  final int storeId = 123; // só exemplo, substitua pelo widget.storeId

  final List<Map<String, String>> dashboardItems = [
    {
      'title': 'Meus Pedidos',
      'route': '/stores/{storeId}/orders',
      'icon': 'assets/images/package.png'
    },
    {
      'title': 'Pedidos Balcão (PDV)',
      'route': '/stores/{storeId}/pdv-orders',
      'icon': 'assets/images/package.png'
    },
    {
      'title': 'Mesas',
      'route': '/stores/{storeId}/tables',
      'icon': 'assets/images/package.png'
    },
  ];

  final List<Map<String, String>> lojaItems = [
    {
      'title': 'Clientes',
      'route': '/stores/{storeId}/customers',
      'icon': 'assets/images/user.png'
    },
    {
      'title': 'Produtos',
      'route': '/stores/{storeId}/products',
      'icon': 'assets/images/package.png'
    },

    {
      'title': 'Atributos',
      'route': '/stores/{storeId}/variants',
      'icon': 'assets/images/4.png'
    },
    {
      'title': 'Cupons',
      'route': '/stores/{storeId}/coupons',
      'icon': 'assets/images/6.png'
    },

    {
      'title': 'Catálogo Online',
      'route': '/stores/{storeId}/catalog',
      'icon': 'assets/images/package.png'
    },
    {
      'title': 'Totem',
      'route': '/stores/{storeId}/totems',
      'icon': 'assets/images/package.png'
    },
  ];

  final List<Map<String, String>> configuracoesItems = [
    {
      'title': 'Informações Gerais',
      'route': '/stores/{storeId}/settings',
      'icon': 'assets/images/33.png'
    },
    {
      'title': 'Horários de Atendimento',
      'route': '/stores/{storeId}/settings/hours',
      'icon': 'assets/images/calendar-edit.png'
    },
    {
      'title': 'Formas de Pagamento',
      'route': '/stores/{storeId}/payment-methods',
      'icon': 'assets/images/coins.png'
    },
    {
      'title': 'Formas de Entrega',
      'route': '/stores/{storeId}/settings/shipping',
      'icon': 'assets/images/box.png'
    },
    {
      'title': 'Cidades e Bairros',
      'route': '/stores/{storeId}/settings/locations',
      'icon': 'assets/images/location-pin.png'
    },
    {
      'title': 'Chatbot',
      'route': '/stores/{storeId}/chatbot',
      'icon': 'assets/images/location-pin.png'
    },
  ];

  final List<Map<String, String>> estoqueItems = [
    {
      'title': 'Estoque',
      'route': '/stores/{storeId}/inventory',
      'icon': 'assets/images/database.png'
    },
  ];

  final List<Map<String, String>> financeiroItems = [
    {
      'title': 'Contas a pagar',
      'route': '/stores/{storeId}/payables',
      'icon': 'assets/images/dollar-circle.png'
    },
    {
      'title': 'Caixa',
      'route': '/stores/{storeId}/cash',
      'icon': 'assets/images/hard-drive.png'
    },
    {
      'title': 'Relatórios',
      'route': '/stores/{storeId}/reports',
      'icon': 'assets/images/chart-trend-up1.png'
    },
  ];

  final List<Map<String, String>> sistemaItems = [
    {
      'title': 'Integrações',
      'route': '/stores/{storeId}/integrations',
      'icon': 'assets/images/33.png'
    },
    {
      'title': 'Usuários',
      'route': '/stores/{storeId}/users',
      'icon': 'assets/images/user.png'
    },
    {
      'title': 'Planos',
      'route': '/stores/{storeId}/plans',
      'icon': 'assets/images/rocket-launch.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Método para montar um grid de cards a partir de uma lista de itens
    Widget buildSection(String title, List<Map<String, String>> items) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium




            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 3 : 4,
                mainAxisExtent: 120,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final route = item['route']!.replaceAll('{storeId}', widget.storeId.toString());

                return InkWell(
                  onTap: () {
                    context.push(route);

                  },
                  child: _buildCard(
                    icon: item['icon']!,
                    title: item['title']!,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Links Rápidos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          //  buildSection('Dashboard', dashboardItems),
            buildSection('Loja', lojaItems),
            buildSection('Configuração da Loja', configuracoesItems),
            buildSection('Estoque', estoqueItems),
            buildSection('Financeiro', financeiroItems),
            buildSection('Sistema', sistemaItems),
          ],
        ),
      ),
    );
  }


  Widget _buildCard({required String icon, required String title}) {
    return Container(

      height: 92,
      width: 180,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),

            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                child: Image.asset(
                  icon,
                  color: Theme.of(context).primaryColor,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(


              title,
              textAlign: TextAlign.center,
              style: Typographyy.bodySmallSemiBold
                  .copyWith(),
             // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  // Widget _buildCard({required String iconPath, required String title}) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     padding: const EdgeInsets.all(12),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         if (iconPath.endsWith('.svg'))
  //           SvgPicture.asset(
  //             iconPath,
  //             height: 32,
  //             width: 32,
  //             color: Colors.blueAccent,
  //           )
  //         else
  //           Image.asset(
  //             iconPath,
  //             height: 32,
  //             width: 32,
  //             color: Colors.blueAccent,
  //           ),
  //         const SizedBox(height: 10),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontWeight: FontWeight.w600,
  //             fontSize: 14,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
