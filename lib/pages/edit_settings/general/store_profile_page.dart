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

class StoreProfilePage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;

  const StoreProfilePage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
  });

  @override
  State<StoreProfilePage> createState() => StoreProfilePageState();
}

class StoreProfilePageState extends State<StoreProfilePage> {
  final StoreRepository storeRepository = getIt();
  final formKey = GlobalKey<FormState>();
  Store? _editableStore;
  int? _storeIdForSync;
  DateTime? _dataLastSynced;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<StoresManagerCubit>().state;
    if (currentState is StoresManagerLoaded && currentState.activeStore != null) {
      log('📝 Inicializando UI da StoreProfilePage com dados do Cubit...');
      _editableStore = currentState.activeStore!.copyWith();
      _dataLastSynced = currentState.lastUpdate;
    }
  }

  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (_editableStore == null) return false;

    try {
      await storeRepository.updateStore(widget.storeId, _editableStore!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações salvas com sucesso!'), backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  void _onStoreChanged(Store updatedStore) {
    setState(() {
      _editableStore = updatedStore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoresManagerCubit, StoresManagerState>(
      listener: (context, state) {
        if (state is StoresManagerLoaded) {
          final activeStore = state.activeStore;
          if (activeStore == null) return;
          if (_storeIdForSync != activeStore.core.id || _dataLastSynced != state.lastUpdate) {
            log('🔄 Sincronizando UI da StoreProfilePage com dados do Cubit...');
            setState(() {
              _editableStore = activeStore.copyWith();
              _storeIdForSync = activeStore.core.id;
              _dataLastSynced = state.lastUpdate;
            });
          }
        }
      },
      child: widget.isInWizard
          ? _buildWizardContent()
          : _buildStandalonePage(),
    );
  }

  Widget _buildStandalonePage() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FixedHeader(title: 'Informações da loja'),
            const SizedBox(height: 32),
            // ✅ CORREÇÃO: Envolve o conteúdo com Expanded aqui para o modo standalone
            Expanded(child: _buildWizardContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardContent() {
    if (_editableStore == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ CORREÇÃO: O conteúdo reutilizável agora é um SingleChildScrollView.
    // Isso resolve o problema de altura infinita dentro do Stepper.
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _buildTabBar(),
              ),
              const SizedBox(height: 25),
              // ✅ CORREÇÃO: O TabBarView precisa de uma altura fixa.
              // Damos a ele uma altura razoável para o conteúdo dos formulários.
              SizedBox(
                height: 400, // Ajuste esta altura conforme necessário
                child: TabBarView(
                  children: [
                    GeneralSettingsTab(store: _editableStore!, onChanged: _onStoreChanged),
                    AddressSettingsTab(store: _editableStore!, onChanged: _onStoreChanged),
                    SocialMediaTab(store: _editableStore!, onChanged: _onStoreChanged),
                  ],
                ),
              ),
              // O botão de salvar só é mostrado no modo standalone.
              // No wizard, os botões são controlados pelo Stepper.
              if (!widget.isInWizard)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppPrimaryButton(
                        onPressed: save,
                        label: 'Salvar Alterações',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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