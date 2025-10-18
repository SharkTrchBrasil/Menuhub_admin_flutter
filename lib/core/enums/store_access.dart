/// Enum que representa as funções/roles de acesso a uma loja.
/// ⚠️ IMPORTANTE: Deve estar sincronizado com o backend!
enum StoreAccessRole {
  /// Proprietário - Acesso total, não pode ser criado via API
  owner('owner', 'Proprietário', false),

  /// Gerente - Pode gerenciar quase tudo
  manager('manager', 'Gerente', true),

  /// Caixa - Focado em vendas e pagamentos
  cashier('cashier', 'Caixa', true),

  /// Garçom - Focado em pedidos de mesas
  waiter('waiter', 'Garçom', true),

  /// Gerente de Estoque - Controle de produtos e inventário
  stockManager('stock_manager', 'Gerente de Estoque', true);  // ✅ Adicionado

  const StoreAccessRole(this.name, this.title, this.selectable);

  /// Nome técnico (usado no backend)
  final String name;

  /// Nome amigável (usado na UI)
  final String title;

  /// Se esta role pode ser selecionada no formulário de criação
  final bool selectable;

  /// Converte o nome técnico em um enum
  static StoreAccessRole fromName(String name) {
    return StoreAccessRole.values.firstWhere(
          (role) => role.name == name,
      orElse: () => throw ArgumentError('Role "$name" não encontrada'),
    );
  }

  /// Lista apenas as roles que podem ser selecionadas
  static List<StoreAccessRole> get selectableRoles {
    return StoreAccessRole.values.where((r) => r.selectable).toList();
  }
}