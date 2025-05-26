import 'package:flutter/material.dart';

import '../../../models/image_model.dart';
import '../../../models/store.dart';


class StoreController {
  bool isInitialized = false;
  final nameController = TextEditingController();

  final phoneController = TextEditingController(); // valor padrão

  final zipCodeController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final complementController = TextEditingController();
  final referenceController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final tiktokController = TextEditingController();

  // Adicionando o controlador para a imagem
  ImageModel? image;

  void initControllers(Store store) {



    nameController.text = store.name ?? '';

    phoneController.text = store.phone ?? '';
    zipCodeController.text = store.zip_code ?? '';
    streetController.text = store.street ?? '';
    numberController.text = store.number ?? '';
    neighborhoodController.text = store.neighborhood ?? '';
    complementController.text = store.complement ?? '';
    referenceController.text = store.reference ?? '';
    cityController.text = store.city ?? '';
    stateController.text = store.state ?? '';
    instagramController.text = store.instagram ?? '';
    facebookController.text = store.facebook ?? '';
    tiktokController.text = store.tiktok ?? '';
    image = store.image;  // Inicializa com a imagem do produto, se houver.
  }

  // Função para alterar a imagem
  void setImage(ImageModel? newImage) {
    image = newImage;
  }




  // Se precisar limpar tudo:
  void dispose() {
    nameController.dispose();

    phoneController.dispose();
    zipCodeController.dispose();
    streetController.dispose();
    numberController.dispose();
    neighborhoodController.dispose();
    complementController.dispose();
    referenceController.dispose();
    cityController.dispose();
    stateController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    tiktokController.dispose();
  }

  // Método para gerar um Store a partir dos dados dos controllers
  Store toStore() {
    return Store(
      name: nameController.text,

      phone: phoneController.text,
      zip_code: zipCodeController.text,
      street: streetController.text,
      number: numberController.text,
      neighborhood: neighborhoodController.text,
      complement: complementController.text,
      reference: referenceController.text,
      city: cityController.text,
      state: stateController.text,
      instagram: instagramController.text,
      facebook: facebookController.text,
      tiktok: tiktokController.text,
      image: image,  // Adiciona a imagem no modelo
    );
  }
}
