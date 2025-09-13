enum ProductStatus {
  ACTIVE,
  INACTIVE,
  ARCHIVED,
}

// Função auxiliar para converter a string da API para o enum
ProductStatus productStatusFromString(String? statusString) {
  if (statusString == null) return ProductStatus.INACTIVE;
  return ProductStatus.values.firstWhere(
        (e) => e.name == statusString,
    orElse: () => ProductStatus.INACTIVE, // Valor padrão seguro
  );
}