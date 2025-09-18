import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

// Coloque todas as suas definições compartilhadas aqui

typedef OnLinkRulesChanged = void Function(ProductVariantLink updatedLink);
typedef OnOptionUpdated = void Function(VariantOption updatedOption);
typedef OnOptionRemoved = void Function(VariantOption optionToRemove);
typedef OnLinkNameChanged = void Function(String newName);
// ... e qualquer outro que seja compartilhado