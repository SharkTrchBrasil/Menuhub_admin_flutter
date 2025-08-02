import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/core/guards/auth_guard.dart';
import 'package:totem_pro_admin/core/guards/route_guard.dart';
import 'package:totem_pro_admin/pages/cash/cash_page.dart';
import 'package:totem_pro_admin/pages/categories/categories_page.dart';
import 'package:totem_pro_admin/pages/create_store/create_store_page.dart';
import 'package:totem_pro_admin/pages/edit_category/edit_category_page.dart';
import 'package:totem_pro_admin/pages/edit_product/edit_product_page.dart';


import 'package:totem_pro_admin/pages/home/home_page.dart';
import 'package:totem_pro_admin/pages/more/more_page.dart';
import 'package:totem_pro_admin/pages/payment_methods/payment_methods_page.dart';
import 'package:totem_pro_admin/pages/products/products_page.dart';
import 'package:totem_pro_admin/pages/sign_in/sign_in_page.dart';
import 'package:totem_pro_admin/pages/sign_up/sign_up_page.dart';
import 'package:totem_pro_admin/pages/splash/splash_page.dart';

import '../cubits/auth_state.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/category.dart';
import '../models/order_details.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../models/store_with_role.dart';
import '../pages/accesses/accesses_page.dart';

import '../pages/banners/banners_page.dart';

import '../pages/chatbot/qrcode.dart';
import '../pages/coupons/coupons_page.dart';

import '../pages/create_store/cubit/store_setup_cubit.dart';
import '../pages/customers/customers_page.dart';
import '../pages/delivery_options/delivery_options_page.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';
import '../pages/edit_payment_methods/edit_payment_methods.dart';
import '../pages/edit_settings/delivery_locations_page.dart';
import '../pages/edit_settings/hours_store_page.dart';
import '../pages/edit_settings/edit_settings_page.dart';

import '../pages/plans/plans_page.dart';

import '../pages/integrations/integrations_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/kds/kds_page.dart';
import '../pages/loading/loading_data_page.dart';
import '../pages/not_found/error_505_Page.dart';

import '../pages/orders/order_page_cubit.dart';
import '../pages/orders/orders_page.dart';


import '../pages/orders/widgets/order_details_mobile.dart';
import '../pages/payables/payables_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/splash/splash_page_cubit.dart';
import '../pages/totems/totems_page.dart';

import '../pages/verify_code/verify_code_page.dart';
import '../repositories/realtime_repository.dart';
import '../repositories/segment_repository.dart';
import '../repositories/store_repository.dart';

import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../cubits/auth_cubit.dart';

import '../services/print/printer_manager.dart';
import 'guards/store_owner_guard.dart';
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

// NÃO use mais uma função. Crie uma classe ou uma variável final.
class AppRouter {
  static final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirectLimit: 10,
    observers: [BotToastNavigatorObserver()],


      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(getIt<AuthCubit>().stream),
        GoRouterRefreshStream(getIt<StoresManagerCubit>().stream),
      ]),



