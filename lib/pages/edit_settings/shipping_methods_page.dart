import 'package:flutter/material.dart';


class EditShippingMethodsPage extends StatelessWidget {
  final int storeId;

  const EditShippingMethodsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formas de Entrega')),
      body: Center(child: Text('Editar entregas da loja: $storeId')),
    );
  }
}
