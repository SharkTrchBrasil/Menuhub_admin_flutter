
class BrazilianStates {
// ✅ Mapeamento Nome → Sigla (com variações)
static const Map<String, String> _stateNameToAbbr = {
// Acre
'acre': 'AC',
// Alagoas
'alagoas': 'AL',
// Amapá
'amapá': 'AP',
'amapa': 'AP',
// Amazonas
'amazonas': 'AM',
// Bahia
'bahia': 'BA',
// Ceará
'ceará': 'CE',
'ceara': 'CE',
// Distrito Federal
'distrito federal': 'DF',
'df': 'DF',
// Espírito Santo
'espírito santo': 'ES',
'espirito santo': 'ES',
'es': 'ES',
// Goiás
'goiás': 'GO',
'goias': 'GO',
// Maranhão
'maranhão': 'MA',
'maranhao': 'MA',
// Mato Grosso
'mato grosso': 'MT',
'mt': 'MT',
// Mato Grosso do Sul
'mato grosso do sul': 'MS',
'ms': 'MS',
// Minas Gerais
'minas gerais': 'MG',
'mg': 'MG',
// Pará
'pará': 'PA',
'para': 'PA',
// Paraíba
'paraíba': 'PB',
'paraiba': 'PB',
// Paraná
'paraná': 'PR',
'parana': 'PR',
// Pernambuco
'pernambuco': 'PE',
// Piauí
'piauí': 'PI',
'piaui': 'PI',
// Rio de Janeiro
'rio de janeiro': 'RJ',
'rj': 'RJ',
// Rio Grande do Norte
'rio grande do norte': 'RN',
'rn': 'RN',
// Rio Grande do Sul
'rio grande do sul': 'RS',
'rs': 'RS',
// Rondônia
'rondônia': 'RO',
'rondonia': 'RO',
// Roraima
'roraima': 'RR',
// Santa Catarina
'santa catarina': 'SC',
'sc': 'SC',
// São Paulo
'são paulo': 'SP',
'sao paulo': 'SP',
'sp': 'SP',
// Sergipe
'sergipe': 'SE',
// Tocantins
'tocantins': 'TO',
};

// ✅ Siglas válidas
static const Set<String> _validAbbreviations = {
'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
};

/// Normaliza o estado para sigla (UF)
///
/// Aceita:
/// - Siglas (ex: 'SP', 'RJ')
/// - Nomes completos (ex: 'São Paulo', 'Rio de Janeiro')
///
/// Retorna:
/// - Sigla normalizada (ex: 'SP') ou null se inválido
///
/// Exemplos:
/// ```dart
/// BrazilianStates.normalizeState('São Paulo')  // 'SP'
/// BrazilianStates.normalizeState('SP')         // 'SP'
/// BrazilianStates.normalizeState('sp')         // 'SP'
/// BrazilianStates.normalizeState('Minas Gerais') // 'MG'
/// BrazilianStates.normalizeState('inválido')   // null
/// ```
static String? normalizeState(String? state) {
if (state == null || state.trim().isEmpty) {
return null;
}

final stateClean = state.trim();
final stateUpper = stateClean.toUpperCase();

// 1. Se já é uma sigla válida
if (_validAbbreviations.contains(stateUpper)) {
return stateUpper;
}

// 2. Tenta converter nome completo → sigla
final stateLower = stateClean.toLowerCase();
if (_stateNameToAbbr.containsKey(stateLower)) {
return _stateNameToAbbr[stateLower];
}

// 3. Não encontrou
return null;
}

/// Valida se o estado é válido (sigla ou nome completo)
///
/// Exemplos:
/// ```dart
/// BrazilianStates.isValid('SP')         // true
/// BrazilianStates.isValid('São Paulo')  // true
/// BrazilianStates.isValid('inválido')   // false
/// ```
static bool isValid(String? state) {
return normalizeState(state) != null;
}

/// Retorna lista de todas as siglas válidas
static List<String> getAllAbbreviations() {
return _validAbbreviations.toList()..sort();
}

/// Retorna mapa Sigla → Nome completo
static Map<String, String> getAbbrToNameMap() {
return const {
'AC': 'Acre',
'AL': 'Alagoas',
'AP': 'Amapá',
'AM': 'Amazonas',
'BA': 'Bahia',
'CE': 'Ceará',
'DF': 'Distrito Federal',
'ES': 'Espírito Santo',
'GO': 'Goiás',
'MA': 'Maranhão',
'MT': 'Mato Grosso',
'MS': 'Mato Grosso do Sul',
'MG': 'Minas Gerais',
'PA': 'Pará',
'PB': 'Paraíba',
'PR': 'Paraná',
'PE': 'Pernambuco',
'PI': 'Piauí',
'RJ': 'Rio de Janeiro',
'RN': 'Rio Grande do Norte',
'RS': 'Rio Grande do Sul',
'RO': 'Rondônia',
'RR': 'Roraima',
'SC': 'Santa Catarina',
'SP': 'São Paulo',
'SE': 'Sergipe',
'TO': 'Tocantins',
};
}
}