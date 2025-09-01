import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/pages/cash/cash_page.dart';
import 'package:totem_pro_admin/pages/categories/categories_page.dart';
import 'package:totem_pro_admin/pages/create_store/create_store_page.dart';
import 'package:totem_pro_admin/pages/edit_category/edit_category_page.dart';




import 'package:totem_pro_admin/pages/more/more_page.dart';
import 'package:totem_pro_admin/pages/operation_configuration/operation_configuration_page.dart';

import 'package:totem_pro_admin/pages/products/products_page.dart';
import 'package:totem_pro_admin/pages/sign_in/sign_in_page.dart';
import 'package:totem_pro_admin/pages/sign_up/sign_up_page.dart';
import 'package:totem_pro_admin/pages/splash/splash_page.dart';

import '../cubits/active_store_cubit.dart';
import '../cubits/auth_state.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/category.dart';
import '../models/coupon.dart';
import '../models/order_details.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../models/store_hour.dart';
import '../models/store_with_role.dart';
import '../models/variant.dart';
import '../pages/accesses/accesses_page.dart';

import '../pages/analytics/analytics_page.dart';
import '../pages/banners/banners_page.dart';

import '../pages/categories/create_category_page.dart';
import '../pages/chatbot/qrcode.dart';
import '../pages/coupons/coupons_page.dart';

import '../pages/create_store/cubit/store_setup_cubit.dart';
import '../pages/customers/customers_page.dart';

import '../pages/dashboard/dashboard.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';

import '../pages/edit_settings/citys/delivery_locations_page.dart';
import '../pages/edit_settings/hours/hours_store_page.dart';
import '../pages/edit_settings/general/store_profile_page.dart';

import '../pages/edit_settings/payment_methods/payment_methods_page.dart';
import '../pages/perfomance/cubit/performance_cubit.dart';
import '../pages/perfomance/perfomance_page.dart';
import '../pages/plans/plans_page.dart';

import '../pages/integrations/integrations_page.dart';
import '../pages/inventory/inventory_page.dart';

import '../pages/not_found/error_505_Page.dart';

import '../pages/orders/order_page_cubit.dart';
import '../pages/orders/orders_page.dart';


import '../pages/orders/widgets/order_details_mobile.dart';
import '../pages/payables/payables_page.dart';
import '../pages/platform_payment_methods/gateway-payment.dart';
import '../pages/product-wizard/product_wizard_page.dart';
import '../pages/product_edit/edit_product_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/splash/splash_page_cubit.dart';
import '../pages/totems/totems_page.dart';

import '../pages/variants/edit_variants.dart';
import '../pages/variants/temp.dart';
import '../pages/verify_code/verify_code_page.dart';
import '../pages/welcome/settings_wizard_page.dart';
import '../pages/welcome/welcome_page.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/realtime_repository.dart';
import '../repositories/segment_repository.dart';
import '../repositories/store_repository.dart';

import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../cubits/auth_cubit.dart';

