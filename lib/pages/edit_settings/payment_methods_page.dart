import 'package:flutter/material.dart';

class EditPaymentMethodsPage extends StatelessWidget {
  final int storeId;

  const EditPaymentMethodsPage({super.key, required this.storeId});











  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formas de Pagamento')),
      body: Center(child: Text('Editar pagamentos da loja: $storeId')),
    );
  }
}
