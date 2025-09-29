
import 'package:totem_pro_admin/models/variant.dart';

import '../../models/products/product.dart';

/// Uma função reutilizável que gera uma string com os nomes dos produtos
/// vinculados a um determinado [variant].
String getVariantLinkedProductsPreview({
  required Variant variant,
  required List<Product> allProducts,
}) {
  if (allProducts.isEmpty) {
    return 'Não vinculado a produtos';
  }

  // A lógica exata que você já tinha, agora em um lugar central.
  final linkedProductNames = allProducts
      .where((product) =>
  product.variantLinks?.any((link) => link.variant.id == variant.id) ?? false)
      .map((product) => product.name)
      .toList();

  if (linkedProductNames.isEmpty) {
    return 'Não vinculado a produtos';
  }

  const int maxNamesToShow = 2;
  if (linkedProductNames.length > maxNamesToShow) {
    final firstNames = linkedProductNames.take(maxNamesToShow).join(', ');
    final remainingCount = linkedProductNames.length - maxNamesToShow;
    return 'Disponível em: $firstNames e mais $remainingCount';
  } else {
    return 'Disponível em: ${linkedProductNames.join(', ')}';
  }
}
