// ✅ NOVO ENUM PARA AS ESTRATÉGIAS
enum PricingStrategy {
  sumOfItems,       // Soma o preço de todos os itens selecionados
  highestPrice,     // O preço final é o do item mais caro selecionado
  lowestPrice,      // O preço final é o do item mais barato selecionado
}