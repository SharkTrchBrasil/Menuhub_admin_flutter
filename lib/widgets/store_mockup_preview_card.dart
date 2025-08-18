import 'package:flutter/material.dart';
import '../models/store.dart';

class StoreProfilePreviewCard extends StatelessWidget {
  final Store store;
  const StoreProfilePreviewCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    // --- Lógica de dados (permanece a mesma) ---
    final logoUrl = store.media?.image?.url?.isNotEmpty == true
        ? store.media!.image!.url!
        : 'https://images.ctfassets.net/kugm9fp9ib18/3aHPaEUU9HKYSVj1CTng58/d6750b97344c1dc31bdd09312d74ea5b/menu-default-image_220606_web.png';
    final bannerUrl = store.media?.banner?.url?.isNotEmpty == true
        ? store.media!.banner!.url!
        : 'https://portal.ifood.com.br/partner-portal-merchant-profile-web-front/static/image/default-profile-image.2c669f74.png';
    final categoryName = store.core.name ?? "Categoria";
    final rating = store.relations.ratingsSummary?.averageRating.toStringAsFixed(1) ?? "N/A";
    final deliveryTime = store.relations.storeOperationConfig != null
        ? '${store.relations.storeOperationConfig!.deliveryEstimatedMin}-${store.relations.storeOperationConfig!.deliveryEstimatedMax} min'
        : '30-45 min';
    final minOrder = store.relations.storeOperationConfig?.deliveryMinOrder ?? '0,00';

    final double finalWidth = 250.0;
    final double finalHeight = 355.0;

    // --- Estrutura da UI Corrigida ---
    return Container(
      width: finalWidth,
      height: finalHeight,
      // O ClipRRect e a decoração da borda ficam no contêiner pai
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          // Ao não especificar bottomLeft e bottomRight, eles ficam retos (Radius.zero)
        ),
        color: Colors.grey[100], // A cor de fundo permanece
        border: const Border(
          top: BorderSide(color: Colors.grey, width: 8),
          left: BorderSide(color: Colors.grey, width: 8),
          right: BorderSide(color: Colors.grey, width: 8),
          bottom: BorderSide.none, // <-- A MÁGICA ACONTECE AQUI
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          // Ao não especificar bottomLeft e bottomRight, eles ficam retos (Radius.zero)
        ), // Raio um pouco menor que o da borda
        child: Scaffold(
          // Usamos um Scaffold para ter um fundo branco padrão para o "app"
          backgroundColor: Colors.white,
          body: Stack(
            // O Stack agora organiza o conteúdo sobre o fundo
            children: [
              // Camada 1: O conteúdo do seu preview
              Positioned.fill(
                child: Column(
                  children: [
                    // Banner na parte superior
                    Container(
                      height: 180, // Altura do banner
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(bannerUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) => print("Erro ao carregar banner"),
                        ),
                      ),
                    ),
                    // Espaço para o card de informações
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),

              // Camada 2: O card de informações que flutua sobre o banner
              Positioned(
                top: 130, // Posição para o card começar abaixo do topo do banner
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.core.name.isEmpty ? 'Nome da Loja' : store.core.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(rating),
                          const SizedBox(width: 8),
                          const Text("•"),
                          const SizedBox(width: 8),
                          Text(categoryName),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pedido Mínimo R\$ $minOrder',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            deliveryTime,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Camada 3: A logo que flutua sobre tudo
              Positioned(
                top: 90, // Posição para a logo ficar sobre a junção do banner e do card
                // Centraliza a logo horizontalmente
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(logoUrl),
                    radius: 40,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}