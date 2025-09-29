
import 'package:totem_pro_admin/models/variant_option.dart';

import '../../../models/products/product_variant_link.dart';

// Coloque todas as suas definições compartilhadas aqui

typedef OnLinkRulesChanged = void Function(ProductVariantLink updatedLink);
typedef OnOptionUpdated = void Function(VariantOption updatedOption);
typedef OnOptionRemoved = void Function(VariantOption optionToRemove);
typedef OnLinkNameChanged = void Function(String newName);
// ... e qualquer outro que seja compartilhado