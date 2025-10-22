import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/chat_pop/chat_popup_manager.dart';

// Cubits
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_state.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'package:totem_pro_admin/pages/create_store/create_store_page.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/orders_page.dart';

import 'package:totem_pro_admin/pages/table/cubits/tables_cubit.dart';
import 'package:totem_pro_admin/pages/chatbot/cubit/chatbot_cubit.dart';
import 'package:totem_pro_admin/pages/perfomance/cubit/performance_cubit.dart';
import 'package:totem_pro_admin/pages/store_wizard/cubit/store_wizard_cubit.dart';

// Repositories
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/analytics_repository.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';

// Models
import 'package:totem_pro_admin/models/coupon.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/variant.dart';

// Pages
import 'package:totem_pro_admin/pages/splash/splash_page.dart';
import 'package:totem_pro_admin/pages/sign_in/sign_in_page.dart';
import 'package:totem_pro_admin/pages/sign_up/sign_up_page.dart';
import 'package:totem_pro_admin/pages/verify_code/verify_code_page.dart';
import 'package:totem_pro_admin/pages/hub/hub_page.dart';
import 'package:totem_pro_admin/pages/clone_store_wizard/new_store_wizard.dart';
import 'package:totem_pro_admin/pages/clone_store_wizard/new_store_wizard_page.dart';

import 'package:totem_pro_admin/pages/store_wizard/store_wizard_page.dart';
import 'package:totem_pro_admin/pages/not_found/error_505_Page.dart';
import 'package:totem_pro_admin/pages/plans/plans_page.dart';
import 'package:totem_pro_admin/pages/dashboard/dashboard.dart';
import 'package:totem_pro_admin/pages/analytics/analytics_page.dart';
import 'package:totem_pro_admin/pages/perfomance/perfomance_page.dart';

import 'package:totem_pro_admin/pages/orders/details/order_details_mobile.dart';
import 'package:totem_pro_admin/pages/products/products_page.dart';

import 'package:totem_pro_admin/pages/edit_settings/payment_methods/payment_methods_page.dart';
import 'package:totem_pro_admin/pages/platform_payment_methods/gateway-payment.dart';
import 'package:totem_pro_admin/pages/coupons/coupons_page.dart';
import 'package:totem_pro_admin/pages/edit_coupon/edit_coupon_page.dart';

import 'package:totem_pro_admin/pages/cash/cash_page.dart';
import 'package:totem_pro_admin/pages/accesses/accesses_page.dart';
import 'package:totem_pro_admin/pages/chatbot/chatbot_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/store_profile_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/hours_store_page.dart';
import 'package:totem_pro_admin/pages/operation_configuration/operation_configuration_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/delivery_locations_page.dart';

import 'package:totem_pro_admin/pages/more/more_page.dart';
import 'package:totem_pro_admin/pages/reports/reports_page.dart';
import 'package:totem_pro_admin/pages/inventory/inventory_page.dart';

import 'package:totem_pro_admin/pages/variants/variant_edit_screen_wrapper.dart';

// Widgets & Services
import 'package:totem_pro_admin/widgets/app_shell.dart';
import '../pages/create_store/cubit/store_setup_cubit.dart';
import '../pages/edit_settings/hours/cubit/opening_hours_cubit.dart';
import '../pages/operation_configuration/cubit/operation_config_cubit.dart';
import '../pages/plans/manage_subscription_page.dart';
import '../pages/plans/reactivate_subscription_page.dart';

import '../pages/plans/subscription_manager_page.dart';
import '../pages/products/cubit/products_cubit.dart';

