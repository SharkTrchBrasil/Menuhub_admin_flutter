import 'dart:async';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup_cubit.dart';

class StoreDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const StoreDetailsStep({required this.formKey, super.key});

  @override
  State<StoreDetailsStep> createState() => _StoreDetailsStepState();
}

class _StoreDetailsStepState extends State<StoreDetailsStep> {
  final urlFocusNode = FocusNode();
  late final TextEditingController urlController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final state = context.read<StoreSetupCubit>().state;
    urlController = TextEditingController(text: state.storeUrl);

    urlFocusNode.addListener(() {
      // Valida a URL quando o campo perde o foco
      if (!urlFocusNode.hasFocus) {
        final url = urlController.text.trim();
        // Só faz a verificação se o campo não estiver vazio e se a URL mudou desde a última checagem
        if (url.isNotEmpty && url != state.lastCheckedUrl) {
          context.read<StoreSetupCubit>().checkUrlAvailability(url);
        }
      }
    });
  }

  @override
  void dispose() {
    urlFocusNode.dispose();
    urlController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Widget helper para o feedback da URL
  Widget _buildUrlFeedback(BuildContext context) {
    final state = context.watch<StoreSetupCubit>().state;
    final urlInField = urlController.text.trim();

    // 1. Mostra o LinearProgressIndicator enquanto verifica
    if (state.urlChecking) {
      return const Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: LinearProgressIndicator(),
      );
    }

    // 2. Só mostra o status (disponível/indisponível) se a verificação foi concluída
    //    para o texto que está atualmente no campo.
    if (!state.urlChecking && state.lastCheckedUrl != null && state.lastCheckedUrl == urlInField) {
      if (state.isUrlTaken) {
        // 3. URL Indisponível
        return const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'URL indisponível',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      } else {
        // 4. URL Disponível
        return const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'URL disponível',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        );
      }
    }

    // Por padrão, não mostra nada
    return const SizedBox.shrink();
  }


  @override
  Widget build(BuildContext context) {
    final state = context.watch<StoreSetupCubit>().state;
    final cubit = context.read<StoreSetupCubit>();

    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 4), // Pequeno ajuste de padding
        children: [







          AppTextField(
            title: 'Nome da Loja',
            hint: 'O nome que seus clientes verão',
            initialValue: state.storeName,
            validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
            onChanged: (v) {
              cubit.updateStoreDetails(name: v);
              final generatedUrl = (v ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

              if (!state.urlEditedManually) {
                cubit.updateStoreDetails(url: generatedUrl);
                urlController.text = generatedUrl;

                // Cancela qualquer verificação anterior que estava agendada
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                // Agenda uma nova verificação para daqui a 500ms
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  // Só verifica se a URL não for vazia
                  if (generatedUrl.isNotEmpty) {
                    cubit.checkUrlAvailability(generatedUrl);
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // ✅ MUDANÇA AQUI: Envolvemos o campo da URL e o feedback em uma Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                title: 'URL do Cardápio',
                hint: 'ex: minhapizzaria',
                controller: urlController,
                focusNode: urlFocusNode,
                // Removido o prefix/suffix text para um look mais limpo
                // ✅ MUDANÇA AQUI: O suffixIcon foi removido
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (!RegExp(r'^[a-z0-9]+$').hasMatch(v)) {
                    return 'Use apenas letras minúsculas e números';
                  }
                  // A validação de "URL em uso" agora é feita pelo feedback visual,
                  // mas podemos manter no validador para garantir.
                  if (state.isUrlTaken && state.lastCheckedUrl == v) {
                    return 'Essa URL já está em uso';
                  }
                  return null;
                },
                onChanged: (v) {
                  // Marca que a URL foi editada e atualiza o estado
                  cubit.updateStoreDetails(url: v, urlEditedManually: true);
                  // Dispara a revalidação do formulário para o status da URL
                  if (widget.formKey.currentState != null) {
                    widget.formKey.currentState!.validate();
                  }
                },
              ),
              // ✅ MUDANÇA AQUI: Adiciona o widget de feedback dinâmico
              _buildUrlFeedback(context),
            ],
          ),
          const SizedBox(height: 16),

          AppTextField(
            title: 'Descrição Curta (Opcional)',
            hint: 'Ex: A melhor pizza da região, com ingredientes frescos.',
            initialValue: state.storeDescription,
            onChanged: (v) => cubit.updateStoreDetails(description: v),
          ),
          const SizedBox(height: 16),

          AppTextField(
            title: 'Telefone de Contato da Loja',
            hint: '(00) 00000-0000',
            initialValue: state.storePhone,
            keyboardType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              TelefoneInputFormatter(),
            ],
            validator: (v) => (v == null || v.length < 14) ? 'Telefone inválido' : null,
            onChanged: (v) => cubit.updateStoreDetails(phone: v),
          ),
        ],
      ),
    );
  }


  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required Color color,
    bool hasTooltip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: hasTooltip
                ? Tooltip(
              message: 'Informação adicional',
              child: Text(
                text,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
              ),
            )
                : Text(text),
          ),
        ],
      ),
    );
  }

}