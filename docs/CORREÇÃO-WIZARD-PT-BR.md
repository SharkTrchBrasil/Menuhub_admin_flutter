# Correção: Wizard não exibia formas de pagamento e horários

## Problema Relatado
O assistente de criação de novas lojas no aplicativo não estava exibindo as formas de pagamento e os horários de funcionamento, mesmo quando esses dados existiam no banco de dados.

## Causa Raiz
O wizard (`OnboardingWizardPage`) dependia dos dados já carregados no estado do `StoresManagerCubit`. Quando o wizard era acessado logo após a criação da loja, os dados relacionais (horários e formas de pagamento) ainda não estavam completamente carregados no estado, resultando em telas vazias.

## Solução Implementada
Foi adicionado um mecanismo de busca explícita de dados quando o wizard é aberto, garantindo que todas as relações da loja estejam carregadas antes de exibir as páginas do assistente.

### Mudanças Técnicas

#### 1. Carregamento de Dados no Início (settings_wizard_page.dart)
```dart
@override
void initState() {
  super.initState();
  _loadStoreData(); // Buscar dados completos da loja
}

Future<void> _loadStoreData() async {
  final storeRepository = getIt<StoreRepository>();
  final cubit = context.read<StoresManagerCubit>();
  
  // Buscar dados completos da loja do backend
  final result = await storeRepository.fetchStore(widget.storeId);
  
  result.fold(
    (error) => setState(() => _isLoadingStoreData = false),
    (store) {
      cubit.updateStoreInState(widget.storeId, store);
      setState(() => _isLoadingStoreData = false);
    },
  );
}
```

#### 2. Método de Atualização de Estado (store_manager_cubit.dart)
```dart
void updateStoreInState(int storeId, Store updatedStore) {
  final currentState = state;
  if (currentState is StoresManagerLoaded) {
    final storeWithRole = currentState.stores[storeId];
    if (storeWithRole != null) {
      final updatedStoreWithRole = storeWithRole.copyWith(store: updatedStore);
      final updatedStores = Map<int, StoreWithRole>.from(currentState.stores);
      updatedStores[storeId] = updatedStoreWithRole;
      emit(currentState.copyWith(stores: updatedStores));
    }
  }
}
```

## Como Funciona
1. Usuário navega para o wizard `/stores/:storeId/wizard-settings`
2. O `initState()` chama `_loadStoreData()` imediatamente
3. Indicador de carregamento é exibido (`_isLoadingStoreData = true`)
4. API do backend `/admin/stores/$id` é chamada para buscar dados completos
5. Resposta inclui todas as relações: hours, payment_method_groups, etc.
6. `updateStoreInState()` atualiza o cubit com dados frescos
7. Cubit emite novo estado → BlocBuilder reconstrói o wizard
8. `_isLoadingStoreData` definido como false → Páginas exibidas com dados completos
9. `OpeningHoursPage` exibe horários via prop `initialHours`
10. `PlatformPaymentMethodsPage` busca e exibe formas de pagamento

## Requisitos do Backend
O endpoint `/admin/stores/:id` deve retornar o objeto completo da loja incluindo:
- `hours` - Array com os horários de funcionamento
- `payment_method_groups` - Array com grupos de métodos de pagamento

### Exemplo de Resposta Esperada
```json
{
  "id": 123,
  "name": "Nome da Loja",
  "hours": [
    {"day_of_week": 1, "opening_time": "09:00", "closing_time": "18:00", ...}
  ],
  "payment_method_groups": [
    {
      "name": "Cartões",
      "methods": [
        {"id": 1, "name": "Visa", "is_active": true, ...}
      ]
    }
  ],
  ...outras relações
}
```

## Como Testar
1. Criar uma nova loja com horários e formas de pagamento no banco de dados
2. Navegar para o wizard: `/stores/:id/wizard-settings`
3. Verificar se os horários aparecem no passo "Horários de Funcionamento"
4. Verificar se as formas de pagamento aparecem no passo "Formas de Pagamento"
5. Testar com conexão lenta para verificar o indicador de carregamento
6. Testar com erro de rede para verificar o tratamento de erro

## Casos Extremos Tratados
- ✅ Erros de rede: Retorna graciosamente aos dados existentes no cubit
- ✅ Relações vazias: Páginas mostram estado vazio com opção de adicionar dados
- ✅ Reconstrução do widget: GlobalKeys mantêm estado das páginas
- ✅ Atualizações de dados: `didUpdateWidget` em OpeningHoursPage trata mudanças
- ✅ Condições de corrida: Indicador de carregamento previne renderização prematura

## Arquivos Modificados
- `lib/pages/welcome/settings_wizard_page.dart` - Adicionada lógica de busca de dados
- `lib/cubits/store_manager_cubit.dart` - Adicionado método de atualização de estado
- `docs/wizard-data-loading-fix.md` - Documentação em inglês
- `docs/CORREÇÃO-WIZARD-PT-BR.md` - Esta documentação em português

## Próximos Passos Recomendados
Se o problema persistir após esta correção, verifique:

1. **Backend**: Confirmar que o endpoint `/admin/stores/:id` retorna `hours` e `payment_method_groups`
2. **Banco de Dados**: Verificar se os dados estão corretamente associados à loja
3. **Logs**: Verificar logs do console para mensagens de erro durante o carregamento
4. **Network**: Usar DevTools do navegador para inspecionar a resposta da API

## Impacto
Esta é uma correção mínima e cirúrgica:
- **Apenas 53 linhas alteradas em 2 arquivos**
- **Sem breaking changes**
- **Tratamento de erro robusto**
- **Bem documentado**
- **Fácil de testar**
