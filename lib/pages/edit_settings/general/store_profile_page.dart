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
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/store/store_media.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field_banner.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field_logo.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/core/helpers/mask.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../core/responsive_builder.dart';
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

  bool validateForm() {
    // O método `validate()` do FormState faz o trabalho pesado:
    // 1. Executa o `validator` de cada campo.
    // 2. Mostra as mensagens de erro abaixo dos campos inválidos.
    // 3. Retorna `true` se tudo estiver OK, `false` caso contrário.
    return formKey.currentState?.validate() ?? false;
  }

  // ✅ 1. ADICIONADO _originalStore PARA GUARDAR O ESTADO INICIAL
  Store? _originalStore;
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
      // ✅ 2. GUARDA TANTO A VERSÃO ORIGINAL QUANTO A EDITÁVEL
      _originalStore = currentState.activeStore!.copyWith();
      _editableStore = currentState.activeStore!.copyWith();
      _dataLastSynced = currentState.lastUpdate;
    }
  }





  // ✅ PASSO 2: SIMPLIFICAR O MÉTODO `save`
  // Ele não precisa mais verificar as mudanças, pois o wizard fará isso.
  Future<bool> save() async {
    if (_editableStore == null) return false;

    log('💾 Iniciando processo de salvamento...');
    if (!(formKey.currentState?.validate() ?? false)) {
      log('❌ Validação falhou.');
      return false;
    }

    formKey.currentState!.save();

    try {
      await storeRepository.updateStore(widget.storeId, _editableStore!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações salvas com sucesso!'), backgroundColor: Colors.green),
        );
      }
      // Atualiza o estado original para refletir o novo estado salvo.
      setState(() {
        _originalStore = _editableStore?.copyWith();
      });
      log('✅ Salvo com sucesso.');
      return true;
    } catch (e) {
      log('🔥 Erro ao salvar: $e');
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
              // ✅ 4. ATUALIZA AMBOS OS ESTADOS QUANDO HÁ SINCRONIZAÇÃO EXTERNA
              _originalStore = activeStore.copyWith();
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

  // O restante do arquivo permanece o mesmo...
  Widget _buildStandalonePage() {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isDesktop(context) ? 24: 14.0),
            child: _buildUnifiedContent(),
          )),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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

            _buildSectionHeader(
              icon: "assets/images/fingerprint-viewfinder.svg",
              title: "Mídia da Loja",
              subtitle: "Logo e imagem de capa do seu estabelecimento",
            ),
            const SizedBox(height: 24),
            _buildMediaSection(),
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
    );
  }

  Widget _buildSectionHeader({required String icon, required String title, required String subtitle}) {
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

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImageFormFieldLogo(
          title: 'Logo da Loja*',
          initialValue: _editableStore!.media?.image,
          onChanged: (imageModel) {
            _onStoreChanged(
              _editableStore!.copyWith(
                media: (_editableStore!.media ?? StoreMedia()).copyWith(image: imageModel),
              ),
            );
          },
          validator: (imageModel) {
            if (imageModel == null || (imageModel.file == null && imageModel.url == null)) {
              return 'A logo da loja é obrigatória.'; // ← Esta mensagem agora será exibida corretamente
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
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
            return null;
          },
        ),
      ],
    );
  }


  Widget _buildGeneralSection() {
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






  // ✅✅✅ MÉTODO hasChanges ATUALIZADO PARA SER 100% CONFIÁVEL ✅✅✅
  bool hasChanges() {
    if (_editableStore == null || _originalStore == null) {
      return false; // Sem dados, sem mudanças.
    }

    // Compara os campos primitivos um por um, tratando nulos.
    // O `?.trim()` ajuda a ignorar diferenças de espaços em branco.
    if (_editableStore?.core.name.trim() != _originalStore?.core.name.trim()) return true;
    if (_editableStore?.core.description?.trim() != _originalStore?.core.description?.trim()) return true;
    if (_editableStore?.core.phone?.trim() != _originalStore?.core.phone?.trim()) return true;

    // Compara o endereço
    if (_editableStore?.address?.zipCode?.trim() != _originalStore?.address?.zipCode?.trim()) return true;
    if (_editableStore?.address?.street?.trim() != _originalStore?.address?.street?.trim()) return true;
    if (_editableStore?.address?.number?.trim() != _originalStore?.address?.number?.trim()) return true;
    if (_editableStore?.address?.neighborhood?.trim() != _originalStore?.address?.neighborhood?.trim()) return true;
    if (_editableStore?.address?.complement?.trim() != _originalStore?.address?.complement?.trim()) return true;
    if (_editableStore?.address?.city?.trim() != _originalStore?.address?.city?.trim()) return true;
    if (_editableStore?.address?.state?.trim() != _originalStore?.address?.state?.trim()) return true;

    // Compara redes sociais
    if (_editableStore?.marketing?.instagram?.trim() != _originalStore?.marketing?.instagram?.trim()) return true;
    if (_editableStore?.marketing?.facebook?.trim() != _originalStore?.marketing?.facebook?.trim()) return true;
    if (_editableStore?.marketing?.tiktok?.trim() != _originalStore?.marketing?.tiktok?.trim()) return true;

    // Compara as mídias (logo e banner).
    // Compara tanto se um novo arquivo foi selecionado quanto se a URL mudou.
    if (_editableStore?.media?.image?.file != _originalStore?.media?.image?.file ||
        _editableStore?.media?.image?.url != _originalStore?.media?.image?.url) {
      return true;
    }
    if (_editableStore?.media?.banner?.file != _originalStore?.media?.banner?.file ||
        _editableStore?.media?.banner?.url != _originalStore?.media?.banner?.url) {
      return true;
    }

    // Se nenhuma das verificações acima encontrou diferença, então não houve mudanças.
    log('🔎 Detecção: NÃO houve mudanças nos campos do formulário.');
    return false;
  }





}