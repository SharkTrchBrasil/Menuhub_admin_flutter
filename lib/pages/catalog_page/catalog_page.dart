import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';

import '../../core/app_edit_controller.dart';
import '../../core/app_fetch_controller.dart';
import '../../core/di.dart';
import '../../models/store.dart';
import '../../repositories/store_repository.dart';
import '../../services/dialog_service.dart';
import '../base/BasePage.dart';
import '../create_store/controllers/create_store_controllers.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final StoreRepository storeRepository = getIt();

  late final AppFetchController<Store> controller = AppFetchController<Store>(
    id: widget.storeId,
    fetch: (id) => storeRepository.fetchStore(id),
  );



  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,

      builder: (_, __) {
        return AppPageStatusBuilder<Store>(
          status: controller.status,
          successBuilder: (store) {
            return BasePage(
              mobileBuilder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildSideMenu(context,store),
                      const SizedBox(height: 15),
                      //  Expanded(child: _buildProductList()),
                    ],
                  ),
                );
              },
              desktopBuilder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildProductHeader(),
                            const SizedBox(height: 10),
                            //   Expanded(child: _buildProductList()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(flex: 2, child: _buildSideMenu(context,store)),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _buildSideMenu(BuildContext context, Store store) {
  return Column(
    children: [
      CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(store.image!.url!),
      ),
      const SizedBox(height: 8),
      Text(store.name, style: TextStyle(fontWeight: FontWeight.bold)),
      const Divider(height: 32),
      ListTile(
        onTap: () {
          DialogService.showUrlLinkDialog(context,store);
        },
        contentPadding: EdgeInsets.all(10),

        title: Text(
          "Link do cardápio",

        ),
        isThreeLine: true,
        subtitle: Row(
          children:  [
            Expanded(
              child: Text(
                '',

              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.copy)],
        ),
      ),
      const SizedBox(height: 8),
      ListTile(
        onTap: () {


        },
        contentPadding: EdgeInsets.all(10),

        title: Text(
          "Dados da loja",

        ),
        isThreeLine: true,
        subtitle: Row(
          children:  [
            Expanded(
              child: Text(
                store.zip_code == null || (store.zip_code ?? "").isEmpty
                    ? "Seu cadastro esta incompleto"
                    : "Cadastro completo",
                style: TextStyle(

                  color: store.zip_code == null || (store.zip_code ?? "").isEmpty
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.arrow_forward)],
        ),
      ),
      const SizedBox(height: 8),
      ListTile(
        onTap: () {


        },
        contentPadding: EdgeInsets.all(10),

        title: Text(
          "Formas de pagamento",

        ),
        isThreeLine: true,
        subtitle: Row(
          children:  [
            Expanded(
              child: Text(
                store.zip_code == null || (store.zip_code ?? "").isEmpty
                    ? "Seu cadastro esta incompleto"
                    : "Cadastro completo",
                style: TextStyle(

                  color: store.zip_code == null || (store.zip_code ?? "").isEmpty
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.arrow_forward)],
        ),
      ),
    ],
  );
}

Widget _buildProductHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        // Switch(
        //   value: isCatalogOnline,
        //   onChanged: (value) => setState(() => isCatalogOnline = value),
        // ),
        const Text('Catálogo Online'),
        const Spacer(),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar produto...',
              prefixIcon: const Icon(Icons.search, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text('Filtrar'),
        ),
      ],
    ),
  );
}


