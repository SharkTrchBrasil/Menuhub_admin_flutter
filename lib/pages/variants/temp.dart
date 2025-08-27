import 'package:flutter/material.dart';


class GroupEditScreen extends StatefulWidget {
  const GroupEditScreen({super.key});

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edição de grupo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Grupos de complementos',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, size: 16),
                ),
                const Text(
                  'Edição de grupo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Group title and pause button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Turbine seu lanche',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text('Pausar grupo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                _buildTab(0, 'Complementos'),
                _buildTab(1, 'Produtos vinculados'),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar complemento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: const Row(
              children: [
                SizedBox(width: 15),
                SizedBox(width: 75, child: Text('Imagem')),
                SizedBox(width: 200, child: Text('Produto')),
                SizedBox(width: 200, child: Text('Canal de venda')),
                SizedBox(width: 130, child: Text('Preço')),
                SizedBox(width: 130, child: Text('Código PDV')),
                SizedBox(width: 80, child: Text('Ações')),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: ListView(
              children: const [
                ProductItem(
                  imageUrl: 'https://static-images.ifood.com.br/pratos/3900c306-26fe-4d16-acac-1b57791c6dda/202507281101_OM6F_i.jpg',
                  name: 'Bifé de picanha',
                  channel: 'Aplicativo iFood',
                  price: 'R\$ 1,00',
                  pdvCode: '',
                ),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Salvar alterações'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String channel;
  final String price;
  final String pdvCode;

  const ProductItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.channel,
    required this.price,
    required this.pdvCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15, child: Icon(Icons.drag_handle, color: Colors.grey)),
          SizedBox(
            width: 75,
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black54,
                    child: const Text(
                      'Alterar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 200, child: Text(name)),
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Image.asset(
                  'assets/ifood_icon.png', // Você precisaria adicionar este asset
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(channel),
              ],
            ),
          ),
          SizedBox(width: 130, child: Text(price)),
          SizedBox(
            width: 130,
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}