import '../services/print/print_manager.dart';
import '../widgets/app_shell.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {

  // ✅ 1. Obtenha as instâncias dos Cubits aqui para usar no redirect
  final AuthCubit authCubit;
  final StoresManagerCubit storesManagerCubit;



  AppRouter({
    required this.authCubit,
    required this.storesManagerCubit,
  });

  late final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirectLimit: 10,
    observers: [BotToastNavigatorObserver()],


      // ✅ 2. O refreshListenable continua perfeito
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(authCubit.stream),
        GoRouterRefreshStream(storesManagerCubit.stream),
      ]),


      redirect: (BuildContext context, GoRouterState state) {
        final location = state.uri.toString();
        final authState = authCubit.state;
        final storesState = storesManagerCubit.state;

        final splashRoute = '/splash';
        final authRoutes = ['/sign-in', '/sign-up', '/verify-email'];
        final isGoingToAuthRoute = authRoutes.any((r) => location.startsWith(r));

        // --- Regra 1: Autenticação pendente ---
        // Se ainda não sabemos se o usuário está logado, ele DEVE ficar na splash.
        if (authState is AuthInitial || authState is AuthLoading) {
          return location == splashRoute ? null : splashRoute;
        }

        // --- Regra 2: Deslogado ---
        // Se sabemos que ele está deslogado, ele só pode ir para as rotas de auth.
        if (authState is AuthUnauthenticated) {
          return isGoingToAuthRoute ? null : '/sign-in';
        }

        // --- Regra 3: Logado, mas dados pendentes ---
        // A partir daqui, sabemos que `authState is AuthAuthenticated`.

        // ✅ A MÁGICA ESTÁ AQUI:
        // Se os dados da loja ainda estão no estado inicial ou carregando...
        if (storesState is StoresManagerInitial || storesState is StoresManagerLoading) {
          // ...mantemos o usuário na splash page! Não pulamos para a loading-data.
          return location == splashRoute ? null : splashRoute;
        }

        // --- A partir daqui, sabemos que o usuário está logado E os dados da loja foram processados. ---

        // Se o resultado foi "sem lojas"...
        if (storesState is StoresManagerEmpty) {
          return '/stores/new';
        }

        // Se o resultado foi "lojas carregadas"...
        if (storesState is StoresManagerLoaded) {
          // E o usuário ainda está na splash, finalmente o mandamos para o dashboard.
          if (location == splashRoute) {
            return '/stores/${storesState.activeStoreId}/dashboard';
          }
        }

        // Se nenhuma regra se aplicou, a navegação é permitida.
        return null;
      },
  errorPageBuilder:
      (context, state) => MaterialPage(
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

    //
    // GoRoute(
    //     path: '/splash',
    //     builder: (_, state) {
    //       return BlocProvider(
    //         create: (_) => SplashPageCubit(),
    //         child: SplashPage(
    //           redirectTo: state.uri.queryParameters['redirectTo'],
    //         ),
    //       );
    //     },
    //     redirect: (context, state) {
    //       final isInitialized = getIt.isRegistered<bool>(
    //         instanceName: 'isInitialized',
    //       );
    //
    //       if (!isInitialized) return null;
    //
    //       final authState = context.read<AuthCubit>().state;
    //
    //       // if (authState is AuthAuthenticated) {
    //       //   final stores = authState.data.stores;
    //       //   return stores.isEmpty
    //       //       ? '/stores/new'
    //       //       : '/stores/${stores.first.store.id}/orders';
    //       // }
    //
    //       if (authState is AuthUnauthenticated) {
    //         return '/sign-in';
    //       }
    //
    //       return null;
    //     }
    //
    //
    // ),

    GoRoute(
      path: '/sign-in',
      // redirect: (_, state) {
      //   return RouteGuard.apply(state, [AuthGuard(invert: true)]);
      // },
      builder: (_, state) {
        return SignInPage(redirectTo: state.uri.queryParameters['redirectTo']);
      },
    ),
    GoRoute(
      path: '/sign-up',
      // redirect: (_, state) {
      //   return RouteGuard.apply(state, [AuthGuard(invert: true)]);
      // },
      builder: (_, state) {
        return SignUpPage(redirectTo: state.uri.queryParameters['redirectTo']);
      },
    ),
    GoRoute(
      path: '/stores/new',
      builder: (context, state) {
        // A rota agora apenas constrói a página.
        // A página será responsável por criar seu próprio Cubit.
        return const StoreSetupPage();
      },
    ),
    //
    // GoRoute(
    //   path: '/stores/new',
    //   builder: (context, state) {
    //     // 👇 É AQUI que você coloca a lógica de criação 👇
    //     return BlocProvider<StoreSetupCubit>(
    //       create: (context) {
    //         // 1. Acessa o AuthCubit que já deve estar disponível no contexto
    //         final authState = context.read<AuthCubit>().state;
    //         String? userName;
    //
    //         // 2. Verifica se o usuário está autenticado
    //         if (authState is AuthAuthenticated) {
    //           // 3. Pega o nome do usuário a partir do estado de autenticação
    //           //    Ajuste o caminho se necessário (ex: authState.data.user.name)
    //           userName = authState.data.user.name;
    //         }
    //
    //         // 4. Cria uma NOVA instância do StoreSetupCubit, passando as dependências
    //         //    e o nome que acabamos de pegar!
    //         return StoreSetupCubit(
    //           getIt<StoreRepository>(),   // Pega os repositórios do getIt
    //           getIt<SegmentRepository>(),
    //            getIt<UserRepository>(),       // ✅ Passe a dependência
    //           context.read<AuthCubit>(),
    //           context.read<AuthService>(),
    //           initialResponsibleName: userName, // <--- A CONEXÃO ACONTECE AQUI!
    //         )..fetchPlans()..fetchSpecialties();
    //       },
    //       child: const StoreSetupPage(), // O widget que inicia o fluxo
    //     );
    //   },
    // ),


    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        // CORREÇÃO: Leia o e-mail dos parâmetros da URL em vez de 'extra'.
        final email = state.uri.queryParameters['email'];

        // É uma boa prática verificar se o e-mail não é nulo.
        if (email == null) {
          // Retorna uma tela de erro ou redireciona se o e-mail não for encontrado.
          return const Scaffold(
            body: Center(
              child: Text('Erro: E-mail não fornecido.'),
            ),
          );
        }

        return VerifyCodePage(email: email);
      },
    ),



    GoRoute(
      path: '/stores',
      builder: (_, __) => Container(),

      routes: [

        GoRoute(
          path: ':storeId',

          builder: (_, state) {
            return Container();
          },
          routes: [


            // ✅ MOVA A ROTA PARA CÁ
            GoRoute(
              path: '/welcome', // O caminho completo será /stores/:storeId/welcome
              builder: (context, state) {
                final storeId = int.parse(state.pathParameters['storeId']!);
                return WelcomeSetupPage(storeId: storeId);
              },
            ),
            // ✅ ROTA DO WIZARD NO LUGAR CERTO
            GoRoute(
              path: 'wizard-settings', // Caminho relativo. O path completo será /stores/:storeId/wizard-settings
              builder: (context, state) {
                // Agora o storeId está disponível nos parâmetros da rota!
                final storeId = int.parse(state.pathParameters['storeId']!);
                return OnboardingWizardPage(storeId: storeId);
              },
            ),


              StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                final storeId = int.parse(state.pathParameters['storeId']!);
                return AppShell(navigationShell: navigationShell, storeId: storeId,);
              },
              branches: [

                // ✅ DASHBOARD (AGORA A ROTA PRINCIPAL)
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/dashboard', // <-- MUDANÇA 1: O caminho agora é /dashboard
                      pageBuilder: (_, state) => NoTransitionPage(
                        child: DashboardPage(), // <-- MUDANÇA 2: Aponta para a DashboardPage
                      ),
                    ),
                  ],
                ),

                // GESTÃO
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/analytics',
                      pageBuilder: (_, state) => NoTransitionPage(
                        child: AnalyticsPage(), // <-- MUDANÇA 2: Aponta para a DashboardPage
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
                      path: '/performance',
                      pageBuilder: (context, state) { // 2. Usar pageBuilder com NoTransitionPage para manter a consistência do seu AppShell.
                        return NoTransitionPage(
                          child: BlocProvider<PerformanceCubit>(
                            create: (context) {

                              final storeId = int.parse(state.pathParameters['storeId']!);
                              return PerformanceCubit(
                                getIt<AnalyticsRepository>(), // Pega o repositório via GetIt
                                storeId,                      // Passa o ID da loja ativa
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
                      path: '/sell',
                      builder:
                          (_, __) => const Center(
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
                      path: '/tables',
                      builder:
                          (_, __) => const Center(
                            child: Text(
                              'Mesas',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/orders',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            child:  BlocBuilder<StoresManagerCubit, StoresManagerState>(
                          builder: (context, storesState) {
                            if (storesState is StoresManagerLoaded) {
                              return BlocProvider<OrderCubit>(
                                create: (context) => OrderCubit(
                                  realtimeRepository: getIt<RealtimeRepository>(),
                                  storesManagerCubit: context.read<StoresManagerCubit>(),
                                  printManager: getIt<PrintManager>(),
                                ),
                                child: OrdersPage(),
                              );
                            }

                            return const Scaffold(
                              body: Center(child: CircularProgressIndicator()),
                            );
                          },
                          ),








                          ),
                      routes: [

                        GoRoute(
                          path: ':id', // Supondo que a rota pai seja '/stores/:storeId'
                          name: 'order-details',
                          builder: (context, state) {
                            // 1. Tenta pegar o 'extra' como um mapa.
                            final extra = state.extra as Map<String, dynamic>?;

                            // 2. Extrai os objetos do mapa.
                            final OrderDetails? order = extra?['order'];
                            final Store? store = extra?['store'];

                            // 3. Verifica se os dados foram recebidos.
                            if (order != null && store != null) {
                              // 4. Constrói a página com os dados completos.
                              return OrderDetailsPageMobile(
                                order: order,
                                store: store
                              );
                            }

                            // Fallback: Se a página for acessada sem os dados (ex: link direto),
                            // mostra uma tela de erro ou de carregamento.
                            return const Scaffold(
                              body: Center(
                                child: Text("Erro: Não foi possível carregar os dados do pedido."),
                              ),
                            );
                          },
                        ),










                      ],
                    ),
                  ],
                ),




                // PRODUTOS
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/products',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CategoryProductPage(storeId: state.storeId),
                          ),
                      routes: [

                        GoRoute(
                          path: 'new',
                          builder: (_, state) {
                            // ✅ CORRETO: Chama a EditProductPage sem o 'id',
                            // ativando o modo de criação.
                            final category = state.extra as Category?; // Permite passar a categoria
                            return EditProductPage(
                              storeId: state.storeId,
                              category: category,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'create',
                          name: 'product-create-wizard',
                          pageBuilder: (context, state) {

                            final category = state.extra as Category?; // Permite passar a categoria
                            return NoTransitionPage( // ou outra transição que preferir
                              child: ProductWizardPage( storeId: state.storeId,  category: category,),
                            );
                          },
                        ),
                        GoRoute(
                          path: ':productId',
                          pageBuilder: (_, state) {
                            // ✅ PASSO 2: Pega o objeto do 'extra'
                            final product = state.extra as Product?;

                            return NoTransitionPage(
                              key: UniqueKey(),
                              child: EditProductPage(
                                storeId: state.storeId,
                                id: state.productId,
                                product: product, // ✅ Passa o produto para a página
                              ),
                            );
                          },
                        ),

                        // ✅ ADICIONE A NOVA ROTA AQUI
                        GoRoute(
                          path: 'variants/:variantId', // O caminho completo será /stores/:storeId/products/variants/:variantId
                          name: 'variant-edit', // É uma boa prática nomear a rota
                          pageBuilder: (context, state) {
                            // Pega o objeto Variant passado pelo parâmetro 'extra'
                            final variant = state.extra as Variant?;

                            // Se a tela for acessada por um link direto sem o objeto,
                            // mostramos uma tela de erro/carregamento.
                            if (variant == null) {
                              return const NoTransitionPage(
                                child: Scaffold(
                                  body: Center(
                                    child: Text("Erro: Dados do grupo de complemento não foram fornecidos."),
                                  ),
                                ),
                              );
                            }

                            // Se o objeto foi recebido, constrói a tela de edição
                            return NoTransitionPage(
                              key: ValueKey(state.uri.toString()), // Chave para garantir a reconstrução
                              child: VariantEditScreen(variant: variant),
                            );
                          },
                        ),






                      ],
                    ),
                  ],
                ),


                // CATEGORIAS
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/categories',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CreateCategoryPage(),
                          ),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder:
                              (_, state) =>
                                  EditCategoryPage(storeId: state.storeId),
                        ),
                        GoRoute(
                          path: ':id',
                          pageBuilder: (_, state) {
                            return NoTransitionPage(
                              key: UniqueKey(),
                              child: EditCategoryPage(
                                storeId: state.storeId,
                                id: state.id,
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
                      path: '/banners',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/payment-methods',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: PaymentMethodsPage(storeId: state.storeId),
                          ),
                      routes: [

                      ],
                    ),
                  ],
                ),



                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/platform-payment-methods',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                        key: UniqueKey(),
                        child: PlatformPaymentMethodsPage(storeId: state.storeId),
                      ),
                      routes: [

                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/coupons',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/totems',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: TotemsPage(storeId: state.storeId),
                          ),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/cash',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CashPage(storeId: state.storeId),
                          ),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/accesses',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: AccessesPage(storeId: state.storeId),
                          ),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/chatbot',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: ChatBotConfigPage(storeId: state.storeId),
                          ),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    // === BASE: SETTINGS ===
                    GoRoute(
                      path: '/settings',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: StoreProfilePage(storeId: state.storeId),
                          ),
                      routes: [
                        // === HORÁRIOS DE ATENDIMENTO ===
                        // Na sua configuração do GoRouter

                        GoRoute(
                          path: 'hours',
                          pageBuilder: (context, state) { // ✅ 1. Usamos o 'context' que o pageBuilder nos dá.

                            // Pega o storeId dos parâmetros da rota de forma segura
                            final storeId = int.tryParse(state.pathParameters['storeId'] ?? '') ?? 0;

                            // Se o ID for inválido, podemos mostrar uma página de erro
                            if (storeId == 0) {
                              return const NoTransitionPage(
                                child: Scaffold(body: Center(child: Text("ID da loja inválido."))),
                              );
                            }

                            // ✅ 2. Acessamos o StoresManagerCubit que está acima na árvore de widgets
                            final cubit = context.read<StoresManagerCubit>();
                            final cubitState = cubit.state;

                            // ✅ 3. Pegamos a lista de horários do estado do Cubit.
                            // Se o estado não estiver carregado ou não houver loja, passamos uma lista vazia.
                            List<StoreHour> initialHours = [];
                            if (cubitState is StoresManagerLoaded) {
                              initialHours = cubitState.activeStore?.relations.hours ?? [];
                            }

                            // ✅ 4. Finalmente, construímos a página passando a lista de horários.
                            return NoTransitionPage(
                              key: UniqueKey(),
                              child: OpeningHoursPage(
                                storeId: storeId,
                                initialHours: initialHours,
                                // O `isInWizard: false` é o padrão, o que está correto para esta rota.
                              ),
                            );
                          },
                        ),

                        // === FORMAS DE ENTREGA ===
                        GoRoute(
                          path: 'shipping',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: OperationConfigurationPage(storeId:  state.storeId,
                                ),
                              ),
                        ),

                        // === LOCAIS DE ENTREGA ===
                        GoRoute(
                          path: 'locations',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: CityNeighborhoodPage(
                                  storeId: state.storeId,
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
                      path: '/integrations',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/more',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/reports',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/inventory',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/customers',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CustomersPage(storeId: state.storeId),
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
                      path: '/payables',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
                      path: '/plans',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
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
          ],
        ),
      ],
    )
  ]);



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
