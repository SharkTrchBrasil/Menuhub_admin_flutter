// ARQUIVO: lib/pages/settings/store_profile_page.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:developer';

// --- IMPORTS DO SEU PROJETO ---
import 'package:totem_pro_admin/constdata/typography.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/image_model.dart'; // ✅ 1. IMPORTAR ImageModel
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/store/store_media.dart'; // ✅ 2. IMPORTAR StoreMedia
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field_banner.dart'; // ✅ 3. IMPORTAR WIDGETS DE IMAGEM
import 'package:totem_pro_admin/widgets/app_image_form_field_logo.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/core/helpers/mask.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../models/store/store_address.dart';

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

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

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

    // Salva o formulário para garantir que todos os `onSaved` sejam chamados, se houver
    formKey.currentState!.save();

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FixedHeader(title: 'Informações da loja'),
          const SizedBox(height: 16),
          Expanded(child: _buildUnifiedContent()),
        ],
      ),
    );
  }

  Widget _buildWizardContent() {
    return _buildUnifiedContent();
  }

  Widget _buildUnifiedContent() {
    if (_editableStore == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 16),
              const FixedHeader(
                title: 'Configurações da loja',
                subtitle: 'Defina as informações da sua loja.',
              ),
              const SizedBox(height: 16),

              // SEÇÃO GERAL
              _buildSectionHeader(
                icon: "assets/images/user.svg",
                title: "Informações Gerais",
                subtitle: "Dados básicos do seu estabelecimento",
              ),
              const SizedBox(height: 24),
              _buildGeneralSection(),
              const SizedBox(height: 40),

              // ✅ NOVA SEÇÃO DE MÍDIA
              _buildSectionHeader(
                icon: "assets/images/fingerprint-viewfinder.svg", // Ícone de exemplo
                title: "Mídia da Loja",
                subtitle: "Logo e imagem de capa do seu estabelecimento",
              ),
              const SizedBox(height: 24),
              _buildMediaSection(), // <-- NOSSA NOVA SEÇÃO
              const SizedBox(height: 40),

              // SEÇÃO ENDEREÇO
              _buildSectionHeader(
                icon: "assets/images/share.svg",
                title: "Endereço",
                subtitle: "Localização física da sua loja",
              ),
              const SizedBox(height: 24),
              _buildAddressSection(),
              const SizedBox(height: 40),

              // SEÇÃO REDES SOCIAIS
              _buildSectionHeader(
                icon: "assets/images/fingerprint-viewfinder.svg",
                title: "Redes Sociais",
                subtitle: "Conecte suas redes sociais",
              ),
              const SizedBox(height: 24),
              _buildSocialMediaSection(),

              // BOTÃO SALVAR
              if (!widget.isInWizard)
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 24),
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

  Widget _buildSectionHeader({required String icon, required String title, required String subtitle}) {
    // ... (nenhuma mudança aqui)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          height: 24,
          width: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ ================================================================
  // ✅ PASSO 4: CONSTRUIR A SEÇÃO DE MÍDIA
  // ✅ ================================================================
  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LOGO ---
        AppImageFormFieldLogo(
          title: 'Logo da Loja',
          initialValue: _editableStore!.media?.image,
          onChanged: (imageModel) {
            _onStoreChanged(
              _editableStore!.copyWith(
                media: (_editableStore!.media ?? StoreMedia()).copyWith(image: imageModel),
              ),
            );
          },
          validator: (imageModel) {
            // Validação: obrigatório ter uma imagem (seja URL existente ou novo arquivo)
            if (imageModel == null || (imageModel.file == null && imageModel.url == null)) {
              return 'A logo da loja é obrigatória.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // --- BANNER ---
        AppImageFormFieldBanner(
          title: 'Banner da Loja',
          aspectRatio: 1920 / 375,
          initialValue: _editableStore!.media?.banner,
          onChanged: (imageModel) {
            _onStoreChanged(
              _editableStore!.copyWith(
                media: (_editableStore!.media ?? StoreMedia()).copyWith(banner: imageModel),
              ),
            );
          },
          validator: (imageModel) {
            // Banner é opcional, então não precisa de validação
            return null;
          },
        ),
      ],
    );
  }


  Widget _buildGeneralSection() {
    // ... (nenhuma mudança aqui)
    return Column(
      children: [
        AppTextField(
          initialValue: _editableStore!.core.name,
          title: 'Nome do estabelecimento',
          hint: 'Minha loja',
          validator: (title) {
            if (title == null || title.isEmpty) return 'Campo obrigatório';
            if (title.length < 3) return 'Nome muito curto';
            return null;
          },
          onChanged: (name) {
            _onStoreChanged(
                _editableStore!.copyWith(core: _editableStore!.core.copyWith(name: name))
            );
          },
        ),
        const SizedBox(height: 20),
        AppTextField(
          initialValue: _editableStore!.core.description,
          title: 'Descrição da loja',
          hint: 'Descreva sua loja',
          maxLines: 4,
          maxLength: 400,
          keyboardType: TextInputType.multiline,
          onChanged: (desc) {
            _onStoreChanged(
                _editableStore!.copyWith(core: _editableStore!.core.copyWith(description: desc))
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                initialValue: _editableStore!.core.phone,
                title: 'Telefone de contato*',
                hint: '(11) 99999-9999',

                keyboardType: TextInputType.phone,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter(),
                ],
                validator: (s) {
                  if (s == null || s.trim().isEmpty) return 'Campo obrigatório';
                  try {
                    final phone = PhoneNumber.parse(s, destinationCountry: IsoCode.BR);
                    if (!phone.isValid(type: PhoneNumberType.mobile)) return 'Número de celular inválido';
                    return null;
                  } catch (e) {
                    return 'Número inválido';
                  }
                },
                onChanged: (phone) {
                  _onStoreChanged(
                      _editableStore!.copyWith(core: _editableStore!.core.copyWith(phone: phone))
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    // ... (nenhuma mudança aqui)
    return Column(
      children: [
        AppTextField(
          initialValue: _editableStore!.address?.zipCode,
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  address: _editableStore!.address?.copyWith(zipCode: v)
                      ?? StoreAddress(zipCode: v)
              )
          ),
          title: 'CEP',
          hint: '00000-000',
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            CepInputFormatter(),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          initialValue: _editableStore!.address?.street,
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  address: _editableStore!.address?.copyWith(street: v)
                      ?? StoreAddress(street: v)
              )
          ),
          title: 'Rua / Avenida',
          hint: 'Digite o nome da rua',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                initialValue: _editableStore!.address?.number,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,

                ],
                onChanged: (v) => _onStoreChanged(
                    _editableStore!.copyWith(
                        address: _editableStore!.address?.copyWith(number: v)
                            ?? StoreAddress(number: v)
                    )
                ),
                title: 'Número',
                hint: '123',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                initialValue: _editableStore!.address?.neighborhood,
                onChanged: (v) => _onStoreChanged(
                    _editableStore!.copyWith(
                        address: _editableStore!.address?.copyWith(neighborhood: v)
                            ?? StoreAddress(neighborhood: v)
                    )
                ),
                title: 'Bairro',
                hint: 'Centro',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          initialValue: _editableStore!.address?.complement,
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  address: _editableStore!.address?.copyWith(complement: v)
                      ?? StoreAddress(complement: v)
              )
          ),
          title: 'Complemento (Opcional)',
          hint: 'Apto, Bloco, etc.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                initialValue: _editableStore!.address?.city,
                onChanged: (v) => _onStoreChanged(
                    _editableStore!.copyWith(
                        address: _editableStore!.address?.copyWith(city: v)
                            ?? StoreAddress(city: v)
                    )
                ),
                title: 'Cidade',
                hint: 'São Paulo',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: AppTextField(
                initialValue: _editableStore!.address?.state,
                onChanged: (v) => _onStoreChanged(
                    _editableStore!.copyWith(
                        address: _editableStore!.address?.copyWith(state: v)
                            ?? StoreAddress(state: v)
                    )
                ),
                title: 'Estado',
                hint: 'SP',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    // ... (NENHUMA MUDANÇA AQUI, mas note a segurança com `?.`)
    return Column(
      children: [
        AppTextField(
          initialValue: _editableStore!.marketing?.instagram,
          title: 'Instagram',
          hint: '@sua_loja',
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  marketing: _editableStore!.marketing?.copyWith(instagram: v)
              )
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          initialValue: _editableStore!.marketing?.facebook,
          title: 'Facebook',
          hint: 'facebook.com/sua_loja',
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  marketing: _editableStore!.marketing?.copyWith(facebook: v)
              )
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          initialValue: _editableStore!.marketing?.tiktok,
          title: 'TikTok',
          hint: 'tiktok.com/@sua_loja',
          onChanged: (v) => _onStoreChanged(
              _editableStore!.copyWith(
                  marketing: _editableStore!.marketing?.copyWith(tiktok: v)
              )
          ),
        ),
      ],
    );
  }
}