import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store/store.dart';

class IfoodHeader extends StatelessWidget {
  final Store? activeStore;

  const IfoodHeader({super.key, required this.activeStore});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Logo iFood (simulada)
          _buildLogo(),

          const Spacer(),

          // Informações do usuário
          _buildUserInfo(),

          const SizedBox(width: 16),

          // Ícones de ação
          _buildActionIcons(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEA1D2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://static-images.ifood.com.br/image/upload/f_auto,t_thumbnail/logosgde/3900c306-26fe-4d16-acac-1b57791c6dda/202507301031_Nu4W_f.jpg',
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activeStore?.core.name ?? 'Cristiano Silva Almeida',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Loja fechada',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildActionIcons() {
    return Row(
      children: [
        _buildHeaderIcon(Icons.headset_mic, 'Atendimentos'),
        const SizedBox(width: 12),
        _buildHeaderIcon(Icons.chat_bubble_outline, 'Conversas'),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }
}