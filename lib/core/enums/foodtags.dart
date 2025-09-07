// Os nomes devem corresponder exatamente aos do backend (respeitando camelCase vs snake_case na serialização)
enum FoodTag {
  vegetarian,
  vegan,
  organic,
  sugarFree,
  lacFree,
}

// Mapa para obter a descrição de cada tag
const Map<FoodTag, String> foodTagDescriptions = {
  FoodTag.vegetarian: 'Sem carne de nenhum tipo',
  FoodTag.vegan: 'Sem produtos de origem animal, como carne, ovo ou leite',
  FoodTag.organic: 'Cultivado sem agrotóxicos',
  FoodTag.sugarFree: 'Não contém nenhum tipo de açúcar',
  FoodTag.lacFree: 'Não contém lactose',
};

// Mapa para obter o nome formatado de cada tag
const Map<FoodTag, String> foodTagNames = {
  FoodTag.vegetarian: 'Vegetariano',
  FoodTag.vegan: 'Vegano',
  FoodTag.organic: 'Orgânico',
  FoodTag.sugarFree: 'Sem açúcar',
  FoodTag.lacFree: 'Zero lactose',
};

// ✅ ADICIONE ESTE MAPA "TRADUTOR"
const Map<FoodTag, String> foodTagApiValues = {
  FoodTag.vegetarian: 'Vegetariano',
  FoodTag.vegan: 'Vegano',
  FoodTag.organic: 'Orgânico',
  FoodTag.sugarFree: 'Sem açúcar',
  FoodTag.lacFree: 'Zero lactose',
};