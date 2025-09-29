// ARQUIVO: lib/pages/settings/store_profile_page.dart (RENOMEADO)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer';

// --- IMPORTS DO SEU PROJETO ---
import 'package:totem_pro_admin/constdata/typography.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/tabs/address_settings_tab.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/tabs/general_settings_tab.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/tabs/social_media_tab.dart';

import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

// ✅ 1. CLASSE RENOMEADA
class StoreProfilePage extends StatefulWidget {
  final int storeId;
  // ✅ 2. NOVO PARÂMETRO 'isInWizard'
  final bool isInWizard;

  const StoreProfilePage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
  });

  @override
  // ✅ 3. STATE COM NOME PÚBLICO
  State<StoreProfilePage> createState() => StoreProfilePageState();
}

class StoreProfilePageState extends State<StoreProfilePage> {
  final StoreRepository storeRepository = getIt();
  final formKey = GlobalKey<FormState>();

  // 'Rascunho' local da loja para edição
  Store? _editableStore;

  // Variáveis de controle para sincronização
  int? _storeIdForSync;
  DateTime? _dataLastSynced;


  // ✅ 1. INICIALIZAÇÃO DOS DADOS NO initState
  @override
  void initState() {
    super.initState();
    // Pega o estado atual do Cubit assim que a página é criada
    final currentState = context.read<StoresManagerCubit>().state;
    if (currentState is StoresManagerLoaded && currentState.activeStore != null) {
      print('📝 Inicializando UI da StoreProfilePage com dados do Cubit...');
      // Popula o nosso 'rascunho' local com uma cópia dos dados atuais
      _editableStore = currentState.activeStore!.copyWith();
      _dataLastSynced = currentState.lastUpdate;
    }
  }

  // ✅ 4. MÉTODO 'save' PÚBLICO PARA O WIZARD
  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_editableStore == null) return false;

    try {
      // Usamos o repositório para salvar o 'rascunho'
      await storeRepository.updateStore(widget.storeId, _editableStore!);
      if (mounted) {
        // Notifica o Cubit para recarregar os dados, mantendo tudo sincronizado
       // context.read<StoresManagerCubit>().reloadActiveStore();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações salvas com sucesso!'), backgroundColor: Colors.green),
        );
      }
      return true; // Sucesso
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
      return false; // Falha
    }
  }

  void _onStoreChanged(Store updatedStore) {
    setState(() {
      _editableStore = updatedStore;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 5. LÓGICA DE SINCRONIZAÇÃO MOVIDA PARA O BlocListener
    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, state) {
        if (state is StoresManagerLoaded) {
          final activeStore = state.activeStore;
          if (activeStore == null) return;

          // Sincroniza o 'rascunho' local se os dados do Cubit forem mais recentes
          if (_storeIdForSync != activeStore.core.id || _dataLastSynced != state.lastUpdate) {
            log('🔄 Sincronizando UI da StoreProfilePage com dados do Cubit...');
            setState(() {
              _editableStore = activeStore.copyWith(); // Cria uma cópia para edição
              _storeIdForSync = activeStore.core.id;
              _dataLastSynced = state.lastUpdate;
            });
          }
        }
      },
      // ✅ 6. BUILD CONDICIONAL
      child: widget.isInWizard
          ? _buildWizardContent()
          : _buildStandalonePage(),
    );
  }

  // MÉTODO PARA A PÁGINA COMPLETA (MODO NORMAL)
  Widget _buildStandalonePage() {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FixedHeader(title: 'Informações da loja'),
SizedBox(height: 32,),
            Expanded(child: _buildWizardContent()),
          ],
        ),
      ),

    );
  }

  // MÉTODO PARA O CONTEÚDO DO FORMULÁRIO (REUTILIZADO)
  Widget _buildWizardContent() {
    // ✅ 7. BlocBuilder SIMPLIFICADO

        if (_editableStore == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: formKey,
          child: DefaultTabController(
            length: 3,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft, // <-- AQUI
                  child: _buildTabBar(),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: TabBarView(
                    children: [
                      GeneralSettingsTab(store: _editableStore!, onChanged: _onStoreChanged),
                      AddressSettingsTab(store: _editableStore!, onChanged: _onStoreChanged),
                      SocialMediaTab(store: _editableStore!, onChanged: _onStoreChanged),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    AppPrimaryButton(
                      onPressed: save, // Botão chama o método público
                      label: 'Salvar Alterações',
                    ),
                  ],
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        );

  }

// O método para construir a TabBar pode continuar aqui
  Widget _buildTabBar() {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        _buildTab(icon: "assets/images/user.svg", text: "Geral"),
        _buildTab(icon: "assets/images/share.svg", text: "Endereço"),
        _buildTab(
          icon: "assets/images/fingerprint-viewfinder.svg",
          text: "Redes Sociais",
        ),
      ],
    );
  }

  Widget _buildTab({required String icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            height: 20,
            width: 20,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Typographyy.bodyMediumMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}



