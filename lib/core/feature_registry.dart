// lib/core/feature_registry.dart

/// Um mapa global e constante que associa a chave de uma feature
/// ao seu nome amigável para exibição na interface.
const Map<String, String> featureRegistry = {
  // --- Features Gerais e de Planos ---
  'basic_reports': 'Relatórios Básicos',
  'coupons': 'Módulo de Promoções',
  'inventory_control': 'Controle de Estoque',
  'financial_payables': 'Financeiro: Contas a Pagar',
  'pdv': 'Ponto de Venda (PDV)',
  'totem': 'Módulo de Totem',
  'multi_device_access': 'Acesso em Múltiplos Dispositivos',
  'auto_accept_orders': 'Aceite Automático de Pedidos',

  // --- Features Premium e Add-ons ---
  'advanced_reports': 'Relatórios Avançados',
  'auto_printing': 'Impressão Automática',
  'style_guide': 'Design Personalizável',
  'custom_banners': 'Banners Promocionais',
  'custom_domain': 'Domínio Personalizado',
  'loyalty_module': 'Módulo Fidelidade', // Chave antiga, pode ser mantida por compatibilidade ou removida
  'whatsapp_bot_ia': 'Módulo Bot (WhatsApp IA)',
  'table_management_module': 'Módulo Mesas e Comandas',
  'extra_store_location': 'Loja Extra (Catálogo Adicional)',
  'fiscal_module': 'Módulo Fiscal (NFC-e)',
  'extra_ifood_integration': 'Integração Extra do iFood',
  'kds_module': 'Tela da Cozinha (KDS)',
  'delivery_personnel_management': 'Módulo de Entregadores',

  // --- NOVAS FEATURES DE MARKETING E OPERAÇÃO ---
  'loyalty_program': 'Programa de Fidelidade',
  'abandoned_cart_recovery': 'Recuperação de Carrinho',
  'marketing_automation': 'Automação de Marketing',
  'delivery_tracking': 'Rastreio de Entregador',
  'ingredient_stock_control': 'Estoque por Ingredientes',
  'advanced_analytics': 'Análises Avançadas',
  'white_labeling': 'Remoção de Marca (White-label)',
};
