
import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';


class ImageModel extends Equatable {
  // ✅ ID da imagem que já existe no banco de dados.
  // Será nulo para imagens novas, recém-selecionadas.
  final int? id;

  // URL da imagem vinda do servidor.
  // Será nulo para imagens novas.
  final String? url;

  // Arquivo local da imagem (para novas imagens).
  // Será nulo para imagens que já estão no servidor.
  final XFile? file;

  const ImageModel({
    this.id,
    this.url,
    this.file,
  });

  // ✅ Construtor para criar a partir do JSON da API
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      url: json['image_url'],
    );
  }

  @override
  List<Object?> get props => [id, url, file];
}