import '../pages/sessions/session_manager_screen.dart';
import '../repositories/segment_repository.dart';
import '../repositories/store_repository.dart';
import '../repositories/user_repository.dart';
import '../widgets/store_switcher_panel.dart';
import 'enums/store_access.dart';
import 'enums/wizard_type.dart';
import 'guards/route_guards.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  late final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirectLimit: 10,
    observers: [BotToastNavigatorObserver()],
    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    // ✅ REDIRECT GLOBAL - Sem applyGuards aqui
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.uri.toString();
      final authState = getIt<AuthCubit>().state;

      // --- NÍVEL 0: ESTADO INICIAL / CARREGAMENTO ---
      if (authState is AuthInitial || authState is AuthLoading) {
        return location == '/splash' ? null : '/splash';
      }

      // --- NÍVEL 1: ESTADO DE AUTENTICAÇÃO ---
      final isLoggedIn = authState is AuthAuthenticated;
      final isAtAuthScreen = [
        '/sign-in',
        '/sign-up',
        '/verify-email',
      ].any((route) => location.startsWith(route));

      if (!isLoggedIn) {
        if (authState is AuthUnauthenticated &&
            authState.reason == 'session_expired') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            BotToast.showText(
              text: 'Sua sessão expirou após 7 dias de inatividade. Faça login novamente.',
              duration: const Duration(seconds: 5),
              contentColor: Colors.orange,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14),
            );
          });
        }
        return isAtAuthScreen ? null : '/sign-in';
      }

      if (authState is AuthNeedsVerification) {
        return location.startsWith('/verify-email') ? null : '/verify-email';
      }

      // --- NÍVEL 2: ESTADO DOS DADOS DO USUÁRIO (LOJAS) ---
      if (!getIt.isRegistered<StoresManagerCubit>()) {
        return '/splash';
      }

      final storesState = getIt<StoresManagerCubit>().state;

      if (storesState is StoresManagerInitial ||
          storesState is StoresManagerLoading ||
          storesState is StoresManagerSynchronizing) {
        return location == '/splash' ? null : '/splash';
      }

      if (storesState is StoresManagerEmpty) {
        final allowedRoutes = ['/stores/new', '/hub'];
        final isGoingToAllowedRoute = allowedRoutes.any(
              (route) => location.startsWith(route),
        );
        return isGoingToAllowedRoute ? null : '/stores/new/wizard';
      }

