// lib/models/pizza_model.dart

import 'package:equatable/equatable.dart';
class PizzaSize extends Equatable {
  final int? dbId;
  final String id;
  final String name;
  final int slices; // Renomeado de 'pieces' para 'slices' para consistência com o CUBIT
  final int flavors; // Máximo de sabores permitidos
  final String externalCode;
  final String? imageUrl;
  final bool isActive; // Renomeado de 'status' para 'isActive' para consistência

  const PizzaSize({
    required this.id,
    this.dbId, // ✨
    this.name = '',
    this.slices = 0,
    this.flavors = 1,
    this.externalCode = '',
    this.imageUrl,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, slices, flavors, externalCode, imageUrl, isActive];

  PizzaSize copyWith({
    String? name,
    int? slices,
    int? flavors,
    String? externalCode,
    String? imageUrl,
    bool? isActive,
  }) {
    return PizzaSize(
      id: id,
      name: name ?? this.name,
      slices: slices ?? this.slices,
      flavors: flavors ?? this.flavors,
      externalCode: externalCode ?? this.externalCode,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}


// Modelo genérico para Massas e Bordas
class PizzaOption extends Equatable {
  final String id;
  final int? dbId;
  final String name;
  final int price; // em centavos
  final bool isAvailable;

  // ✅ NOVO CAMPO ADICIONADO
  final String externalCode; // Cód. PDV

  const PizzaOption({
    required this.id,
    this.dbId,
    this.name = '',
    this.price = 0,
    this.isAvailable = true,
    // ✅ VALOR PADRÃO PARA O NOVO CAMPO
    this.externalCode = '',
  });

  @override
  // ✅ ATUALIZADO: props para o Equatable
  List<Object?> get props => [id, name, price, isAvailable, externalCode];

  // ✅ ATUALIZADO: copyWith com todos os campos
  PizzaOption copyWith({
    String? name,
    int? price,
    bool? isAvailable,
    String? externalCode,
  }) {
    return PizzaOption(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      externalCode: externalCode ?? this.externalCode,
    );


  }}