import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

// Importe seus modelos e widgets necessários
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../widgets/store_mockup_preview_card.dart';

// Remova os imports do cubit e state se não estiver usando em outro lugar

class GeneralSettingsTab extends StatefulWidget {
  final Store store;
  // O onChanged original pode ser usado para notificar o widget pai quando salvar
  final Function(Store) onChanged;

  const GeneralSettingsTab({
    super.key,
    required this.store,
    required this.onChanged,
  });

  @override
  State<GeneralSettingsTab> createState() => _GeneralSettingsTabState();
}



class _GeneralSettingsTabState extends State<GeneralSettingsTab> {
  // Cópia local do 'store' para permitir edições e atualizações na UI
  late Store _localStore;

  @override
  void didUpdateWidget(GeneralSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Esta verificação garante que só atualizaremos o estado local
    // se o objeto 'store' vindo do pai realmente mudou.
    if (widget.store != oldWidget.store) {
      setState(() {
        _localStore = widget.store;
      });
    }
  }

  // Mask para o campo de telefone
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    // Inicializa a cópia local com os dados recebidos
    _localStore = widget.store;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildDesktopLayout());
        } else {
          return _buildMobileLayout();
        }

      },
    );
  }

  // ===================================================================
  // =================== LAYOUT PARA DESKTOP ===========================
  // ===================================================================
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildNameAndDescriptionFields(),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: StoreProfilePreviewCard(store: _localStore),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          const SizedBox(height: 32),
          _buildCategoryAndContactFields(),
          const SizedBox(height: 48),

        ],
      ),
    );
  }

  // ===================================================================
  // ==================== LAYOUT PARA MOBILE ===========================
  // ===================================================================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 32),
          _buildNameAndDescriptionFields(),
          const SizedBox(height: 24),
          _buildCategoryAndContactFields(),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onChanged(_localStore),
              child: const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ===================================================================
  // ============== WIDGETS AUXILIARES REUTILIZÁVEIS ===================
  // ===================================================================

  Widget _buildMobileHeader() {
    final logoUrl = _localStore.media?.image?.url ?? '';
    final bannerUrl = _localStore.media?.banner?.url ?? '';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
            image: bannerUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover)
                : null,
          ),
          child: bannerUrl.isEmpty ? const Icon(Icons.image, color: Colors.grey, size: 50) : null,
        ),
        Positioned(
          left: 16,
          bottom: -25,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
              child: logoUrl.isEmpty ? const Icon(Icons.store, size: 40) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          initialValue: _localStore.core.name,
          title: 'Nome do estabelecimento',
          hint: 'Minha loja',
          validator: (title) {
            if (title == null || title.isEmpty) return 'Campo obrigatório';
            if (title.length < 3) return 'Nome muito curto';
            return null;
          },
          onChanged: (name) {
            setState(() {
              _localStore = _localStore.copyWith(core: _localStore.core.copyWith(name: name));
            });
            widget.onChanged(_localStore); // 🔥 importante!
          },
        ),

        const SizedBox(height: 24),
        AppTextField(
          initialValue: _localStore.core.description,
          title: 'Descrição da loja',
          hint: 'Descreva sua loja',
          maxLines: 12,
          maxLength: 400,
          keyboardType: TextInputType.multiline,
          onChanged: (desc) {
            setState(() {
              _localStore = _localStore.copyWith(core: _localStore.core.copyWith(description: desc));
            });
            widget.onChanged(_localStore); // 🔥 importante!
          },
        ),

      ],
    );
  }

  Widget _buildCategoryAndContactFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOTE: O dropdown de categoria precisa de uma lógica para buscar os dados.
              // Por enquanto, usaremos um AppTextField como placeholder.
              // Você pode substituir por um FutureBuilder + DropdownButton depois.
              AppTextField(
                initialValue: _localStore.core.name ?? '',
                readOnly: true, // Apenas para visualização por enquanto
                title: 'Categoria*',
                hint: 'Selecione a categoria',
                // onTap: () {
                //   // Aqui você abriria um modal ou outra tela para selecionar a categoria
                //   print("Lógica para selecionar categoria a ser implementada.");
                // },
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: AppTextField(
            initialValue: _localStore.core.phone,
            title: 'Telefone de contato*',
            hint: 'enter_your_phone'.tr(),
            formatters: [phoneMask],
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
              setState(() {
                _localStore = _localStore.copyWith(core: _localStore.core.copyWith(phone: phone));
              });
              widget.onChanged(_localStore); // 🔥 importante!
            },
          ),

        ),
      ],
    );
  }
}