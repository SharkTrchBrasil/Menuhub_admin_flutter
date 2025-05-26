import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class StorePixConfig {
  final String pixKey;
  final String? clientId;
  final String? clientSecret;
  final XFile? certificate;
  final bool isActive;

  const StorePixConfig({
    this.pixKey = '',
    this.clientId,
    this.clientSecret,
    this.certificate,
    this.isActive = false,
  });

  StorePixConfig copyWith({
    String? pixKey,
    String? clientId,
    String? clientSecret,
    XFile? certificate,
  }) {
    return StorePixConfig(
      pixKey: pixKey ?? this.pixKey,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      certificate: certificate ?? this.certificate,
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'pix_key': pixKey,
      'client_id': clientId,
      'client_secret': clientSecret,
      'certificate': MultipartFile.fromBytes(
        await certificate!.readAsBytes(),
        filename: 'certificate.pem',
        contentType: DioMediaType.parse('application/x-pem-file'),
      ),
    });
  }

  factory StorePixConfig.fromJson(Map<String, dynamic> map) {
    return StorePixConfig(
      pixKey: map['pix_key'] as String,
      isActive: map['is_active'] as bool,
    );
  }
}
