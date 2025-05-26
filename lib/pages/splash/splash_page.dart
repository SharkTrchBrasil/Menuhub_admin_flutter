import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_logo.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import '../../core/responsive_builder.dart';
import '../../core/store_provider.dart';
import '../../models/store_with_role.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.redirectTo});

  final String? redirectTo;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                SizedBox(
                    height: 30,
                    width: 30,
                    child: Image(
                      image: AssetImage('assets/images/Symbol123.png'),
                      fit: BoxFit.fill,
                    )),
                SizedBox(width: 10),
                Text('PDVix',
                    style: TextStyle(
                        fontFamily: 'Jost-SemiBold',
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }


  Future<void> initialize() async {
    final AuthRepository authRepository = getIt();
    final StoreRepository storeRepository = getIt();
    final isLoggedIn = await authRepository.initialize();
    getIt.registerSingleton(true, instanceName: 'isInitialized');

    if(!isLoggedIn) {
      if(mounted) context.go('/sign-in');
      return;
    }

    final getStoresResult = await storeRepository.getStores();
    if(getStoresResult.isLeft) {
      showError('Não foi possível buscar suas lojas.');
      return;
    } else {
      final stores = getStoresResult.right;

      if(!mounted) return;

      if(stores.isNotEmpty) {
        context.go(widget.redirectTo ?? '/stores/${stores.first.store.id}/orders');
      } else {
        context.go('/stores/new');
      }
    }
  }
}
