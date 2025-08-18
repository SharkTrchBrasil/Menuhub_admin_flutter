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
  String? _errorMessage;

  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountValueController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _minOrderController;
  late TextEditingController _maxUsesController;
  late TextEditingController _maxUsesPerCustomerController;

  // Valores para os campos que não são de texto
  String _discountType = 'PERCENTAGE';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isForFirstOrder = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _codeController = TextEditingController();
    _descriptionController = TextEditingController();
    _discountValueController = TextEditingController();
    _maxDiscountController = TextEditingController();
    _minOrderController = TextEditingController();
    _maxUsesController = TextEditingController();
    _maxUsesPerCustomerController = TextEditingController();
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
    } else {
      initialCoupon = Coupon(
        code: '',
        description: '',
        discountType: 'PERCENTAGE',
        discountValue: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
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
    _codeController.text = coupon.code;
    _descriptionController.text = coupon.description;
    _discountType = coupon.discountType;
    _startDate = coupon.startDate ?? DateTime.now();
    _endDate = coupon.endDate ?? DateTime.now().add(const Duration(days: 30));
    _isActive = coupon.isActive;
    _maxDiscountController.text = coupon.maxDiscountAmount != null ? (coupon.maxDiscountAmount! / 100).toStringAsFixed(2) : '';

    if (coupon.discountType == 'PERCENTAGE') {
      _discountValueController.text = coupon.discountValue.toInt().toString();
    } else { // FIXED_AMOUNT
      _discountValueController.text = (coupon.discountValue / 100).toStringAsFixed(2);
    }

    // Popula as regras
    _isForFirstOrder = coupon.isForFirstOrder;
    _minOrderController.text = coupon.minOrderValue != null ? (coupon.minOrderValue! / 100).toStringAsFixed(2) : '';
    _maxUsesController.text = coupon.maxUsesPerCustomer?.toString() ?? '';
    _maxUsesPerCustomerController.text = coupon.maxUsesPerCustomer?.toString() ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _maxUsesController.dispose();
    _maxUsesPerCustomerController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Constrói a lista de regras a partir dos campos do formulário
    final List<CouponRule> rules = [];
    if (_isForFirstOrder) {
      rules.add(CouponRule(ruleType: 'FIRST_ORDER', value: {}));
    }
    final minOrderValue = UtilBrasilFields.converterMoedaParaDouble(_minOrderController.text) * 100;
    if (minOrderValue > 0) {
      rules.add(CouponRule(ruleType: 'MIN_SUBTOTAL', value: {'value': minOrderValue.toInt()}));
    }
    final maxUses = int.tryParse(_maxUsesController.text);
    if (maxUses != null && maxUses > 0) {
      rules.add(CouponRule(ruleType: 'MAX_USES_TOTAL', value: {'limit': maxUses}));
    }
    final maxUsesPerCustomer = int.tryParse(_maxUsesPerCustomerController.text);
    if (maxUsesPerCustomer != null && maxUsesPerCustomer > 0) {
      rules.add(CouponRule(ruleType: 'MAX_USES_PER_CUSTOMER', value: {'limit': maxUsesPerCustomer}));
    }
// Constrói o objeto Coupon para salvar
    final couponToSave = Coupon(
      id: widget.id,
      code: _codeController.text.toUpperCase(),
      description: _descriptionController.text,
      discountType: _discountType,
      // ✅ CORREÇÃO AQUI
      discountValue: _discountType == 'PERCENTAGE'
          ? (int.tryParse(_discountValueController.text) ?? 0).toDouble() // Converte para double
          : (UtilBrasilFields.converterMoedaParaDouble(_discountValueController.text) * 100), // Já é double

      maxDiscountAmount: (UtilBrasilFields.converterMoedaParaDouble(_maxDiscountController.text) * 100).round(),
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
              : 'Ocorreu um erro desconhecido.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        },
            (savedCoupon) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cupom salvo com sucesso!'), backgroundColor: Colors.green));
          context.pop(true); // Retorna 'true' para indicar sucesso
        },
      );
    }
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

        mobileBuilder: (BuildContext context, BoxConstraints constraints) { return  _buildMobileLayout(title); },
      //  tabletBuilder: (BuildContext context, BoxConstraints constraints) { return  _buildDesktopLayout(title);   },
        desktopBuilder: (BuildContext context, BoxConstraints constraints) {return _buildDesktopLayout(title);  },
      ),
    );
  }

  Widget _buildMobileLayout(String title) {
    return Column(
      children: [
        AppBar(title: Text(title)),
        Expanded(
          child: _CouponForm(
            formKey: _formKey,
            // Passa os controllers e valores para o formulário
            codeController: _codeController,
            descriptionController: _descriptionController,
            discountType: _discountType,
            discountValueController: _discountValueController,
            maxDiscountController: _maxDiscountController,
            minOrderController: _minOrderController,
            maxUsesController: _maxUsesController,
            maxUsesPerCustomerController: _maxUsesPerCustomerController,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
            isForFirstOrder: _isForFirstOrder,
            onStateChanged: (updates) => setState(() => _applyUpdates(updates)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppPrimaryButton(label: 'Salvar', onPressed: _onSave),
        )
      ],
    );
  }

  Widget _buildDesktopLayout(String title) {
    return Column(
      children: [
        FixedHeader(
          title: title,
          actions: [
            AppPrimaryButton(label: 'Salvar', onPressed: _onSave),
          ],
        ),
        Expanded(
          child: _CouponForm(
            formKey: _formKey,
            // Passa os mesmos controllers e valores
            codeController: _codeController,
            descriptionController: _descriptionController,
            discountType: _discountType,
            discountValueController: _discountValueController,
            maxDiscountController: _maxDiscountController,
            minOrderController: _minOrderController,
            maxUsesController: _maxUsesController,
            maxUsesPerCustomerController: _maxUsesPerCustomerController,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
            isForFirstOrder: _isForFirstOrder,
            onStateChanged: (updates) => setState(() => _applyUpdates(updates)),
          ),
        ),
      ],
    );
  }

  void _applyUpdates(Map<String, dynamic> updates) {
    if(updates.containsKey('discountType')) _discountType = updates['discountType'];
    if(updates.containsKey('startDate')) _startDate = updates['startDate'];
    if(updates.containsKey('endDate')) _endDate = updates['endDate'];
    if(updates.containsKey('isActive')) _isActive = updates['isActive'];
    if(updates.containsKey('isForFirstOrder')) _isForFirstOrder = updates['isForFirstOrder'];
  }
}

// ✅ NOVO WIDGET REUTILIZÁVEL PARA O FORMULÁRIO
class _CouponForm extends StatelessWidget {
  const _CouponForm({
    required this.formKey,
    required this.codeController,
    required this.descriptionController,
    required this.discountType,
    required this.discountValueController,
    required this.maxDiscountController,
    required this.minOrderController,
    required this.maxUsesController,
    required this.maxUsesPerCustomerController,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isForFirstOrder,
    required this.onStateChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final String discountType;
  final TextEditingController discountValueController;
  final TextEditingController maxDiscountController;
  final TextEditingController minOrderController;
  final TextEditingController maxUsesController;
  final TextEditingController maxUsesPerCustomerController;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isForFirstOrder;
  final ValueChanged<Map<String, dynamic>> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Informações Básicas
          _buildSectionTitle('Informações Básicas'),
          AppTextField(controller: codeController, title: 'Código', hint: 'EX: BEMVINDO10', validator: (v) => v!.isEmpty ? 'Obrigatório' : null, formatters: [UpperCaseTextFormatter()],),
          const SizedBox(height: 16),
          AppTextField(controller: descriptionController, title: 'Descrição', hint: 'Ex: Cupom de 10% para novos clientes', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
          const SizedBox(height: 16),
          AppDateTimeFormField(title: 'Data de Início', initialValue: startDate, onChanged: (date) => onStateChanged({'startDate': date})),
          const SizedBox(height: 16),
          AppDateTimeFormField(title: 'Data de Fim', initialValue: endDate, onChanged: (date) => onStateChanged({'endDate': date})),
          const SizedBox(height: 32),

          // Ação do Cupom
          _buildSectionTitle('Ação do Cupom'),
          DropdownButtonFormField<String>(
            value: discountType,
            decoration: const InputDecoration(labelText: 'Tipo de Desconto'),
            items: [
              const DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentual (%)')),
              DropdownMenuItem(value: 'FIXED_AMOUNT', child: Text('Valor Fixo (R\$)')),
              const DropdownMenuItem(value: 'FREE_DELIVERY', child: Text('Frete Grátis')),
            ],
            onChanged: (value) {
              if (value != null) {
                discountValueController.clear();
                onStateChanged({'discountType': value});
              }
            },
          ),
          const SizedBox(height: 16),
          if (discountType != 'FREE_DELIVERY')
            AppTextField(
              controller: discountValueController,
              title: discountType == 'PERCENTAGE' ? 'Percentual (%)' : 'Valor do Desconto (R\$)',
              hint: discountType == 'PERCENTAGE' ? 'Ex: 15' : 'Ex: 10,00',
              keyboardType: TextInputType.number,
              formatters: discountType == 'PERCENTAGE'
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
            ),
          if (discountType == 'PERCENTAGE') ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: maxDiscountController,
              title: 'Valor Máximo do Desconto (R\$) (Opcional)',
              hint: 'Ex: 20,00',
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
            ),
          ],
          const SizedBox(height: 32),

          // Regras e Condições
          _buildSectionTitle('Regras e Condições'),
          AppTextField(controller: minOrderController, title: 'Pedido Mínimo (R\$) (Opcional)', hint: 'Ex: 50,00', keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)]),
          const SizedBox(height: 16),
          AppTextField(controller: maxUsesController, title: 'Limite de Usos Totais (Opcional)', hint: 'Ex: 1000', keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 16),
          AppTextField(controller: maxUsesPerCustomerController, title: 'Limite de Usos por Cliente (Opcional)', hint: 'Ex: 1', keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// Helper para formatar o código do cupom em maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}