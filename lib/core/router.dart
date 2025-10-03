import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/pages/cash/cash_page.dart';

import 'package:totem_pro_admin/pages/create_store/create_store_page.dart';

import 'package:totem_pro_admin/pages/more/more_page.dart';
import 'package:totem_pro_admin/pages/operation_configuration/operation_configuration_page.dart';

import 'package:totem_pro_admin/pages/products/products_page.dart';
import 'package:totem_pro_admin/pages/sign_in/sign_in_page.dart';
import 'package:totem_pro_admin/pages/sign_up/sign_up_page.dart';
import 'package:totem_pro_admin/pages/splash/splash_page.dart';


import '../cubits/auth_state.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/category.dart';
import '../models/coupon.dart';
import '../models/order_details.dart';

import '../models/products/product.dart';
import '../models/store/store.dart';


import '../models/store/store_hour.dart';
import '../models/variant.dart';
import '../pages/accesses/accesses_page.dart';

import '../pages/analytics/analytics_page.dart';
import '../pages/banners/banners_page.dart';

import '../pages/categories/create_category_page.dart';

import '../pages/chatbot/chatbot_page.dart';
import '../pages/chatbot/cubit/chatbot_cubit.dart';
import '../pages/coupons/coupons_page.dart';



import '../pages/dashboard/dashboard.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';

import '../pages/edit_settings/citys/delivery_locations_page.dart';
import '../pages/edit_settings/hours/hours_store_page.dart';
import '../pages/edit_settings/general/store_profile_page.dart';

import '../pages/edit_settings/payment_methods/payment_methods_page.dart';
import '../pages/hub/hub_page.dart';
import '../pages/perfomance/cubit/performance_cubit.dart';
import '../pages/perfomance/perfomance_page.dart';
import '../pages/plans/plans_page.dart';

import '../pages/integrations/integrations_page.dart';
import '../pages/inventory/inventory_page.dart';

import '../pages/not_found/error_505_Page.dart';

import '../pages/orders/cubit/order_page_cubit.dart';
import '../pages/orders/orders_page.dart';

import '../pages/orders/details/order_details_mobile.dart';
import '../pages/payables/payables_page.dart';
import '../pages/platform_payment_methods/gateway-payment.dart';
import '../pages/product-wizard/product_wizard_page.dart';
import '../pages/product_edit/edit_product_page.dart';
import '../pages/product_flavors/flavor_wizard_page.dart';
import '../pages/reports/reports_page.dart';

import '../pages/store_wizard/cubit/store_wizard_cubit.dart';
import '../pages/store_wizard/store_wizard_page.dart';
import '../pages/totems/totems_page.dart';

import '../pages/variants/edit_variants.dart';

import '../pages/variants/variant_edit_screen_wrapper.dart';
import '../pages/verify_code/verify_code_page.dart';
import '../pages/welcome/settings_wizard_page.dart';
import '../pages/welcome/welcome_page.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/chatbot_repository.dart';
import '../repositories/realtime_repository.dart';

import '../cubits/auth_cubit.dart';

import '../services/preference_service.dart';
import '../services/print/print_manager.dart';
import '../widgets/app_shell.dart';
import 'enums/category_type.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
GlobalKey<NavigatorState>();

class AppRouter {
  // ✅ 1. Obtenha as instâncias dos Cubits aqui para usar no redirect
  final AuthCubit authCubit;
  final StoresManagerCubit storesManagerCubit;


  AppRouter({required this.authCubit, required this.storesManagerCubit});

