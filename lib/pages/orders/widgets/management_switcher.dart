import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';


// ✅ SEU WIDGET DO BOTTOM SHEET (copiado do seu arquivo e sem alterações)
class ManagementBottomSheet extends StatefulWidget {
  final bool isOrdersManagement;
  final VoidCallback onSwitchManagement;

  const ManagementBottomSheet({
    Key? key,
    required this.isOrdersManagement,
    required this.onSwitchManagement,
  }) : super(key: key);

  @override
  _ManagementBottomSheetState createState() => _ManagementBottomSheetState();
}

class _ManagementBottomSheetState extends State<ManagementBottomSheet> {
  bool _keepScreenOpen = true;

  @override
  Widget build(BuildContext context) {
    final bool isOrdersManagement = widget.isOrdersManagement;
    final String currentManagement = isOrdersManagement ? 'Pedidos' : 'Loja';
    final String oppositeManagement = isOrdersManagement ? 'Loja' : 'Pedidos';

    final String title = isOrdersManagement ? 'Gestão de pedidos' : 'Gestão de loja';
    final String description = isOrdersManagement
        ? 'Aqui você pode acompanhar os pedidos que sua loja recebe'
        : 'Aqui você gerencia seu estabelecimento';
    final String switchDescription = isOrdersManagement
        ? 'Troque para a Gestão de Loja e confira os seus repasses, avaliações, cardápio e muito mais'
        : 'Troque para a Gestão de Pedidos e acompanhe os pedidos em tempo real';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com botão de fechar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição principal
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Descrição de troca
                  Text(
                    switchDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Checkbox para manter tela aberta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _keepScreenOpen,
                        onChanged: (value) {
                          setState(() {
                            _keepScreenOpen = value ?? true;
                          });
                        },
                        activeColor: Color(0xFF2E7D32),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Para que a Gestão de $currentManagement funcione normalmente e sua loja não feche, deixe a tela principal de $currentManagement aberta ou tente acessá-la frequentemente.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Botão de trocar gestão
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onSwitchManagement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Trocar para Gestão de $oppositeManagement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ✅ NOVA FUNÇÃO GLOBAL PARA MOSTRAR O BOTTOM SHEET
void showManagementSwitcher(BuildContext context) {
  // 1. Descobrimos a rota atual para saber em qual modo estamos
  final String currentRoute = GoRouterState.of(context).uri.toString();
  final bool isOrdersManagement = currentRoute.contains('/orders');

  // Pega o ID da loja ativa para poder navegar corretamente
  final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;
  if (storeId == null) return; // Segurança

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return ManagementBottomSheet(
        isOrdersManagement: isOrdersManagement,
        onSwitchManagement: () {
          // 2. LÓGICA DE NAVEGAÇÃO
          Navigator.pop(ctx); // Fecha o BottomSheet

          if (isOrdersManagement) {
            // Se estamos em Pedidos, vamos para a Gestão (Dashboard)
            context.go('/stores/$storeId/dashboard');
          } else {
            // Se estamos na Gestão, vamos para Pedidos
            context.go('/stores/$storeId/orders');
          }
        },
      );
    },
  );
}


// ✅ NOVO WIDGET REUTILIZÁVEL PARA A APPBAR
class AppBarModeSwitcher extends StatelessWidget {
  const AppBarModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    // Descobre a rota atual para exibir o título correto
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final bool isOrdersManagement = currentRoute.contains('/orders');
    final String title = isOrdersManagement ? 'Pedidos' : 'Loja';

    return InkWell(
      onTap: () {
        // Chama nossa função global
        showManagementSwitcher(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}