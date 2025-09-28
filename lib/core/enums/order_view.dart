
// lib/core/enums/order_view.dart

// Os dois layouts principais que o usuário pode alternar
enum OrderViewMode {
  list, // Layout com BottomNavigationBar e filtros
  grouped, // Layout com ExpansionTile agrupado por status
}

// Os filtros da BottomNavigationBar
enum ListFilter {
  all,
  deliveries,
  scheduled,
  completed,
  issues, // Placeholder para Ocorrências
}

// ✅ NOVO: Enum para os sub-filtros da tela de agendados
enum ScheduledFilter {
  today,
  tomorrow,
  nextDays,
}