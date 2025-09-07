import 'package:equatable/equatable.dart'; // 1. (Opcional, mas recomendado) Adicione o pacote equatable no seu pubspec.yaml
import 'package:image_picker/image_picker.dart';

// 2. Faça a classe estender Equatable
class ImageModel extends Equatable {
  // 3. Adicione 'const' ao construtor
  const ImageModel({
    this.url,
    this.file,
  });

  final String? url;
  final XFile? file;

  // 4. (Opcional) Implemente a props do Equatable
  @override
  List<Object?> get props => [url, file];
}