  late final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirectLimit: 10,
    observers: [BotToastNavigatorObserver()],


    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authCubit.stream),
      GoRouterRefreshStream(storesManagerCubit.stream),
    ]),

    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.uri.toString();
      final authState = authCubit.state;
      final storesState = storesManagerCubit.state;

      final splashRoute = '/splash';
      final authRoutes = ['/sign-in', '/sign-up', '/verify-email'];
      final isGoingToAuthRoute = authRoutes.any((r) => location.startsWith(r));
      final isGoingToVerifyEmail = location.startsWith('/verify-email');
      final isGoingToCreateStore = location.startsWith('/stores/new');

      final preferenceService = getIt<PreferenceService>();

      debugPrint('🔄 REDIRECT: location=$location, authState=$authState, storesState=$storesState');

      // ✅ CORREÇÃO 2: Trata o estado de erro de autenticação
      if (authState is AuthError) {
        // Se deu erro, manda para o login, a menos que já esteja lá.
        return isGoingToAuthRoute ? null : '/sign-in';
      }


      // ✅ PASSO 1: LÓGICA PARA USUÁRIO DESLOGADO (A CORREÇÃO)
      if (authState is AuthUnauthenticated) {
        // Se o usuário está deslogado, ele só pode acessar as rotas de autenticação.
        // Se ele tentar ir para qualquer outro lugar, será redirecionado para o login.
        return isGoingToAuthRoute ? null : '/sign-in';
      }

      // ✅ 1. Estado de verificação necessário
      if (authState is AuthNeedsVerification) {
        if (isGoingToVerifyEmail) return null;
        debugPrint('📧 Redirecting to verify email: ${authState.email}');
        return '/verify-email?email=${Uri.encodeComponent(authState.email)}';
      }

      // ✅ CORREÇÃO 1: Refina a lógica de carregamento
      if (authState is AuthInitial || authState is AuthLoading) {
        // SÓ redireciona para o splash se NÃO estivermos numa tela de autenticação.
        if (!isGoingToAuthRoute) {
          debugPrint('⏳ App initializing - redirecting to splash');
          return splashRoute;
        }
        // Se estivermos em /sign-in (ou /sign-up), não faz nada e deixa
        // a própria tela mostrar o indicador de loading no botão.
        debugPrint('⏳ User action in progress on auth route. No redirect.');
        return null;
      }







      if (authState is AuthAuthenticated) {
        debugPrint('✅ Authenticated - checking stores state: $storesState');

        if (storesState is StoresManagerInitial ||
            storesState is StoresManagerLoading) {
          debugPrint('🔄 Stores loading - redirecting to splash');
          return location == splashRoute ? null : splashRoute;
        }

        if (storesState is StoresManagerEmpty) {
          debugPrint('🏪 No stores - redirecting to create store');
          return isGoingToCreateStore ? null : '/stores/new';
        }

        if (storesState is StoresManagerLoaded) {
          debugPrint('📊 Stores loaded - checking final destination');

          final activeStore = storesState.activeStore;


          if (activeStore != null &&
              !activeStore.core.isSetupComplete &&
              !location.contains('/wizard') &&
              !isGoingToCreateStore) { // <-- NÃO redirecione se ainda estamos no fluxo de criação
            debugPrint('🛠️ Store not set up, redirecting to wizard.');
            return '/stores/${activeStore.core.id}/wizard';
          }


          // Lógica para sair da Splash Page (executa se o wizard não for necessário)
          if (location == splashRoute) {
            final shouldSkipHub = await preferenceService
                .getSkipHubPreference();
            final lastRoute = await preferenceService.getLastAccessedRoute();
            debugPrint(
                '🏠 Splash route - skipHub: $shouldSkipHub, lastRoute: $lastRoute');
            return (shouldSkipHub && lastRoute != null) ? lastRoute : '/hub';
          }
        }

      }

      // ✅ 5. Permite a navegação se nenhuma regra se aplicou
      debugPrint('✅ No redirect needed');
      return null;
    },

    errorPageBuilder:
        (context, state) =>
        MaterialPage(
          child: NotFoundPage(), // sua página 404
        ),

    routes: [


      GoRoute(
        path: '/splash',
        builder: (context, state) {
          // A rota agora apenas constrói a SplashPage.
          // A SplashPage, com seu BlocListener, cuidará do resto.
          return const SplashPage();
        },
      ),



      GoRoute(
        path: '/billing/:storeId',
        builder: (context, state) {
          final storeId = int.tryParse(state.pathParameters['storeId'] ?? '');
          if (storeId == null) {
            return const Scaffold(body: Center(child: Text('ID da Loja inválido')));
          }
          // Reutilizamos a MESMA página de planos, mas agora ela é acessível
          // publicamente através desta rota.
          return EditSubscriptionPage(storeId: storeId);
        },
      ),

      GoRoute(
        path: '/hub',
        builder: (context, state) => const HubPage(),
      ),


      GoRoute(
        path: '/stores/:storeId/wizard',
        builder: (context, state) {
          final storeId = int.parse(state.pathParameters['storeId']!);

          // ✅ AQUI ESTÁ A MÁGICA!
          // Usamos o BlocProvider para criar o StoreWizardCubit.
          // Ele estará disponível para a StoreSetupWizardPage e todos os seus descendentes.
          return BlocProvider<StoreWizardCubit>(
            create: (context) => StoreWizardCubit(
              storeId: storeId,
              // Pegamos a instância global do StoresManagerCubit que já existe
              storesManagerCubit: context.read<StoresManagerCubit>(),
            ),
            child: StoreSetupWizardPage(storeId: storeId),
          );
        },
      ),



      GoRoute(
        path: '/sign-in',

        builder: (_, state) {
          return SignInPage(
            redirectTo: state.uri.queryParameters['redirectTo'],
          );
        },
      ),
      GoRoute(
        path: '/sign-up',

        builder: (_, state) {
          return SignUpPage(
            redirectTo: state.uri.queryParameters['redirectTo'],
          );
        },
      ),
      GoRoute(
        path: '/stores/new',
        builder: (context, state) {
          return const StoreSetupPage();
        },
      ),

      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          // Tenta pegar o email dos parâmetros da URL
          final email = state.uri.queryParameters['email'];

          // Se não tem na URL, tenta pegar do AuthCubit
          if (email == null) {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthNeedsVerification) {
              return VerifyCodePage(email: authState.email);
            }
          }

          // Se ainda não tem, mostra erro
          if (email == null) {
            return const Scaffold(
              body: Center(
                child: Text('E-mail não encontrado. Volte para o login.'),
              ),
            );
          }

          return VerifyCodePage(email: email);
        },
      ),
      GoRoute(
        path: '/stores/:storeId',

        redirect: (context, state) {
          final storeId = state.pathParameters['storeId'];


          final isGoingToBaseStorePath = state.uri.path == '/stores/$storeId';

          // Se for a rota pai, redireciona para o dashboard como padrão.
          if (isGoingToBaseStorePath) {
            return '/stores/$storeId/dashboard';
          }

          // Para todas as outras sub-rotas (/products, /settings, etc.),
          // não faça nada e deixe a navegação continuar.
          return null;
        },

        routes: [
          // ✅ MOVA A ROTA PARA CÁ
          GoRoute(
            path: 'welcome',
            // O caminho completo será /stores/:storeId/welcome
            builder: (context, state) {
              final storeId = int.parse(state.pathParameters['storeId']!);
              return WelcomeSetupPage(storeId: storeId);
            },
          ),
          // ✅ ROTA DO WIZARD NO LUGAR CERTO
          GoRoute(
            path: 'wizard-settings',
            // Caminho relativo. O path completo será /stores/:storeId/wizard-settings
            builder: (context, state) {
              // Agora o storeId está disponível nos parâmetros da rota!
              final storeId = int.parse(state.pathParameters['storeId']!);
              return OnboardingWizardPage(storeId: storeId);
            },
          ),


          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final storeId = int.parse(state.pathParameters['storeId']!);
              return AppShell(
                navigationShell: navigationShell,
                storeId: storeId,
              );
            },
            branches: [
              // ✅ DASHBOARD (AGORA A ROTA PRINCIPAL)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'dashboard',
                    // <-- MUDANÇA 1: O caminho agora é /dashboard
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          child:
                          DashboardPage(), // <-- MUDANÇA 2: Aponta para a DashboardPage
                        ),
                  ),
                ],
              ),

              // GESTÃO
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'analytics',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          child:
                          AnalyticsPage(), // <-- MUDANÇA 2: Aponta para a DashboardPage
                        ),
                  ),
                ],
              ),
              // GESTÃO
              // CÓDIGO CORRIGIDO E MAIS SEGURO
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    // 1. O path agora é relativo ao AppShell, então /performance está correto.
                    path: 'performance',
                    pageBuilder: (context, state) {
                      // 2. Usar pageBuilder com NoTransitionPage para manter a consistência do seu AppShell.
                      return NoTransitionPage(
                        child: BlocProvider<PerformanceCubit>(
                          create: (context) {
                            final storeId = int.parse(
                              state.pathParameters['storeId']!,
                            );
                            return PerformanceCubit(
                              getIt<AnalyticsRepository>(),
                              // Pega o repositório via GetIt
                              storeId, // Passa o ID da loja ativa
                            );
                          },
                          child: const PerformancePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // VENDER
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'sell',
                    builder:
                        (_, __) =>
                    const Center(
                      child: Text(
                        'Vender',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ],
              ),

              // MESAS
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'tables',
                    builder:
                        (_, __) =>
                    const Center(
                      child: Text(
                        'Mesas',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ],
              ),



              // PRODUTOS
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'products',
                    name: 'products',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: CategoryProductPage(
                            storeId: state.storeId,
                          ),
                        ),

                  ),
                ],
              ),

              // CATEGORIAS
              // ...

              // StatefulShellBranch(
              //   routes: [
              //     GoRoute(
              //       path: '/categories',
              //       builder: (_, state) => CreateCategoryPage(
              //         storeId: int.parse(state.pathParameters['storeId']!),
              //         // category é nulo, ativando o modo de CRIAÇÃO.
              //       ),
              //       routes: [
              //         GoRoute(
              //           path: 'new',
              //           builder: (_, state) => CreateCategoryPage(
              //             storeId: int.parse(state.pathParameters['storeId']!),
              //             // category é nulo, ativando o modo de CRIAÇÃO.
              //           ),
              //         ),
              //         // Em core/router.dart
              //         GoRoute(
              //           path: ':id',
              //           builder: (_, state) {
              //             // ✅ INÍCIO DA SOLUÇÃO ROBUSTA
              //             Category? category; // A variável agora é nulável
              //
              //             if (state.extra is Category) {
              //               // Caso 1: O objeto já veio pronto.
              //               category = state.extra as Category;
              //             } else if (state.extra is Map<String, dynamic>) {
              //               // Caso 2: O objeto veio como um Map.
              //               category = Category.fromJson(state.extra as Map<String, dynamic>);
              //             }
              //             // Se state.extra for nulo, a variável 'category' permanecerá nula, o que está correto.
              //             // ✅ FIM DA SOLUÇÃO ROBUSTA
              //
              //             return CreateCategoryPage(
              //               storeId: int.parse(state.pathParameters['storeId']!),
              //               category: category, // Passa a categoria (ou nulo) corretamente
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ],
              // ),

              // ...
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'banners',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: BannersPage(storeId: state.storeId),
                        ),
                    routes: [
                      // GoRoute(
                      //   path: 'new',
                      //   builder:
                      //       (_, state) =>
                      //       EditCategoryPage(storeId: state.storeId),
                      // ),
                      // GoRoute(
                      //   path: ':id',
                      //   pageBuilder: (_, state) {
                      //     return NoTransitionPage(
                      //       key: UniqueKey(),
                      //       child: EditCategoryPage(
                      //         storeId: state.storeId,
                      //         id: state.id,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'payment-methods',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: PaymentMethodsPage(storeId: state.storeId),
                        ),
                    routes: [],
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'platform-payment-methods',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: PlatformPaymentMethodsPage(
                            storeId: state.storeId,
                          ),
                        ),
                    routes: [],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'coupons',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: CouponsPage(storeId: state.storeId),
                        ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (_, state) {
                          return EditCouponPage(storeId: state.storeId);
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        pageBuilder: (_, state) {
                          // ✅ CORREÇÃO AQUI
                          // Pega o cupom do parâmetro 'extra'
                          final coupon = state.extra as Coupon?;
                          return NoTransitionPage(
                            key: UniqueKey(),
                            child: EditCouponPage(
                              storeId: state.storeId,
                              id: state.id,
                              coupon: coupon, // Passa o cupom para a página
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'totems',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: TotemsPage(storeId: state.storeId),
                        ),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'cash',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: CashPage(storeId: state.storeId),
                        ),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'accesses',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: AccessesPage(storeId: state.storeId),
                        ),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [

                  GoRoute(
                    path: 'chatbot',
                    pageBuilder: (context, state) {
                      final storeId = state.pathParameters['storeId']!;
                      final storesCubit = context.read<StoresManagerCubit>();
                      final activeStore = (storesCubit.state as StoresManagerLoaded).activeStore;
                      final initialConfig = activeStore?.relations.chatbotConfig;
                      final initialMessages = activeStore?.relations.chatbotMessages ?? [];

                      return NoTransitionPage(
                        key: UniqueKey(),
                        child: BlocProvider<ChatbotCubit>(
                          create: (context) => ChatbotCubit(
                            storeId: int.parse(storeId),
                            chatbotRepository: getIt<ChatbotRepository>(),
                            realtimeRepository: getIt<RealtimeRepository>(),
                            storesManagerCubit: storesCubit,

                          )..initialize(initialConfig, initialMessages),

                          child: ChatbotPage(storeId: int.parse(storeId)),
                        ),
                      );
                    },
                  ),




                ],
              ),

              StatefulShellBranch(
                routes: [
                  // === BASE: SETTINGS ===
                  GoRoute(
                    path: 'settings',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: StoreProfilePage(storeId: state.storeId),
                        ),
                    routes: [
                      // === HORÁRIOS DE ATENDIMENTO ===
                      // Na sua configuração do GoRouter
                      GoRoute(
                        path: 'hours',
                        pageBuilder: (context, state) {
                          // ✅ 1. Usamos o 'context' que o pageBuilder nos dá.

                          // Pega o storeId dos parâmetros da rota de forma segura
                          final storeId =
                              int.tryParse(
                                state.pathParameters['storeId'] ?? '',
                              ) ??
                                  0;

                          // Se o ID for inválido, podemos mostrar uma página de erro
                          if (storeId == 0) {
                            return const NoTransitionPage(
                              child: Scaffold(
                                body: Center(
                                  child: Text("ID da loja inválido."),
                                ),
                              ),
                            );
                          }

                          // ✅ 2. Acessamos o StoresManagerCubit que está acima na árvore de widgets
                          final cubit = context.read<StoresManagerCubit>();
                          final cubitState = cubit.state;

                          // ✅ 3. Pegamos a lista de horários do estado do Cubit.
                          // Se o estado não estiver carregado ou não houver loja, passamos uma lista vazia.
                          List<StoreHour> initialHours = [];
                          if (cubitState is StoresManagerLoaded) {
                            initialHours =
                                cubitState.activeStore?.relations.hours ??
                                    [];
                          }

                          // ✅ 4. Finalmente, construímos a página passando a lista de horários.
                          return NoTransitionPage(
                            key: UniqueKey(),
                            child: OpeningHoursPage(
                              storeId: storeId,

                              // O `isInWizard: false` é o padrão, o que está correto para esta rota.
                            ),
                          );
                        },
                      ),

                      // === FORMAS DE ENTREGA ===
                      GoRoute(
                        path: 'shipping',
                        pageBuilder:
                            (_, state) =>
                            NoTransitionPage(
                              key: UniqueKey(),
                              child: OperationConfigurationPage(
                                storeId: state.storeId,
                              ),
                            ),
                      ),

                      // === LOCAIS DE ENTREGA ===
                      GoRoute(
                        path: 'locations',
                        pageBuilder:
                            (_, state) =>
                            NoTransitionPage(
                              key: UniqueKey(),
                              child: CityNeighborhoodPage(
                                storeId: state.storeId, isInWizard: false,
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  // === BASE: SETTINGS ===
                  GoRoute(
                    path: 'integrations',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: EditPaymentInfoSection(
                            storeId: state.storeId,
                          ),
                        ),
                    routes: [
                      // === HORÁRIOS DE ATENDIMENTO ===
                      // GoRoute(
                      //   path: 'efi',
                      //   pageBuilder: (_, state) => NoTransitionPage(
                      //     key: UniqueKey(),
                      //     child: EditStoreHoursPage(storeId: state.storeId),
                      //   ),
                      // ),
                      //
                      //
                    ],
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'more',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: MorePage(storeId: state.storeId),
                        ),
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'reports',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: ReportsPage(storeId: state.storeId),
                        ),
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'inventory',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: InventoryPage(storeId: state.storeId),
                        ),
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),



              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'payables',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: PayablePage(storeId: state.storeId),
                        ),
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),

              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'plans',
                    pageBuilder:
                        (_, state) =>
                        NoTransitionPage(
                          key: UniqueKey(),
                          child: EditSubscriptionPage(
                            storeId:
                            int.tryParse(
                              state.pathParameters['storeId']!,
                            )!,
                          ),
                        ),
                    // redirect:
                    //     (_, state) =>
                    //         RouteGuard.apply(state, [StoreOwnerGuard()]),
                  ),
                ],
              ),
            ],

            // MESAS
          ),


          GoRoute(
            path: 'products/create',
            name: 'product-create-wizard',
            pageBuilder: (context, state) {
              // ✅ INÍCIO DA CORREÇÃO ROBUSTA
              late final Category
              category; // Usamos 'late final' para garantir que será inicializada

              if (state.extra is Category) {
                // CASO 1: O objeto já é uma instância de Category (navegação interna).
                // Simplesmente o usamos diretamente.
                category = state.extra as Category;
              } else if (state.extra is Map<String, dynamic>) {
                // CASO 2: O objeto veio como um Map (ex: vindo de um deep link).
                // Usamos o .fromJson para construí-lo.
                category = Category.fromJson(
                  state.extra as Map<String, dynamic>,
                );
              } else {
                // CASO 3: Nenhum dado foi passado ou o tipo é inesperado.
                // Lançamos uma exceção para deixar claro que a categoria é obrigatória aqui.
                throw Exception(
                  'A rota /products/create requer um objeto Category ou Map<String, dynamic> no parâmetro extra.',
                );
              }
              // ✅ FIM DA CORREÇÃO ROBUSTA

              // O resto da sua lógica para escolher a página continua igual e agora segura.
              Widget pageToBuild;
              if (category.type == CategoryType.CUSTOMIZABLE) {
                pageToBuild = FlavorWizardPage(
                  storeId: state.storeId,
                  category: category,
                );
              } else {
                pageToBuild = ProductWizardPage(
                  storeId: state.storeId,
                  category: category,
                );
              }

              return NoTransitionPage(child: pageToBuild);
            },
          ),

          // No seu arquivo de rotas
          GoRoute(
            path: 'products/:productId',
            name: 'product-edit',
            builder: (context, state) {
              // Tenta pegar o produto do 'extra' para uma carga rápida
              var product = state.extra as Product?;
              final storeId = int.parse(state.pathParameters['storeId']!);
              final productId = int.parse(
                state.pathParameters['productId']!,
              );

              product ??= context.read<StoresManagerCubit>().getProductById(
                productId,
              );

              if (product == null) {
                return const Scaffold(
                  body: Center(child: Text("Produto não encontrado!")),
                );
              }

              // Se o produto existe, constrói a página normalmente.
              return EditProductPage(storeId: storeId, product: product);
            },
          ),


          GoRoute(
            path: 'variants/:variantId',
            name: 'variant-edit',
            pageBuilder: (context, state) {
              // A lógica para pegar os dados continua a mesma
              final storeId = int.parse(state.pathParameters['storeId']!);
              final variantId = int.parse(state.pathParameters['variantId']!);
              final storesManagerCubit = context.read<StoresManagerCubit>();

              var variant = state.extra as Variant?;
              variant ??= storesManagerCubit.getVariantById(variantId);

              if (variant == null) {
                return NoTransitionPage(
                  child: Scaffold(
                    appBar: AppBar(title: const Text("Erro")),
                    body: Center(
                      child: Text("Grupo de complemento com ID $variantId não encontrado!"),
                    ),
                  ),
                );
              }

              // ✅ A CORREÇÃO É AQUI:
              // Em vez de chamar a tela diretamente, chamamos o Wrapper.
              // O Wrapper vai criar o BlocProvider e o VariantEditCubit para a tela.
              return NoTransitionPage(
                key: ValueKey('variant-${variant.id}'),
                child: VariantEditScreenWrapper(
                  storeId: storeId,
                  variant: variant,
                ),
              );
            },
          ),

          GoRoute(
            path: 'products/:productId/edit-flavor',
            name: 'flavor-edit',
            pageBuilder: (context, state) {
              // --- Carregamento dos Dados ---
              final storeId = int.parse(state.pathParameters['storeId']!);
              final productId = int.parse(
                state.pathParameters['productId']!,
              );
              final storesManagerCubit = context.read<StoresManagerCubit>();

              // Plano A: Tenta pegar o produto do 'extra' para uma carga rápida
              var partialProduct = state.extra as Product?;

              // Plano B: Se o 'extra' for nulo (devido a um refresh, etc.),
              // busca o produto na nossa fonte da verdade: o StoresManagerCubit!
              partialProduct ??= storesManagerCubit.getProductById(
                productId,
              );


              // 1. Se, mesmo após o Plano B, o produto não for encontrado, mostra erro.
              if (partialProduct == null) {
                return NoTransitionPage(
                  child: Scaffold(
                    appBar: AppBar(title: Text("Erro")),
                    body: Center(
                      child: Text(
                        "Sabor com ID $productId não encontrado!",
                      ),
                    ),
                  ),
                );
              }

              // 2. Com o produto em mãos, busca a Categoria Pai COMPLETA.
              Category? fullParentCategory;
              if (partialProduct.categoryLinks.isNotEmpty) {
                final categoryId =
                    partialProduct.categoryLinks.first.categoryId;
                fullParentCategory = storesManagerCubit.getCategoryById(
                  categoryId,
                );
              }

              // 3. Se a categoria pai não for encontrada, mostra erro.
              if (fullParentCategory == null) {
                return NoTransitionPage(
                  child: Scaffold(
                    appBar: AppBar(title: Text("Erro")),
                    body: Center(
                      child: Text(
                        "Categoria pai do sabor não foi encontrada!",
                      ),
                    ),
                  ),
                );
              }

              // 4. Monta o objeto final para a tela de edição, garantindo que a
              //    categoria aninhada dentro do produto seja a versão completa.
              final productForEdition = partialProduct.copyWith(
                categoryLinks: [
                  partialProduct.categoryLinks.first.copyWith(
                    category: fullParentCategory,
                  ),
                ],
              );

              // --- Construção da Página ---
              // Se tudo deu certo, constrói a página com os dados completos e corretos.
              return NoTransitionPage(
                child: FlavorWizardPage(
                  storeId: storeId,
                  product: productForEdition,
                  category: fullParentCategory,
                ),
              );
            },
          ),

          GoRoute(
            path: 'categories/new', // CRIAÇÃO DE CATEGORIA
            name: 'category-new',
            builder:
                (_, state) =>
                CreateCategoryPage(
                  storeId: int.parse(state.pathParameters['storeId']!),
                ),
          ),
          GoRoute(
            path: 'categories/:categoryId',
            name: 'category-edit',
            builder: (context, state) {
              // --- Início da Lógica Robusta ---

              // Passo 1: Obter IDs e o Cubit (continua igual)
              final categoryId = int.parse(state.pathParameters['categoryId']!);
              final storesManagerCubit = context.read<StoresManagerCubit>();

              // Passo 2: Tentar carregar a categoria do 'extra' de forma SEGURA
              Category? category; // Começa como nulo

              if (state.extra is Category) {
                // Caso 1: Veio como o objeto correto. Ótimo!
                category = state.extra as Category;
              } else if (state.extra is Map<String, dynamic>) {
                // Caso 2: O tipo se perdeu e veio como um Map. Reconstruímos a partir do JSON.
                category =
                    Category.fromJson(state.extra as Map<String, dynamic>);
              }

              // Passo 3: Plano B - se o 'extra' falhou ou era nulo, buscar no Cubit (continua igual)
              category ??= storesManagerCubit.getCategoryById(categoryId);

              // Passo 4: Validação Final (continua igual)
              if (category == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text("Erro")),
                  body: Center(child: Text(
                      "Categoria com ID $categoryId não encontrada!")),
                );
              }

              // Passo 5: Construir a página com os dados garantidos (continua igual)
              return CreateCategoryPage(
                storeId: int.parse(state.pathParameters['storeId']!),
                category: category,
              );
            },
          ),


          GoRoute(
                path: 'orders',
                pageBuilder:
                    (_, state) =>
                    NoTransitionPage(
                      child: BlocBuilder<
                          StoresManagerCubit,
                          StoresManagerState
                      >(
                        builder: (context, storesState) {
                          if (storesState is StoresManagerLoaded) {
                            return BlocProvider<OrderCubit>(
                              create:
                                  (context) =>
                                  OrderCubit(
                                    realtimeRepository:
                                    getIt<RealtimeRepository>(),
                                    storesManagerCubit:
                                    context
                                        .read<StoresManagerCubit>(),
                                    printManager: getIt<PrintManager>(),
                                  ),
                              child: OrdersPage(),
                            );
                          }

                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                routes: [
                  GoRoute(
                    path: ':id',
                    // Supondo que a rota pai seja '/stores/:storeId'
                    name: 'order-details',
                    builder: (context, state) {
                      // 1. Tenta pegar o 'extra' como um mapa.
                      final extra =
                      state.extra as Map<String, dynamic>?;

                      // 2. Extrai os objetos do mapa.
                      final OrderDetails? order = extra?['order'];
                      final Store? store = extra?['store'];

                      // 3. Verifica se os dados foram recebidos.
                      if (order != null && store != null) {
                        // 4. Constrói a página com os dados completos.
                        return OrderDetailsPageMobile(
                          order: order,
                          store: store,
                        );
                      }

                      // Fallback: Se a página for acessada sem os dados (ex: link direto),
                      // mostra uma tela de erro ou de carregamento.
                      return const Scaffold(
                        body: Center(
                          child: Text(
                            "Erro: Não foi possível carregar os dados do pedido.",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),





        ],
      ),


    ],
  );
}

// Auxiliar para streams em GoRouter
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
