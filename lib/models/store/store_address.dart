// store_address.dart
class StoreAddress {
  final String? zipCode;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? complement;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? deliveryRadiusKm;

  StoreAddress({
    this.zipCode,
    this.street,
    this.number,
    this.neighborhood,
    this.complement,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.deliveryRadiusKm,
  });

  factory StoreAddress.fromJson(Map<String, dynamic> json) {
    return StoreAddress(
      zipCode: json['zip_code'],
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      complement: json['complement'],
      city: json['city'],
      state: json['state'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      deliveryRadiusKm: json['delivery_radius_km']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zip_code': zipCode,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_radius_km': deliveryRadiusKm,
    };
  }

  StoreAddress copyWith({
    String? zipCode,
    String? street,
    String? number,
    String? neighborhood,
    String? complement,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    double? deliveryRadiusKm,
  }) {
    return StoreAddress(
      zipCode: zipCode ?? this.zipCode,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      complement: complement ?? this.complement,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
    );
  }
}