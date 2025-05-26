import 'package:dio/dio.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';

class StorePaymentMethod implements SelectableItem {
  const StorePaymentMethod({
    this.id,

    required this.paymentType,        // 'Cash', 'Card', 'Pix', 'Other'…
    required this.customName,
    this.customIcon,                  // ex.: 'cash.svg'

    this.isActive       = true,
    this.activeOnDelivery = true,
    this.activeOnPickup   = true,
    this.activeOnCounter  = true,
    this.taxRate        = 0.0,


    this.pixKey,

  });

  final int? id;


  // obrigatórios
  final String paymentType;
  final String customName;

  // opcionais
  final String? customIcon;

  // flags

  final bool isActive;

  // canais
  final bool activeOnDelivery;
  final bool activeOnPickup;
  final bool activeOnCounter;

  // financeiro
  final double taxRate;



  // Pix
  final String? pixKey;


  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  /* JSON <‑‑> MODEL                                            */
  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/

  factory StorePaymentMethod.fromJson(Map<String, dynamic> json) {



    return StorePaymentMethod(
      id                : json['id'] as int?,

      paymentType       : json['payment_type'] as String,
      customName        : json['custom_name'] as String,
      customIcon       : json['custom_icon'] as String?,
      isActive          : json['is_active'] as bool? ?? true,
      activeOnDelivery  : json['active_on_delivery'] as bool? ?? true,
      activeOnPickup    : json['active_on_pickup'] as bool? ?? true,
      activeOnCounter   : json['active_on_counter'] as bool? ?? true,
      taxRate           : json['tax_rate'] as double ?? 0.0,

      pixKey            : json['pix_key'] as String?,

    );
  }

  Map<String, dynamic> toJson() => {
    'id'                 : id,

    'payment_type'       : paymentType,
    'custom_name'        : customName,
    'custom_icon'        : customIcon,

    'is_active'          : isActive,
    'active_on_delivery' : activeOnDelivery,
    'active_on_pickup'   : activeOnPickup,
    'active_on_counter'  : activeOnCounter,
    'tax_rate'           : taxRate,

    'pix_key'            : pixKey,

  };

  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  /* Envio em multipart (FormData) – para API FastAPI            */
  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  StorePaymentMethod copyWith({
    int? id,

    String? paymentType,
    String? customName,
    String? customIcon,

    bool? isActive,
    bool? activeOnDelivery,
    bool? activeOnPickup,
    bool? activeOnCounter,
    double? taxRate,

    String? pixKey,

  }) {
    return StorePaymentMethod(
      id: id ?? this.id,

      paymentType: paymentType ?? this.paymentType,
      customName: customName ?? this.customName,
      customIcon: customIcon ?? this.customIcon,

      isActive: isActive ?? this.isActive,
      activeOnDelivery: activeOnDelivery ?? this.activeOnDelivery,
      activeOnPickup: activeOnPickup ?? this.activeOnPickup,
      activeOnCounter: activeOnCounter ?? this.activeOnCounter,
      taxRate: taxRate ?? this.taxRate,
      pixKey: pixKey ?? this.pixKey,

    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'payment_type'       : paymentType,
      'custom_name'        : customName,
      'custom_icon'        : customIcon,     // nome/slug do asset

      'is_active'          : isActive,
      'active_on_delivery' : activeOnDelivery,
      'active_on_pickup'   : activeOnPickup,
      'active_on_counter'  : activeOnCounter,
      'tax_rate'           : taxRate,

      'pix_key'            : pixKey,

    });
  }

  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  /* SelectableItem interface                                   */
  /*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  @override
  String get title => customName;
}
