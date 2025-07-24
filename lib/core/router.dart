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

import 'package:totem_pro_admin/pages/edit_variant_option/edit_variant_option_page.dart';
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
import '../models/order_details.dart';
import '../models/store.dart';
import '../pages/accesses/accesses_page.dart';

import '../pages/banners/banners_page.dart';
import '../pages/catalog_page/catalog_page.dart';
import '../pages/chatbot/qrcode.dart';
import '../pages/coupons/coupons_page.dart';

import '../pages/customers/customers_page.dart';
import '../pages/delivery_options/delivery_options_page.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';
import '../pages/edit_payment_methods/edit_payment_methods.dart';
import '../pages/edit_settings/delivery_locations_page.dart';
import '../pages/edit_settings/hours_store_page.dart';
import '../pages/edit_settings/edit_settings_page.dart';

import '../pages/plans/plans_page.dart';
import '../pages/edit_variant/edit_variant_page.dart';
import '../pages/integrations/integrations_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/kds/kds_page.dart';
import '../pages/loading/loading_data_page.dart';
import '../pages/not_found/error_505_Page.dart';

import '../pages/orders/order_page_cubit.dart';
import '../pages/orders/orders_page.dart';

import '../services/printer_manager.dart';
import '../pages/orders/store_settings.dart';
import '../pages/orders/widgets/order_details_mobile.dart';
import '../pages/payables/payables_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/splash/splash_page_cubit.dart';
import '../pages/totems/totems_page.dart';
import '../pages/variants/variants_page.dart';
import '../pages/verify_code/verify_code_page.dart';
import '../repositories/realtime_repository.dart';
import '../repositories/store_repository.dart';

import '../services/auth_service.dart';
import '../cubits/auth_cubit.dart';

import 'guards/store_owner_guard.dart';
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  required AuthCubit authCubit,
  required StoresManagerCubit storesManagerCubit,
}) {
  return GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirectLimit: 10,
    observers: [BotToastNavigatorObserver()],
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authCubit.stream),
      GoRouterRefreshStream(storesManagerCubit.stream),
    ]),


// Dentro da sua configuração do GoRouter

      redirect: (BuildContext context, GoRouterState state) {
        final authCubit = context.read<AuthCubit>();
        final authState = authCubit.state;
        final location = state.uri.toString();

        // Variáveis para facilitar a leitura da lógica
        final isLoading = authState is AuthInitial || authState is AuthLoading;
        final isAuthenticated = authState is AuthAuthenticated;


        final isGoingToSplash = location == '/loading';


        const authRoutes = ['/sign-in', '/sign-up'];
        final isGoingToAuthRoute = authRoutes.any((route) => location.startsWith(route));


        // REGRA 1: Se o app ainda está carregando o status de autenticação...
        if (isLoading) {


          if (isGoingToSplash || isGoingToAuthRoute) {
            return null;
          }
          return '/loading';



        }

        // REGRA 2: Se o usuário ESTÁ autenticado...
        if (isAuthenticated) {
          // ... e está na tela de splash ou de login, redireciona para dentro do app.
          if (isGoingToSplash || isGoingToAuthRoute) {
            final stores = authState.data.stores;
            if (stores.isEmpty) {
              return '/stores/new';
            } else {
              final activeStoreId = stores.first.store.id;
              return '/stores/$activeStoreId/orders';
            }
          }
        }

        // REGRA 3: Se o usuário NÃO ESTÁ autenticado (e não está carregando)...
        if (!isAuthenticated) {
          // ... e tenta acessar qualquer rota que não seja a de login, redireciona para o login.
          if (!isGoingToAuthRoute) {
            return '/sign-in';
          }
        }

        // Se nenhuma regra acima foi acionada, permite a navegação.
        return null;
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
        if (isInitialized) {
          return '/sign-in';
        }
        return null;
      },

    ),

    GoRoute(
      path: '/sign-in',
      redirect: (_, state) {
        return RouteGuard.apply(state, [AuthGuard(invert: true)]);
      },
      builder: (_, state) {
        return SignInPage(redirectTo: state.uri.queryParameters['redirectTo']);
      },
    ),
    GoRoute(
      path: '/sign-up',
      redirect: (_, state) {
        return RouteGuard.apply(state, [AuthGuard(invert: true)]);
      },
      builder: (_, state) {
        return SignUpPage(redirectTo: state.uri.queryParameters['redirectTo']);
      },
    ),
    GoRoute(
      path: '/stores/new',
      redirect: (_, state) {
        return RouteGuard.apply(state, [AuthGuard()]);
      },
      builder: (_, state) {
        return CreateStorePage();
      },
    ),

    GoRoute(
      path: '/loading',
      builder: (_, state) => LoadingDataPage(), // <-- ADICIONE AQUI
    ),

    GoRoute(
      path: '/verify-code',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        final email = extra['email']!;
        final password = extra['password']!;
        return VerifyCodePage(email: email, password: password);
      },
    ),

    GoRoute(
      path: '/stores',
      builder: (_, __) => Container(),
      redirect: (_, state) {
        if (state.fullPath == '/stores') {
          final StoreRepository storeRepository = getIt();
          if (storeRepository.stores.isNotEmpty) {
            return '/stores/${storeRepository.stores.first.store.id}';
          } else {
            return '/stores/new';
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: ':storeId',
          redirect: (_, state) {
            if (state.fullPath == '/stores/:storeId') {
              return '/stores/${state.pathParameters['storeId']}/products';
            }
            return null;
          },
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
                          builder:
                              (_, state) =>
                                  EditProductPage(storeId: state.storeId),
                        ),
                        GoRoute(
                          path: ':productId',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: EditProductPage(
                                  storeId: state.storeId,
                                  id: state.productId,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/variants',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: VariantsPage(storeId: state.storeId),
                          ),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder:
                              (_, state) => EditVariantPage(
                                storeId: state.storeId,
                                id: null,
                              ),
                        ),
                        GoRoute(
                          path: ':variantId',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: EditVariantPage(
                                  storeId: state.storeId,
                                  id: state.variantId,
                                ),
                              ),
                          routes: [
                            GoRoute(
                              path: 'options/new',
                              builder:
                                  (_, state) => EditVariantOptionPage(
                                    storeId: state.storeId,
                                    variantId: state.variantId,
                                    id: null,
                                  ),
                            ),
                            GoRoute(
                              path: 'options/:optionId',
                              pageBuilder:
                                  (_, state) => NoTransitionPage(
                                    key: UniqueKey(),
                                    child: EditVariantOptionPage(
                                      storeId: state.storeId,
                                      variantId: state.variantId,
                                      id: state.optionId,
                                    ),
                                  ),
                            ),
                          ],
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
                    ),
                  ],
                ),

                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/catalog',
                      pageBuilder:
                          (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: CatalogPage(storeId: state.storeId),
                          ),
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
                      redirect:
                          (_, state) =>
                              RouteGuard.apply(state, [StoreOwnerGuard()]),
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
