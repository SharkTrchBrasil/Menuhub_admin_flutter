
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

class ProductVariantLink {
  final UIDisplayMode uiDisplayMode;
  final int minSelectedOptions;
  final int maxSelectedOptions;
  final int? maxTotalQuantity;
  final Variant variant; // O template Variant está aninhado aqui

  ProductVariantLink({
    required this.uiDisplayMode,
    required this.minSelectedOptions,
    required this.maxSelectedOptions,
    this.maxTotalQuantity,
    required this.variant,
  });

  // Getter para a UI saber se o grupo é obrigatório
  bool get isRequired => minSelectedOptions > 0;

  /// ✅ CORRIGIDO: Constrói o objeto a partir do JSON recebido da API.
  factory ProductVariantLink.fromJson(Map<String, dynamic> json) {

    // Helper para converter a string do JSON para o nosso Enum
    UIDisplayMode modeFromString(String? modeStr) {
      switch (modeStr) {
        case "Seleção Única":
          return UIDisplayMode.SINGLE;
        case "Seleção Múltipla":
          return UIDisplayMode.MULTIPLE;
        case "Seleção com Quantidade":
          return UIDisplayMode.QUANTITY;
        default:
          return UIDisplayMode.UNKNOWN;
      }
    }

    return ProductVariantLink(
      variant: Variant.fromJson(json['variant']),
      uiDisplayMode: modeFromString(json['ui_display_mode']),
      minSelectedOptions: json['min_selected_options'],
      maxSelectedOptions: json['max_selected_options'],
      // ... (outros campos)
    );
  }

  /// ✅ CORRIGIDO: Converte o objeto para o JSON que a API espera ao salvar.
  Map<String, dynamic> toJson() {

    // Helper para converter nosso Enum para a string que a API espera
    String modeToString(UIDisplayMode mode) {
      switch (mode) {
        case UIDisplayMode.SINGLE:
          return "Seleção Única";
        case UIDisplayMode.MULTIPLE:
          return "Seleção Múltipla";
        case UIDisplayMode.QUANTITY:
          return "Seleção com Quantidade";
        default:
          return "";
      }
    }

    return {
      'ui_display_mode': modeToString(uiDisplayMode),
      'min_selected_options': minSelectedOptions,
      'max_selected_options': maxSelectedOptions,
      'max_total_quantity': maxTotalQuantity,
      // O 'variant' não é enviado aqui, pois o ID dele já está na URL da API
    };
  }


}