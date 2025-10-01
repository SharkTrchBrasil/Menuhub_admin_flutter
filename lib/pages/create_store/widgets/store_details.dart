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
  bool _urlEditedManually = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<StoreSetupCubit>().state;
    urlController = TextEditingController(text: state.storeUrl);

    urlController.addListener(() {
      if (urlFocusNode.hasFocus && urlController.text.isNotEmpty) {
        context.read<StoreSetupCubit>().updateStoreDetails(
          url: urlController.text,
          urlEditedManually: _urlEditedManually,
        );
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

  void _updateUrlController(String newUrl) {
    if (!_urlEditedManually && urlController.text != newUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          urlController.text = newUrl;
          urlController.selection = TextSelection.fromPosition(
            TextPosition(offset: urlController.text.length),
          );
        }
      });
    }
  }

  Widget _buildUrlFeedback(BuildContext context) {
    final state = context.watch<StoreSetupCubit>().state;
    final urlInField = urlController.text.trim();

    if (state.urlChecking) {
      return const Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: LinearProgressIndicator(),
      );
    }

    if (!state.urlChecking && state.lastCheckedUrl != null && state.lastCheckedUrl == urlInField) {
      if (state.isUrlTaken) {
        return const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'URL indisponível',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'URL disponível - Seu cardápio ficará em: $urlInField.menuhub.com.br',
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StoreSetupCubit>().state;
    final cubit = context.read<StoreSetupCubit>();

    if (!_urlEditedManually && state.storeUrl != urlController.text) {
      _updateUrlController(state.storeUrl);
    }

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
         // padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            AppTextField(
              title: 'Nome da Loja',
              hint: 'O nome que seus clientes verão',
              initialValue: state.storeName,
              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              onChanged: (v) {
                cubit.updateStoreDetails(name: v);
                final generatedUrl = (v ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        
                if (!_urlEditedManually) {
                  cubit.updateStoreDetails(url: generatedUrl);
                  _updateUrlController(generatedUrl);
        
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
        
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (generatedUrl.isNotEmpty) {
                      cubit.checkUrlAvailability(generatedUrl);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ TÍTULO DO CAMPO
                const Text(
                  'URL do Cardápio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: urlController,
                  focusNode: urlFocusNode,
                  decoration: InputDecoration(
                    hintText: 'ex: minhapizzaria',
                    suffixText: '.menuhub.com.br',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obrigatório';
                    if (!RegExp(r'^[a-z0-9]+$').hasMatch(v)) {
                      return 'Use apenas letras minúsculas e números';
                    }
                    if (state.isUrlTaken && state.lastCheckedUrl == v) {
                      return 'Essa URL já está em uso';
                    }
                    return null;
                  },
                  onChanged: (v) {
                    // 👉 Marca como editado manualmente só se for diferente do que foi gerado
                    if (!_urlEditedManually) {
                      _urlEditedManually = true;
                    }

                    cubit.updateStoreDetails(url: v, urlEditedManually: true);

                    if (widget.formKey.currentState != null) {
                      widget.formKey.currentState!.validate();
                    }

                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (v.isNotEmpty) {
                        cubit.checkUrlAvailability(v);
                      }
                    });
                  },
                ),

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
              validator: validMobilePhone,
              onChanged: (v) => cubit.updateStoreDetails(phone: v),
            ),
          ],
        ),
      ),
    );
  }

  String? validMobilePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone obrigatório';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 11 || !digitsOnly.startsWith('1') && digitsOnly[2] != '9') {
      return 'Telefone inválido';
    }

    return null;
  }
}