// Em lib/core/router.dart, dentro do GoRouter

      redirect: (BuildContext context, GoRouterState state) {
        final location = state.uri.toString();
        final authState = context
            .read<AuthCubit>()
            .state;
        final isAuthenticated = authState is AuthAuthenticated;

        // Imprime o estado atual em cada execução do redirect
        print('--- GoRouter Redirect ---');
        print('Location: $location');
        print('AuthState: ${authState.runtimeType}');
        print('isAuthenticated: $isAuthenticated');

        // Rotas que não exigem login
        const publicRoutes = [
          '/splash',
          '/loading',
          '/sign-in',
          '/sign-up',
          '/verify-email'
        ];
        final isGoingToPublicRoute = publicRoutes.any((r) =>
            location.startsWith(r));

        // 👇👇👇 AQUI: redireciona para verificação se for necessário
        if (authState is AuthNeedsVerification &&
            !location.startsWith('/verify-email')) {
          final email = Uri.encodeComponent(authState.email);
          return '/verify-email?email=$email';
        }



        // Trava de segurança para quando já estamos no destino correto
        if (isAuthenticated && authState.data.stores.isEmpty &&
            location == '/stores/new') {
          print('Decisão: Deixar passar (já no destino /stores/new).');
          print('-------------------------\n');
          return null;
        }
        if (isAuthenticated && authState.data.stores.isNotEmpty &&
            location.startsWith('/stores/')) {
          print('Decisão: Deixar passar (já dentro de uma loja).');
          print('-------------------------\n');
          return null;
        }

        // Se estiver autenticado e tentando ir para uma rota pública, redireciona para dentro
        if (isAuthenticated && isGoingToPublicRoute) {
          final stores = authState.data.stores;
          final destination = stores.isEmpty ? '/stores/new' : '/stores/${stores
              .first.store.id}/orders';
          print('Decisão: Redirecionar para dentro do app -> $destination');
          print('-------------------------\n');
          return destination;
        }

        // Se NÃO estiver autenticado e tentando ir para uma rota protegida...
        if (!isAuthenticated && !isGoingToPublicRoute) {
          final destination = '/sign-in?redirectTo=$location';
          print('Decisão: Redirecionar para o login -> $destination');
          print('-------------------------\n');
          return destination;
        }

        if (isAuthenticated) {
          // 👇 LÓGICA DE VERIFICAÇÃO DE "DONO" CORRIGIDA 👇
          final ownerOnlyRoutes = ['/settings', '/integrations', '/plans'];
          final isGoingToOwnerRoute = ownerOnlyRoutes.any((r) =>
              location.contains(r));

          if (isGoingToOwnerRoute) {
            final storeId = int.tryParse(state.pathParameters['storeId'] ?? '');
            if (storeId != null) {
              final storeRepo = getIt<StoreRepository>();
              StoreWithRole? store; // Declara a variável como anulável

              try {
                // Tenta encontrar a loja. Se não encontrar, vai para o catch.
                store =
                    storeRepo.stores.firstWhere((s) => s.store.id == storeId);
              } catch (e) {
                // Se a loja não for encontrada na lista, o 'store' continua null.
                // Isso é normal e esperado se a lista ainda estiver carregando.
                store = null;
              }

              // Se a loja foi encontrada e o usuário não é o dono, redireciona.
              if (store != null && store.role != StoreAccessRole.owner) {
                print(
                    'Decisão: Acesso negado (não é dono). Redirecionando para /products.');
                return '/stores/$storeId/orders';
              }
            }
          }
        }
      },

  errorPageBuilder:
      (context, state) => MaterialPage(
        child: NotFoundPage(), // sua página 404
      ),

  routes: [


    GoRoute(
        path: '/splash',
        builder: (_, state) {
          return BlocProvider(
            create: (_) => SplashPageCubit(),
            child: SplashPage(
              redirectTo: state.uri.queryParameters['redirectTo'],
            ),
          );
        },
        redirect: (context, state) {
          final isInitialized = getIt.isRegistered<bool>(
            instanceName: 'isInitialized',
          );

          if (!isInitialized) return null;

          final authState = context.read<AuthCubit>().state;

          if (authState is AuthAuthenticated) {
            final stores = authState.data.stores;
            return stores.isEmpty
                ? '/stores/new'
                : '/stores/${stores.first.store.id}/orders';
          }

          if (authState is AuthUnauthenticated) {
            return '/sign-in';
          }

          return null;
        }


    ),

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
        // 👇 É AQUI que você coloca a lógica de criação 👇
        return BlocProvider<StoreSetupCubit>(
          create: (context) {
            // 1. Acessa o AuthCubit que já deve estar disponível no contexto
            final authState = context.read<AuthCubit>().state;
            String? userName;

            // 2. Verifica se o usuário está autenticado
            if (authState is AuthAuthenticated) {
              // 3. Pega o nome do usuário a partir do estado de autenticação
              //    Ajuste o caminho se necessário (ex: authState.data.user.name)
              userName = authState.data.user.name;
            }

            // 4. Cria uma NOVA instância do StoreSetupCubit, passando as dependências
            //    e o nome que acabamos de pegar!
            return StoreSetupCubit(
              getIt<StoreRepository>(),   // Pega os repositórios do getIt
              getIt<SegmentRepository>(),
               getIt<UserRepository>(),       // ✅ Passe a dependência
              context.read<AuthCubit>(),
              initialResponsibleName: userName, // <--- A CONEXÃO ACONTECE AQUI!
            )..fetchPlans()..fetchSpecialties();
          },
          child: const StoreSetupPage(), // O widget que inicia o fluxo
        );
      },
    ),

    GoRoute(
      path: '/loading',
      builder: (_, state) => LoadingDataPage(), // <-- ADICIONE AQUI
    ),

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
      // redirect: (_, state) {
      //   if (state.fullPath == '/stores') {
      //     final StoreRepository storeRepository = getIt();
      //     if (storeRepository.stores.isNotEmpty) {
      //       return '/stores/${storeRepository.stores.first.store.id}';
      //     } else {
      //       return '/stores/new';
      //     }
      //   }
      //   return null;
      // },
      routes: [
        GoRoute(
          path: ':storeId',
          // redirect: (_, state) {
          //   if (state.fullPath == '/stores/:storeId') {
          //     return '/stores/${state.pathParameters['storeId']}/products';
          //   }
          //   return null;
          // },
          builder: (_, state) {
            return Container();
          },
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) {
                return HomePage(shell: shell, storeId: state.storeId);
              },

              branches: [
                // DASHBOARD
                StatefulShellBranch(
                  routes: [
                    GoRoute(path: '/home', builder: (_, state) => Container()),
                  ],
                ),

                // GESTÃO
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/management',
                      builder:
                          (_, __) => const Center(
                            child: Text(
                              'Gestão',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
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











                // StatefulShellBranch(
                //   routes: [
                //     GoRoute(
                //       path: '/orders',
                //       pageBuilder: (context, state) => NoTransitionPage(
                //         key: UniqueKey(),
                //         child: BlocProvider(
                //           create: (_) => OrderCubit(GetIt.I<RealtimeRepository>()),
                //           child: OrdersPage(storeId: state.storeId),
                //         ),
                //       ),
                //       routes: [
                //         GoRoute(
                //           path: ':id',
                //           pageBuilder: (context, state) => NoTransitionPage(
                //             key: UniqueKey(),
                //             child: BlocProvider.value(
                //               value: context.read<OrderCubit>(),
                //               child: OrderDetailsPage(
                //                 storeId: state.storeId,
                //             //    id: state.pathParameters['id']!, // ou state.id se tiver extensão
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),

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
                            child: CategoriesPage(storeId: state.storeId),
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
                        GoRoute(
                          path: 'new',
                          builder:
                              (_, state) =>
                                  EditPaymentMethods(storeId: state.storeId),
                        ),
                        GoRoute(
                          path: ':id',
                          pageBuilder: (_, state) {
                            return NoTransitionPage(
                              key: UniqueKey(),
                              child: EditPaymentMethods(
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
                      path: '/coupons',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CouponsPage(storeId: state.storeId),
                          ),
                      routes: [
                        // GoRoute(
                        //   path: 'new',
                        //   builder: (_, state) {
                        //     return EditCouponPage(storeId: state.storeId);
                        //   },
                        // ),
                        // GoRoute(
                        //   path: ':id',
                        //   pageBuilder: (_, state) {
                        //     return NoTransitionPage(
                        //       key: UniqueKey(),
                        //       child: EditCouponPage(
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
                            child: Settings(storeId: state.storeId),
                          ),
                      routes: [
                        // === HORÁRIOS DE ATENDIMENTO ===
                        GoRoute(
                          path: 'hours',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: OpeningHoursPage(storeId: state.storeId),
                              ),
                        ),

                        // === FORMAS DE ENTREGA ===
                        GoRoute(
                          path: 'shipping',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: DeliveryOptionsPage(
                                  storeId: state.storeId,
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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





bool _isPublicRoute(String path) {
  return [
    '/splash',
    '/sign-in',
    '/sign-up',
    '/verify-code',
    '/loading-data',
  ].any((publicRoute) => path.startsWith(publicRoute));
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
