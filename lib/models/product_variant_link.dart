import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../core/enums/ui_display_mode.dart'; // Importe o enum

class ProductVariantLink {
  final UIDisplayMode uiDisplayMode;
  final int minSelectedOptions;
  final int maxSelectedOptions;
  final int? maxTotalQuantity;
  final Variant variant;
  final bool available;

  ProductVariantLink({
    required this.uiDisplayMode,
    required this.minSelectedOptions,
    required this.maxSelectedOptions,
    this.maxTotalQuantity,
    required this.variant,
  this.available = true,
  });

  bool get isRequired => minSelectedOptions > 0;

  // ✅ MÉTODO copyWith ADICIONADO
  /// Cria uma cópia deste objeto, substituindo os valores fornecidos.
  ProductVariantLink copyWith({
    UIDisplayMode? uiDisplayMode,
    int? minSelectedOptions,
    int? maxSelectedOptions,
    int? maxTotalQuantity,
    Variant? variant,
    bool? available,
  }) {
    return ProductVariantLink(
      uiDisplayMode: uiDisplayMode ?? this.uiDisplayMode,
      minSelectedOptions: minSelectedOptions ?? this.minSelectedOptions,
      maxSelectedOptions: maxSelectedOptions ?? this.maxSelectedOptions,
      maxTotalQuantity: maxTotalQuantity ?? this.maxTotalQuantity,
      variant: variant ?? this.variant,
      available: available ?? this.available,
    );
  }

  factory ProductVariantLink.fromJson(Map<String, dynamic> json) {
    UIDisplayMode modeFromString(String? modeStr) {
      switch (modeStr) {
        case "Seleção Única": return UIDisplayMode.SINGLE;
        case "Seleção Múltipla": return UIDisplayMode.MULTIPLE;
        case "Seleção com Quantidade": return UIDisplayMode.QUANTITY;

        default: return UIDisplayMode.UNKNOWN;
      }
    }

    return ProductVariantLink(
      variant: Variant.fromJson(json['variant']),
      uiDisplayMode: modeFromString(json['ui_display_mode']),
      minSelectedOptions: json['min_selected_options'],
      maxSelectedOptions: json['max_selected_options'],
      maxTotalQuantity: json['max_total_quantity'],
      available: json['available'] ?? true,
    );
  }

  // ✅ MÉTODO `toJson` CORRIGIDO E UNIFICADO
  Map<String, dynamic> toJson() {
    String modeToString(UIDisplayMode mode) {
      switch (mode) {
        case UIDisplayMode.SINGLE: return "Seleção Única";
        case UIDisplayMode.MULTIPLE: return "Seleção Múltipla";
        case UIDisplayMode.QUANTITY: return "Seleção com Quantidade";
        default: return "";
      }
    }

    return {
      'ui_display_mode': modeToString(uiDisplayMode),
      'min_selected_options': minSelectedOptions,
      'max_selected_options': maxSelectedOptions,
     // 'max_total_quantity': maxTotalQuantity,
      'available': available,

      // A lógica correta que estava no `toWizardJson` agora está aqui
      'variant': variant.toJson(),
    };
  }




}