// --- NÍVEL 3: ESTADO DA APLICAÇÃO (LOJA ATIVA E CONFIGURAÇÃO) ---
      if (storesState is StoresManagerLoaded) {
        final activeStore = storesState.activeStore;
        final allStores = storesState.stores.values.toList();

        final isComingFromAuthFlow =
            location == '/splash' || location == '/sign-in';

        if (isComingFromAuthFlow) {
          // Após autenticação
          if (allStores.length == 1) {
            // 1 loja: vai direto pro hub
            final singleStore = allStores.first.store;
            getIt<StoresManagerCubit>().changeActiveStore(singleStore.core.id!);
            return '/hub';
          } else if (allStores.length > 1) {
            // 2+ lojas: vai pro select-store
            return '/select-store';
          }
        }

        // Se já tem uma loja ativa, mantém o fluxo
        if (activeStore == null) {
          final allowedRoutes = ['/select-store', '/hub'];
          return allowedRoutes.any((route) => location.startsWith(route))
              ? null
              : '/select-store';
        }

        if (!activeStore.core.isSetupComplete) {
          final wizardRoute = '/stores/${activeStore.core.id}/wizard';
          return location == wizardRoute ? null : wizardRoute;
        }
      }


      return null;
    },

    errorPageBuilder: (context, state) => const MaterialPage(child: NotFoundPage()),

    routes: [
      // ═══════════════════════════════════════════════════════════
      // ROTAS DE AUTENTICAÇÃO (sem guards)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, state) => SignInPage(
          redirectTo: state.uri.queryParameters['redirectTo'],
        ),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (_, state) => SignUpPage(
          redirectTo: state.uri.queryParameters['redirectTo'],
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ??
              (context.read<AuthCubit>().state as AuthNeedsVerification?)?.email;
          if (email == null) {
            return const Scaffold(
              body: Center(child: Text('E-mail não encontrado.')),
            );
          }
          return VerifyCodePage(email: email);
        },
      ),



      GoRoute(
        path: '/orders',
        pageBuilder: (_, state) =>
        const NoTransitionPage(child: OrdersPage()),
        routes: [
          GoRoute(
            path: ':id',
            name: 'order-details',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final order = extra?['order'] as OrderDetails?;
              final store = extra?['store'] as Store?;
              if (order != null && store != null) {
                return OrderDetailsPageMobile(
                  order: order,
                  store: store,
                );
              }
              return const Scaffold(
                body: Center(
                  child: Text(
                    "Erro: Dados do pedido não encontrados.",
                  ),
                ),
              );
            },
          ),
        ],
      ),


      // ═══════════════════════════════════════════════════════════
      // SHELL PRINCIPAL
      // ═══════════════════════════════════════════════════════════
      ShellRoute(
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<StoresManagerCubit>()),
              BlocProvider(
                create: (context) =>
                getIt<OrderCubit>()..init(context.read<StoresManagerCubit>()),
                lazy: true,
              ),
              BlocProvider(
                create: (context) => TablesCubit(
                  realtimeRepository: getIt<RealtimeRepository>(),
                ),
                lazy: true,
              ),
            ],
            child: ChatPopupManager(child: child),
          );
        },
        routes: [
          // ─────────────────────────────────────────────────────
          // SELECT STORE (sem redirect, rota simples)
          // ─────────────────────────────────────────────────────
          GoRoute(
            path: '/select-store',
            pageBuilder: (context, state) {
              return const MaterialPage(child: StoreSwitcherPanelWrapper());
            },
          ),

          GoRoute(
            path: '/hub',
            builder: (context, state) => const HubPage(),
          ),

          // ─────────────────────────────────────────────────────
          // CRIAR NOVA LOJA (sem redirect, rota simples)
          // ─────────────────────────────────────────────────────

          GoRoute(
            path: '/stores/new',
            builder: (context, state) => const NewStoreOptionsPage(),
            routes: [
              GoRoute(
                path: 'clone',
                builder: (context, state) =>
                    NewStoreWizardPage(mode: WizardMode.clone),
              ),

              // ✅ CORRIGIR ESTA ROTA
              GoRoute(
                path: 'wizard',
                builder: (context, state) {
                  // ✅ ADICIONAR O CUBIT AQUI
                  return BlocProvider<CreateStoreCubit>(
                    create: (context) => CreateStoreCubit(
                      getIt<StoreRepository>(),
                      getIt<SegmentRepository>(),
                      getIt<UserRepository>(),
                      getIt<AuthCubit>(),
                      getIt<StoresManagerCubit>(),
                      initialResponsibleName: (context.read<AuthCubit>().state
                      as AuthAuthenticated?)?.data.user.name,
                    ),
                    child: const StoreSetupPage(),
                  );
                },
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════
          // ROTAS POR LOJA
          // ═══════════════════════════════════════════════════════════
          GoRoute(
            path: '/stores/:storeId',
            redirect: (context, state) {
              final storeId = state.pathParameters['storeId'];
              if (state.uri.path == '/stores/$storeId') {
                return '/stores/$storeId/dashboard';
              }
              return null;
            },
            routes: [
              // ─────────────────────────────────────────────────────
              // WIZARD (sem guard)
              // ─────────────────────────────────────────────────────
              GoRoute(
                path: 'wizard',
                builder: (context, state) {
                  final storeId = int.parse(state.pathParameters['storeId']!);
                  return BlocProvider<StoreWizardCubit>(
                    create: (context) => StoreWizardCubit(
                      storeId: storeId,
                      storesManagerCubit: context.read<StoresManagerCubit>(),
                      openingHoursCubit: context.read<OpeningHoursCubit>(),
                    ),
                    child: StoreSetupWizardPage(storeId: storeId),
                  );
                },
              ),

              // ─────────────────────────────────────────────────────
              // SUBSCRIPTION (sem redirect, rota simples)
              // ─────────────────────────────────────────────────────
              GoRoute(
                path: 'subscription',
                redirect: (context, state) {
                  final storeId = state.pathParameters['storeId'];
                  return '/stores/$storeId/subscription/plans';
                },
                routes: [
                  GoRoute(
                    path: 'manage',
                    pageBuilder: (context, state) {
                      final storeId = int.parse(
                        state.pathParameters['storeId']!,
                      );
                      return NoTransitionPage(
                        child: ManageSubscriptionPage(storeId: storeId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'plans',
                    pageBuilder: (context, state) {
                      final storeId = int.parse(
                        state.pathParameters['storeId']!,
                      );
                      return NoTransitionPage(
                        child: EditSubscriptionPage(storeId: storeId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'reactivate',
                    pageBuilder: (context, state) {
                      final storeId = int.parse(
                        state.pathParameters['storeId']!,
                      );
                      return NoTransitionPage(
                        child: ReactivateSubscriptionPage(storeId: storeId),
                      );
                    },
                  ),
                ],
              ),

              // ═══════════════════════════════════════════════════════════
              // APP SHELL (NAVEGAÇÃO PRINCIPAL)
              // ═══════════════════════════════════════════════════════════
              StatefulShellRoute.indexedStack(
                builder: (context, state, navigationShell) {
                  final storeId = int.parse(state.pathParameters['storeId']!);
                  return AppShell(
                    navigationShell: navigationShell,
                    storeId: storeId,
                  );
                },
                branches: [
                  // Dashboard
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'dashboard',
                        pageBuilder: (_, state) =>
                        const NoTransitionPage(child: DashboardPage()),
                      ),
                    ],
                  ),

                  // Analytics
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'analytics',
                        pageBuilder: (_, state) =>
                        const NoTransitionPage(child: AnalyticsPage()),
                      ),
                    ],
                  ),

                  // Performance
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'performance',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: BlocProvider<PerformanceCubit>(
                            create: (context) => PerformanceCubit(
                              getIt<AnalyticsRepository>(),
                              int.parse(state.pathParameters['storeId']!),
                            ),
                            child: const PerformancePage(),
                          ),
                        ),
                      ),
                    ],
                  ),


                  // Products
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'products',
                        name: 'products',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: BlocProvider<ProductsCubit>(
                            create: (context) => getIt<ProductsCubit>(),
                            child: CategoryProductPage(
                              storeId: state.storeId,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Payment Methods
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'payment-methods',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: PaymentMethodsPage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Platform Payment Methods
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'platform-payment-methods',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: PlatformPaymentMethodsPage(
                            storeId: state.storeId,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Coupons
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'coupons',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: CouponsPage(storeId: state.storeId),
                        ),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (_, state) =>
                                EditCouponPage(storeId: state.storeId),
                          ),
                          GoRoute(
                            path: ':id',
                            builder: (_, state) => EditCouponPage(
                              storeId: state.storeId,
                              id: state.id,
                              coupon: state.extra as Coupon?,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Cash
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'cash',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: CashPage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Accesses
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'accesses',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: AccessesPage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Sessions
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'sessions',
                        pageBuilder: (_, state) => const NoTransitionPage(
                          child: SessionManagerPage(),
                        ),
                      ),
                    ],
                  ),

                  // Chatbot
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'chatbot',
                        pageBuilder: (context, state) {
                          final storeId =
                          int.parse(state.pathParameters['storeId']!);
                          final storesCubit =
                          context.read<StoresManagerCubit>();
                          final activeStore =
                              (storesCubit.state as StoresManagerLoaded)
                                  .activeStore;
                          return NoTransitionPage(
                            child: BlocProvider<ChatbotCubit>(
                              create: (context) => ChatbotCubit(
                                storeId: storeId,
                                chatbotRepository:
                                getIt<ChatbotRepository>(),
                                realtimeRepository:
                                getIt<RealtimeRepository>(),
                                storesManagerCubit: storesCubit,
                              )..initialize(
                                activeStore?.relations.chatbotConfig,
                                activeStore?.relations.chatbotMessages ?? [],
                              ),
                              child: ChatbotPage(
                                storeId: storeId,
                                phoneStore: activeStore?.core.phone ?? "",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Settings
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'settings',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: StoreProfilePage(storeId: state.storeId),
                        ),
                        routes: [
                          GoRoute(
                            path: 'hours',
                            builder: (context, state) {
                              return BlocProvider<OpeningHoursCubit>(
                                create: (context) =>
                                    getIt<OpeningHoursCubit>(),
                                child:
                                OpeningHoursPage(storeId: state.storeId),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'shipping',
                            builder: (context, state) {
                              return BlocProvider<OperationConfigCubit>(
                                create: (context) =>
                                    getIt<OperationConfigCubit>(),
                                child: OperationConfigurationPage(
                                  storeId: state.storeId,
                                ),
                              );
                            },
                          ),
                          GoRoute(
                            path: 'locations',
                            builder: (_, state) => CityNeighborhoodPage(
                              storeId: state.storeId,
                              isInWizard: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // More
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'more',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: MorePage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Reports
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'reports',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: ReportsPage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Inventory
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'inventory',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: InventoryPage(storeId: state.storeId),
                        ),
                      ),
                    ],
                  ),

                  // Manager
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'manager',
                        pageBuilder: (_, state) => NoTransitionPage(
                          child: SubscriptionManagerPage(
                            storeId: state.storeId,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );


}

// ═══════════════════════════════════════════════════════════
// REFRESH LISTENER PARA O ROUTER
// ═══════════════════════════════════════════════════════════
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
