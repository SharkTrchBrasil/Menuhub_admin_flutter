import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
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


import '../pages/accesses/accesses_page.dart';

import '../pages/catalog_page/catalog_page.dart';
import '../pages/chatbot/qrcode.dart';
import '../pages/coupons/coupons_page.dart';

import '../pages/delivery_options/delivery_options_page.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';
import '../pages/edit_payment_methods/edit_payment_methods.dart';
import '../pages/edit_settings/delivery_locations_page.dart';
import '../pages/edit_settings/hours_store_page.dart';
import '../pages/edit_settings/edit_settings_page.dart';


import '../pages/edit_variant/edit_variant_page.dart';
import '../pages/integrations/integrations_page.dart';
import '../pages/kds/kds_page.dart';
import '../pages/not_found/error_505_Page.dart';
import '../pages/orders/orders_page.dart';

import '../pages/payables/payables_page.dart';
import '../pages/totems/totems_page.dart';
import '../pages/variants/variants_page.dart';
import '../pages/verify_code/verify_code_page.dart';
import '../repositories/store_repository.dart';

import 'guards/store_owner_guard.dart';

final router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  redirectLimit: 10,
  observers: [BotToastNavigatorObserver()],

  redirect: (context, state) {
    final isInitializedRegistered = getIt.isRegistered<bool>(
      instanceName: 'isInitialized',
    );

    final isSplash = state.fullPath == '/splash';

    if (!isInitializedRegistered ||
        !getIt.get<bool>(instanceName: 'isInitialized')) {
      // Permite apenas a splash
      return isSplash ? null : '/splash?redirectTo=${state.uri.toString()}';
    }

    // Já está inicializado, mas está na splash
    if (isSplash) {
      return '/sign-in'; // ou '/' se quiser ir direto pro app
    }

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
        return SplashPage(redirectTo: state.uri.queryParameters['redirectTo']);
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

    GoRoute(path: '/', builder: (context, state) => const Sales()),

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
              return '/stores/${state.pathParameters['storeId']}/orders';
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

                // PEDIDOS
                StatefulShellBranch(
                  routes: [
                    GoRoute(path: '/orders', builder: (_, __) => Sales()),
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
                      pageBuilder: (_, state) => NoTransitionPage(
                        key: UniqueKey(),
                        child: VariantsPage(storeId: state.storeId),
                      ),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder: (_, state) => EditVariantPage(
                            storeId: state.storeId,
                            id: null,
                          ),
                        ),
                        GoRoute(
                          path: ':variantId',
                          pageBuilder: (_, state) => NoTransitionPage(
                            key: UniqueKey(),
                            child: EditVariantPage(
                              storeId: state.storeId,
                              id: state.variantId,
                            ),
                          ),
                          routes: [
                            GoRoute(
                              path: 'options/new',
                              builder: (_, state) => EditVariantOptionPage(
                                storeId: state.storeId,
                                variantId: state.variantId,
                                id: null,
                              ),
                            ),
                            GoRoute(
                              path: 'options/:optionId',
                              pageBuilder: (_, state) => NoTransitionPage(
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
                        GoRoute(
                          path: 'new',
                          builder: (_, state) {
                            return EditCouponPage(storeId: state.storeId);
                          },
                        ),
                        GoRoute(
                          path: ':id',
                          pageBuilder: (_, state) {
                            return NoTransitionPage(
                              key: UniqueKey(),
                              child: EditCouponPage(
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
                            child: EditSettingsPage(storeId: state.storeId),
                          ),
                      routes: [
                        // === HORÁRIOS DE ATENDIMENTO ===
                        GoRoute(
                          path: 'hours',
                          pageBuilder:
                              (_, state) => NoTransitionPage(
                                key: UniqueKey(),
                                child: OpeningHoursPage(
                                  storeId: state.storeId,
                                ),
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



              ],

              // MESAS
            ),
          ],
        ),
      ],
    ),


  ],
);
