import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/coupon.dart';
import 'package:totem_pro_admin/models/coupon_rule.dart';
import 'package:totem_pro_admin/repositories/coupons_repository.dart';
import 'package:totem_pro_admin/widgets/app_date_time_form_field.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

import 'package:brasil_fields/brasil_fields.dart';

import '../../widgets/ds_primary_button.dart';

enum CouponError {
  codeAlreadyExists,
  unknown,
}

class EditCouponPage extends StatefulWidget {
  const EditCouponPage({
    super.key,
    required this.storeId,
    this.id,
    this.coupon,
  });

  final int storeId;
  final int? id;
  final Coupon? coupon;

  bool get isEditing => id != null;

  @override
  State<EditCouponPage> createState() => _EditCouponPageState();
}

class _EditCouponPageState extends State<EditCouponPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Removemos os controllers já que AppTextField gerencia internamente
  // Mantemos apenas os valores atuais
  String _code = '';
  String _description = '';
  String _discountValue = '';
  String _maxDiscount = '';
  String _minOrder = '';
  String _maxUses = '';
  String _maxUsesPerCustomer = '';

  // Valores para os campos que não são de texto
  String _discountType = 'PERCENTAGE';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isForFirstOrder = false;

  @override
  void initState() {
    super.initState();
    final initialCoupon = widget.coupon;

    _discountType = initialCoupon?.discountType ?? 'PERCENTAGE';
    _startDate = initialCoupon?.startDate ?? DateTime.now();
    _endDate = initialCoupon?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _isActive = initialCoupon?.isActive ?? true;
    _isForFirstOrder = initialCoupon?.isForFirstOrder ?? false;

    // Inicializa os valores dos campos de texto
    _code = initialCoupon?.code ?? '';
    _description = initialCoupon?.description ?? '';
    _maxUses = initialCoupon?.maxUsesTotal?.toString() ?? '';
    _maxUsesPerCustomer = initialCoupon?.maxUsesPerCustomer?.toString() ?? '';

    final initialMaxDiscount = initialCoupon?.maxDiscountAmount;
    _maxDiscount = initialMaxDiscount != null ? (initialMaxDiscount / 100).toStringAsFixed(2) : '';

    final initialMinOrder = initialCoupon?.minOrderValue;
    _minOrder = initialMinOrder != null ? (initialMinOrder / 100).toStringAsFixed(2) : '';

    // Lógica especial para o valor do desconto
    if (initialCoupon != null) {
      if (initialCoupon.discountType == 'PERCENTAGE') {
        _discountValue = initialCoupon.discountValue.toInt().toString();
      } else {
        _discountValue = (initialCoupon.discountValue / 100).toStringAsFixed(2);
      }
    } else {
      _discountValue = '';
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    Coupon? initialCoupon;

    if (widget.coupon != null) {
      initialCoupon = widget.coupon;
    } else if (widget.isEditing) {
      final result = await getIt<CouponRepository>().getCoupon(widget.storeId, widget.id!);
      result.fold(
            (error) => _errorMessage = 'Não foi possível carregar o cupom.',
            (couponData) => initialCoupon = couponData,
      );
    }

    if (mounted) {
      setState(() {
        if (initialCoupon != null) {
          _populateForm(initialCoupon!);
        }
        _isLoading = false;
      });
    }
  }

  void _populateForm(Coupon coupon) {
    setState(() {
      _code = coupon.code;
      _description = coupon.description;
      _discountType = coupon.discountType;
      _startDate = coupon.startDate ?? DateTime.now();
      _endDate = coupon.endDate ?? DateTime.now().add(const Duration(days: 30));
      _isActive = coupon.isActive;
      _maxDiscount = coupon.maxDiscountAmount != null ? (coupon.maxDiscountAmount! / 100).toStringAsFixed(2) : '';

      if (coupon.discountType == 'PERCENTAGE') {
        _discountValue = coupon.discountValue.toInt().toString();
      } else {
        _discountValue = (coupon.discountValue / 100).toStringAsFixed(2);
      }

      _isForFirstOrder = coupon.isForFirstOrder;
      _minOrder = coupon.minOrderValue != null ? (coupon.minOrderValue! / 100).toStringAsFixed(2) : '';
      _maxUses = coupon.maxUsesTotal?.toString() ?? '';
      _maxUsesPerCustomer = coupon.maxUsesPerCustomer?.toString() ?? '';
    });
  }

  // Validações robustas
  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código do cupom é obrigatório';
    }
    if (value.length < 3) {
      return 'Código deve ter pelo menos 3 caracteres';
    }
    if (!RegExp(r'^[A-Z0-9_\-]+$').hasMatch(value)) {
      return 'Use apenas letras maiúsculas, números, hífen ou underline';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Descrição é obrigatória';
    }
    if (value.length < 5) {
      return 'Descrição deve ter pelo menos 5 caracteres';
    }
    return null;
  }

  String? _validateDiscountValue(String? value) {
    if (_discountType != 'FREE_DELIVERY') {
      if (value == null || value.isEmpty) {
        return 'Valor do desconto é obrigatório';
      }

      if (_discountType == 'PERCENTAGE') {
        final percent = int.tryParse(value);
        if (percent == null || percent <= 0) {
          return 'Percentual deve ser maior que 0';
        }
        if (percent > 100) {
          return 'Percentual não pode ser maior que 100%';
        }
      } else {
        final amount = UtilBrasilFields.converterMoedaParaDouble(value);
        if (amount <= 0) {
          return 'Valor deve ser maior que R\$ 0,00';
        }
      }
    }
    return null;
  }

  String? _validateMaxDiscount(String? value) {
    if (_discountType == 'PERCENTAGE' && value != null && value.isNotEmpty) {
      final maxDiscount = UtilBrasilFields.converterMoedaParaDouble(value);
      if (maxDiscount <= 0) {
        return 'Valor máximo deve ser maior que R\$ 0,00';
      }
    }
    return null;
  }

  String? _validateMinOrder(String? value) {
    if (value != null && value.isNotEmpty) {
      final minOrder = UtilBrasilFields.converterMoedaParaDouble(value);
      if (minOrder <= 0) {
        return 'Pedido mínimo deve ser maior que R\$ 0,00';
      }
    }
    return null;
  }

  String? _validateMaxUses(String? value) {
    if (value != null && value.isNotEmpty) {
      final maxUses = int.tryParse(value);
      if (maxUses == null || maxUses <= 0) {
        return 'Limite deve ser maior que 0';
      }
    }
    return null;
  }

  String? _validateMaxUsesPerCustomer(String? value) {
    if (value != null && value.isNotEmpty) {
      final maxUses = int.tryParse(value);
      if (maxUses == null || maxUses <= 0) {
        return 'Limite deve ser maior que 0';
      }
    }
    return null;
  }

  String? _validateDates() {
    if (_startDate.isAfter(_endDate)) {
      return 'Data de início não pode ser após a data de fim';
    }
    if (_endDate.isBefore(DateTime.now())) {
      return 'Data de fim não pode ser no passado';
    }
    return null;
  }

  // Métodos para atualizar os valores dos campos
  void _onCodeChanged(String? value) {
    if (value != null) {
      setState(() {
        _code = value;
      });
    }
  }

  void _onDescriptionChanged(String? value) {
    if (value != null) {
      setState(() {
        _description = value;
      });
    }
  }

  void _onDiscountValueChanged(String? value) {
    if (value != null) {
      setState(() {
        _discountValue = value;
      });
    }
  }

  void _onMaxDiscountChanged(String? value) {
    if (value != null) {
      setState(() {
        _maxDiscount = value;
      });
    }
  }

  void _onMinOrderChanged(String? value) {
    if (value != null) {
      setState(() {
        _minOrder = value;
      });
    }
  }

  void _onMaxUsesChanged(String? value) {
    if (value != null) {
      setState(() {
        _maxUses = value;
      });
    }
  }

  void _onMaxUsesPerCustomerChanged(String? value) {
    if (value != null) {
      setState(() {
        _maxUsesPerCustomer = value;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError('Por favor, corrija os erros antes de salvar');
      return;
    }

    // Validação adicional das datas
    final dateError = _validateDates();
    if (dateError != null) {
      _showValidationError(dateError);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final List<CouponRule> rules = [];
      if (_isForFirstOrder) {
        rules.add(CouponRule(ruleType: 'FIRST_ORDER', value: {}));
      }

      final minOrderValueText = _minOrder;
      if (minOrderValueText.isNotEmpty) {
        final minOrderValue = UtilBrasilFields.converterMoedaParaDouble(minOrderValueText) * 100;
        if (minOrderValue > 0) {
          rules.add(CouponRule(ruleType: 'MIN_SUBTOTAL', value: {'value': minOrderValue.toInt()}));
        }
      }

      final maxUses = int.tryParse(_maxUses);
      if (maxUses != null && maxUses > 0) {
        rules.add(CouponRule(ruleType: 'MAX_USES_TOTAL', value: {'limit': maxUses}));
      }

      final maxUsesPerCustomer = int.tryParse(_maxUsesPerCustomer);
      if (maxUsesPerCustomer != null && maxUsesPerCustomer > 0) {
        rules.add(CouponRule(ruleType: 'MAX_USES_PER_CUSTOMER', value: {'limit': maxUsesPerCustomer}));
      }

      double discountValue;
      if (_discountType == 'PERCENTAGE') {
        discountValue = (int.tryParse(_discountValue) ?? 0).toDouble();
      } else if (_discountType == 'FIXED_AMOUNT') {
        discountValue = UtilBrasilFields.converterMoedaParaDouble(_discountValue) * 100;
      } else {
        discountValue = 0;
      }

      int? maxDiscountAmount;
      final maxDiscountText = _maxDiscount;
      if (maxDiscountText.isNotEmpty) {
        maxDiscountAmount = (UtilBrasilFields.converterMoedaParaDouble(maxDiscountText) * 100).round();
      }

      final couponToSave = Coupon(
        id: widget.id,
        code: _code.toUpperCase().trim(),
        description: _description.trim(),
        discountType: _discountType,
        discountValue: discountValue,
        maxDiscountAmount: maxDiscountAmount,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        rules: rules,
      );

      final result = await getIt<CouponRepository>().saveCoupon(widget.storeId, couponToSave);

      if (mounted) {
        result.fold(
              (error) {
            final message = error == CouponError.codeAlreadyExists
                ? 'Este código de cupom já está em uso.'
                : 'Erro ao salvar cupom. Tente novamente.';
            _showError(message);
          },
              (savedCoupon) {
            _showSuccess('Cupom salvo com sucesso!');
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                context.pop(true);
              }
            });
          },
        );
      }
    } catch (e) {
      _showError('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar Cupom' : 'Novo Cupom';

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : ResponsiveBuilder(
        mobileBuilder: (BuildContext context, BoxConstraints constraints) => _buildMobileLayout(title),
        desktopBuilder: (BuildContext context, BoxConstraints constraints) => _buildDesktopLayout(title),
      ),
    );
  }

  Widget _buildMobileLayout(String title) {
    return Column(
      children: [
        Expanded(
          child: _CouponForm(
            formKey: _formKey,
            // Passamos os valores atuais e callbacks para atualização
            codeValue: _code,
            descriptionValue: _description,
            discountValue: _discountValue,
            maxDiscountValue: _maxDiscount,
            minOrderValue: _minOrder,
            maxUsesValue: _maxUses,
            maxUsesPerCustomerValue: _maxUsesPerCustomer,
            discountType: _discountType,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
            isForFirstOrder: _isForFirstOrder,
            onCodeChanged: _onCodeChanged,
            onDescriptionChanged: _onDescriptionChanged,
            onDiscountValueChanged: _onDiscountValueChanged,
            onMaxDiscountChanged: _onMaxDiscountChanged,
            onMinOrderChanged: _onMinOrderChanged,
            onMaxUsesChanged: _onMaxUsesChanged,
            onMaxUsesPerCustomerChanged: _onMaxUsesPerCustomerChanged,
            onStateChanged: (updates) => setState(() => _applyUpdates(updates)),
            isMobile: true,
            validateCode: _validateCode,
            validateDescription: _validateDescription,
            validateDiscountValue: _validateDiscountValue,
            validateMaxDiscount: _validateMaxDiscount,
            validateMinOrder: _validateMinOrder,
            validateMaxUses: _validateMaxUses,
            validateMaxUsesPerCustomer: _validateMaxUsesPerCustomer,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DsButton(
                  label: _isSaving ? 'Salvando...' : 'Salvar',
                  onPressed: _isSaving ? null : _onSave,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDesktopLayout(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
      ),
      child: Column(
        children: [
          FixedHeader(
            title: title,
            actions: [
              DsButton(
                style: DsButtonStyle.secondary,
                onPressed: _isSaving ? null : () => context.pop(),
                label: 'Cancelar',
              ),
              const SizedBox(width: 16),
              DsButton(
                label: _isSaving ? 'Salvando...' : 'Salvar',
                onPressed: _isSaving ? null : _onSave,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _CouponForm(
              formKey: _formKey,
              codeValue: _code,
              descriptionValue: _description,
              discountValue: _discountValue,
              maxDiscountValue: _maxDiscount,
              minOrderValue: _minOrder,
              maxUsesValue: _maxUses,
              maxUsesPerCustomerValue: _maxUsesPerCustomer,
              discountType: _discountType,
              startDate: _startDate,
              endDate: _endDate,
              isActive: _isActive,
              isForFirstOrder: _isForFirstOrder,
              onCodeChanged: _onCodeChanged,
              onDescriptionChanged: _onDescriptionChanged,
              onDiscountValueChanged: _onDiscountValueChanged,
              onMaxDiscountChanged: _onMaxDiscountChanged,
              onMinOrderChanged: _onMinOrderChanged,
              onMaxUsesChanged: _onMaxUsesChanged,
              onMaxUsesPerCustomerChanged: _onMaxUsesPerCustomerChanged,
              onStateChanged: (updates) => setState(() => _applyUpdates(updates)),
              isMobile: false,
              validateCode: _validateCode,
              validateDescription: _validateDescription,
              validateDiscountValue: _validateDiscountValue,
              validateMaxDiscount: _validateMaxDiscount,
              validateMinOrder: _validateMinOrder,
              validateMaxUses: _validateMaxUses,
              validateMaxUsesPerCustomer: _validateMaxUsesPerCustomer,
            ),
          ),
        ],
      ),
    );
  }

  void _applyUpdates(Map<String, dynamic> updates) {
    setState(() {
      if (updates.containsKey('discountType')) {
        _discountType = updates['discountType'];
        // Limpa o valor do desconto quando o tipo muda
        _discountValue = '';
      }
      if (updates.containsKey('startDate') && updates['startDate'] != null) {
        _startDate = updates['startDate'];
      }
      if (updates.containsKey('endDate') && updates['endDate'] != null) {
        _endDate = updates['endDate'];
      }
      if (updates.containsKey('isActive')) {
        _isActive = updates['isActive'];
      }
      if (updates.containsKey('isForFirstOrder')) {
        _isForFirstOrder = updates['isForFirstOrder'];
      }
    });
  }
}

class _CouponForm extends StatelessWidget {
  const _CouponForm({
    required this.formKey,
    required this.codeValue,
    required this.descriptionValue,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountValue,
    required this.minOrderValue,
    required this.maxUsesValue,
    required this.maxUsesPerCustomerValue,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isForFirstOrder,
    required this.onCodeChanged,
    required this.onDescriptionChanged,
    required this.onDiscountValueChanged,
    required this.onMaxDiscountChanged,
    required this.onMinOrderChanged,
    required this.onMaxUsesChanged,
    required this.onMaxUsesPerCustomerChanged,
    required this.onStateChanged,
    required this.isMobile,
    required this.validateCode,
    required this.validateDescription,
    required this.validateDiscountValue,
    required this.validateMaxDiscount,
    required this.validateMinOrder,
    required this.validateMaxUses,
    required this.validateMaxUsesPerCustomer,
  });

  final GlobalKey<FormState> formKey;
  final String codeValue;
  final String descriptionValue;
  final String discountType;
  final String discountValue;
  final String maxDiscountValue;
  final String minOrderValue;
  final String maxUsesValue;
  final String maxUsesPerCustomerValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isForFirstOrder;
  final ValueChanged<String?> onCodeChanged;
  final ValueChanged<String?> onDescriptionChanged;
  final ValueChanged<String?> onDiscountValueChanged;
  final ValueChanged<String?> onMaxDiscountChanged;
  final ValueChanged<String?> onMinOrderChanged;
  final ValueChanged<String?> onMaxUsesChanged;
  final ValueChanged<String?> onMaxUsesPerCustomerChanged;
  final ValueChanged<Map<String, dynamic>> onStateChanged;
  final bool isMobile;
  final String? Function(String?)? validateCode;
  final String? Function(String?)? validateDescription;
  final String? Function(String?)? validateDiscountValue;
  final String? Function(String?)? validateMaxDiscount;
  final String? Function(String?)? validateMinOrder;
  final String? Function(String?)? validateMaxUses;
  final String? Function(String?)? validateMaxUsesPerCustomer;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileForm();
    } else {
      return _buildDesktopForm();
    }
  }

  Widget _buildMobileForm() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _buildFormFields(),
      ),
    );
  }

  Widget _buildDesktopForm() {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informações Básicas'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AppTextField(
                        initialValue: codeValue,
                        title: 'Código *',
                        hint: 'EX: BEMVINDO10',
                        validator: validateCode,
                        onChanged: onCodeChanged,
                        formatters: [UpperCaseTextFormatter()],
                      ),
                      const SizedBox(height: 16),
                      AppDateTimeFormField(
                        title: 'Data de Início *',
                        initialValue: startDate,
                        onChanged: (date) => onStateChanged({'startDate': date}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      AppTextField(
                        initialValue: descriptionValue,
                        title: 'Descrição *',
                        hint: 'Ex: Cupom de 10% para novos clientes',
                        validator: validateDescription,
                        onChanged: onDescriptionChanged,
                      ),
                      const SizedBox(height: 16),
                      AppDateTimeFormField(
                        title: 'Data de Fim *',
                        initialValue: endDate,
                        onChanged: (date) => onStateChanged({'endDate': date}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Ação do Cupom'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Desconto *',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentual (%)')),
                          const DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Valor Fixo (R\$)')),
                          const DropdownMenuItem(value: 'FREE_DELIVERY', child: Text('Frete Grátis')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onStateChanged({'discountType': value});
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (discountType != 'FREE_DELIVERY')
                        AppTextField(
                          initialValue: discountValue,
                          title: discountType == 'PERCENTAGE' ? 'Percentual (%) *' : 'Valor do Desconto (R\$) *',
                          hint: discountType == 'PERCENTAGE' ? 'Ex: 15' : 'Ex: 10,00',
                          keyboardType: TextInputType.number,
                          validator: validateDiscountValue,
                          onChanged: onDiscountValueChanged,
                          formatters: discountType == 'PERCENTAGE'
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                if (discountType == 'PERCENTAGE')
                  Expanded(
                    child: AppTextField(
                      initialValue: maxDiscountValue,
                      title: 'Valor Máximo do Desconto (R\$) (Opcional)',
                      hint: 'Ex: 20,00',
                      keyboardType: TextInputType.number,
                      validator: validateMaxDiscount,
                      onChanged: onMaxDiscountChanged,
                      formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Regras e Condições'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AppTextField(
                        initialValue: minOrderValue,
                        title: 'Pedido Mínimo (R\$) (Opcional)',
                        hint: 'Ex: 50,00',
                        keyboardType: TextInputType.number,
                        validator: validateMinOrder,
                        onChanged: onMinOrderChanged,
                        formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        initialValue: maxUsesValue,
                        title: 'Limite de Usos Totais (Opcional)',
                        hint: 'Ex: 1000',
                        keyboardType: TextInputType.number,
                        validator: validateMaxUses,
                        onChanged: onMaxUsesChanged,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      AppTextField(
                        initialValue: maxUsesPerCustomerValue,
                        title: 'Limite de Usos por Cliente (Opcional)',
                        hint: 'Ex: 1',
                        keyboardType: TextInputType.number,
                        validator: validateMaxUsesPerCustomer,
                        onChanged: onMaxUsesPerCustomerChanged,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Apenas para primeira compra?'),
                        value: isForFirstOrder,
                        onChanged: (value) => onStateChanged({'isForFirstOrder': value}),
                      ),
                      SwitchListTile(
                        title: const Text('Cupom Ativo?'),
                        value: isActive,
                        onChanged: (value) => onStateChanged({'isActive': value}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequiredFieldsNote(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildSectionTitle('Informações Básicas'),
      AppTextField(
        initialValue: codeValue,
        title: 'Código *',
        hint: 'EX: BEMVINDO10',
        validator: validateCode,
        onChanged: onCodeChanged,
        formatters: [UpperCaseTextFormatter()],
      ),
      const SizedBox(height: 16),
      AppTextField(
        initialValue: descriptionValue,
        title: 'Descrição *',
        hint: 'Ex: Cupom de 10% para novos clientes',
        validator: validateDescription,
        onChanged: onDescriptionChanged,
      ),
      const SizedBox(height: 16),
      AppDateTimeFormField(
        title: 'Data de Início *',
        initialValue: startDate,
        onChanged: (date) => onStateChanged({'startDate': date}),
      ),
      const SizedBox(height: 16),
      AppDateTimeFormField(
        title: 'Data de Fim *',
        initialValue: endDate,
        onChanged: (date) => onStateChanged({'endDate': date}),
      ),
      const SizedBox(height: 32),

      _buildSectionTitle('Ação do Cupom'),
      DropdownButtonFormField<String>(
        value: discountType,
        decoration: const InputDecoration(
          labelText: 'Tipo de Desconto *',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentual (%)')),
          const DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Valor Fixo (R\$)')),
          const DropdownMenuItem(value: 'FREE_DELIVERY', child: Text('Frete Grátis')),
        ],
        onChanged: (value) {
          if (value != null) {
            onStateChanged({'discountType': value});
          }
        },
      ),
      const SizedBox(height: 16),
      if (discountType != 'FREE_DELIVERY')
        AppTextField(
          initialValue: discountValue,
          title: discountType == 'PERCENTAGE' ? 'Percentual (%) *' : 'Valor do Desconto (R\$) *',
          hint: discountType == 'PERCENTAGE' ? 'Ex: 15' : 'Ex: 10,00',
          keyboardType: TextInputType.number,
          validator: validateDiscountValue,
          onChanged: onDiscountValueChanged,
          formatters: discountType == 'PERCENTAGE'
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
        ),
      if (discountType == 'PERCENTAGE') ...[
        const SizedBox(height: 16),
        AppTextField(
          initialValue: maxDiscountValue,
          title: 'Valor Máximo do Desconto (R\$) (Opcional)',
          hint: 'Ex: 20,00',
          keyboardType: TextInputType.number,
          validator: validateMaxDiscount,
          onChanged: onMaxDiscountChanged,
          formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
        ),
      ],
      const SizedBox(height: 32),

      _buildSectionTitle('Regras e Condições'),
      AppTextField(
        initialValue: minOrderValue,
        title: 'Pedido Mínimo (R\$) (Opcional)',
        hint: 'Ex: 50,00',
        keyboardType: TextInputType.number,
        validator: validateMinOrder,
        onChanged: onMinOrderChanged,
        formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
      ),
      const SizedBox(height: 16),
      AppTextField(
        initialValue: maxUsesValue,
        title: 'Limite de Usos Totais (Opcional)',
        hint: 'Ex: 1000',
        keyboardType: TextInputType.number,
        validator: validateMaxUses,
        onChanged: onMaxUsesChanged,
        formatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: 16),
      AppTextField(
        initialValue: maxUsesPerCustomerValue,
        title: 'Limite de Usos por Cliente (Opcional)',
        hint: 'Ex: 1',
        keyboardType: TextInputType.number,
        validator: validateMaxUsesPerCustomer,
        onChanged: onMaxUsesPerCustomerChanged,
        formatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Apenas para primeira compra?'),
        value: isForFirstOrder,
        onChanged: (value) => onStateChanged({'isForFirstOrder': value}),
      ),
      SwitchListTile(
        title: const Text('Cupom Ativo?'),
        value: isActive,
        onChanged: (value) => onStateChanged({'isActive': value}),
      ),
      _buildRequiredFieldsNote(),
    ];
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRequiredFieldsNote() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Text(
        '* Campos obrigatórios',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}