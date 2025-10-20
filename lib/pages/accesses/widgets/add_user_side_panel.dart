// pages/accesses/widgets/add_user_side_panel.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_drop_down_form_field.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../../core/enums/store_access.dart';

class AddUserSidePanel extends StatefulWidget {
  const AddUserSidePanel({
    super.key,
    this.storeId,
    required this.availableStores,
  });

  final int? storeId;
  final List<StoreWithRole> availableStores;

  @override
  State<AddUserSidePanel> createState() => _AddUserSidePanelState();
}

class _AddUserSidePanelState extends State<AddUserSidePanel> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Campos do formulário
  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  StoreAccessRole? role;
  StoreWithRole? selectedStore;

  // Estados
  bool isLoading = false;
  String storeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeSelectedStore();
  }

  void _initializeSelectedStore() {
    if (widget.availableStores.isEmpty) return;

    if (widget.storeId != null) {
      final matchingStore = widget.availableStores
          .where((s) => s.store.core.id == widget.storeId)
          .firstOrNull;
      selectedStore = matchingStore ?? widget.availableStores.first;
    } else {
      selectedStore = widget.availableStores.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isMobile
          ? AppBar(
        title: const Text('Adicionar Usuário'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      )
          : null,
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) ...[
                  _buildHeader(),
                  const SizedBox(height: 24),
                ],
                _buildStoreSelector(isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                _buildUserFields(isMobile),
                SizedBox(height: isMobile ? 24 : 32),
                _buildActionButtons(isMobile),
                if (isMobile) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Text(
          'Adicionar Usuário',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreSelector(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: Colors.blue.shade700,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Text(
                  'Loja de Vínculo',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              if (widget.availableStores.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.availableStores.length} lojas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Campo de busca (se tiver mais de 5 lojas)
          if (widget.availableStores.length > 5) ...[
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar loja...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => storeSearchQuery = value.toLowerCase());
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
          ],

          // Dropdown de lojas
          AppDropDownFormField<StoreWithRole>(
            value: selectedStore,
            onChanged: (store) {
              setState(() => selectedStore = store);
            },
            items: _getFilteredStores()
                .map((store) => DropdownMenuItem(
              value: store,
              child: _buildStoreItem(store, isMobile),
            ))
                .toList(),
            validator: (v) {
              if (v == null) {
                return 'Selecione uma loja';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(StoreWithRole store, bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 32 : 36,
          height: isMobile ? 32 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            Icons.storefront,
            size: isMobile ? 16 : 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                store.store.core.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (store.store.address?.city != null)
                Text(
                  store.store.address!.city!,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserFields(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: Colors.green.shade700,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Dados do Usuário',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          AppTextField(
            title: 'Nome Completo',
            hint: 'Digite o nome completo',
            onChanged: (v) => name = v ?? '',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              if (v.trim().length < 3) {
                return 'Nome deve ter no mínimo 3 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          AppTextField(
            title: 'E-mail',
            hint: 'Digite o e-mail do usuário',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => email = v ?? '',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              if (!EmailValidator.validate(v)) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          AppTextField(
            title: 'Telefone',
            hint: '(00) 00000-0000',
            keyboardType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              TelefoneInputFormatter(),
            ],
            onChanged: (v) => phone = v ?? '',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
              if (digitsOnly.length < 10) {
                return 'Telefone inválido';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          AppTextField(
            title: 'Senha',
            hint: 'Mínimo 6 caracteres',
            isHidden: true,
            onChanged: (v) => password = v ?? '',
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Campo obrigatório';
              }
              if (v.length < 6) {
                return 'Senha deve ter no mínimo 6 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          AppDropDownFormField<StoreAccessRole>(
            title: 'Função',
            onChanged: (v) => role = v,
            items: StoreAccessRole.selectableRoles
                .map((r) => DropdownMenuItem(
              value: r,
              child: Row(
                children: [
                  Icon(
                    _getRoleIcon(r),
                    size: isMobile ? 16 : 18,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    r.title,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
            validator: (v) {
              if (v == null) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: isMobile ? 14 : null,
              ),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          flex: isMobile ? 2 : 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
            ),
            child: isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Criar Usuário',
              style: TextStyle(
                fontSize: isMobile ? 14 : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<StoreWithRole> _getFilteredStores() {
    if (storeSearchQuery.isEmpty) {
      return widget.availableStores;
    }

    return widget.availableStores.where((store) {
      final name = store.store.core.name.toLowerCase();
      final city = store.store.address?.city?.toLowerCase() ?? '';
      return name.contains(storeSearchQuery) ||
          city.contains(storeSearchQuery);
    }).toList();
  }

  IconData _getRoleIcon(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.manager:
        return Icons.admin_panel_settings_rounded;
      case StoreAccessRole.cashier:
        return Icons.point_of_sale_rounded;
      case StoreAccessRole.waiter:
        return Icons.room_service_rounded;
      case StoreAccessRole.stockManager:
        return Icons.inventory_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedStore == null) {
      showError('Selecione uma loja para vincular o usuário.');
      return;
    }

    if (role == null) {
      showError('Selecione uma função para o usuário.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await getIt<StoreRepository>().createUserForStore(
        storeId: selectedStore!.store.core.id!,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.replaceAll(RegExp(r'\D'), ''),
        password: password,
        role: role!,
      );

      if (!mounted) return;

      result.fold(
            (failure) {
          setState(() => isLoading = false);

          if (failure.message.contains('e-mail')) {
            showError('Este e-mail já está cadastrado no sistema.');
          } else if (failure.message.contains('telefone')) {
            showError('Este telefone já está em uso.');
          } else {
            showError(failure.message);
          }
        },
            (access) {
          showSuccess(
            'Usuário ${access.user.name} adicionado à ${selectedStore!.store.core.name}!',
          );
          context.pop(true);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showError('Erro inesperado: ${e.toString()}');
      }
    }
  }
}