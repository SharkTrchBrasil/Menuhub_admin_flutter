import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/cubit/create_complement_cubit.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/create_complement_panel.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';

class EditableComplementCard extends StatefulWidget {
  final VariantOption complement;
  final int index;

  const EditableComplementCard({
    super.key,
    required this.complement,
    required this.index,
  });

  @override
  State<EditableComplementCard> createState() => _EditableComplementCardState();
}

class _EditableComplementCardState extends State<EditableComplementCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    final complement = widget.complement;
    _nameController = TextEditingController(text: complement.resolvedName);
    final priceString = UtilBrasilFields.obterReal((complement.price_override ?? 0) / 100);
    _priceController = TextEditingController(text: priceString);
    _pdvController = TextEditingController(text: complement.pos_code ?? '');
  }

  @override
  void didUpdateWidget(covariant EditableComplementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.complement != oldWidget.complement) {
      final complement = widget.complement;
      _nameController.text = complement.resolvedName;
      final priceString = UtilBrasilFields.obterReal((complement.price_override ?? 0) / 100);
      _priceController.text = priceString;
      _pdvController.text = complement.pos_code ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  void _updateCubit(VariantOption updatedComplement) {
    context.read<CreateComplementGroupCubit>().updateComplementOption(widget.index, updatedComplement);
  }

  Future<void> _openEditPanel() async {
    final updatedOption = await showModalBottomSheet<VariantOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateComplementPanel(initialData: widget.complement),
    );

    if (updatedOption != null && mounted) {
      _updateCubit(updatedOption);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Pega a referência do cubit que gerencia a lista de complementos
    final listManagerCubit = context.read<CreateComplementGroupCubit>();


    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com imagem, nome e botão de deletar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ✅ --- INÍCIO DA INTEGRAÇÃO CORRIGIDA --- ✅

              // 1. Usamos o AppImageFormField diretamente aqui
              SizedBox(
                width: 98, // Define um tamanho fixo para o seletor
                height: 78,
                child: AppImageFormField(
                  // 2. Removemos o título para um visual mais limpo
                  title: "",
                  initialValue: widget.complement.image,
                  // 3. O onChanged agora atualiza o complemento na lista
                  onChanged: (newImage) {
                    final updatedComplement = widget.complement.copyWith(
                      image: newImage ?? const ImageModel(),
                    );
                    // 4. Chama o método do cubit da lista para atualizar este item específico
                    listManagerCubit.updateComplementOption(
                      widget.index,
                      updatedComplement,
                    );
                  },
                ),
              ),

              // ✅ --- FIM DA INTEGRAÇÃO CORRIGIDA --- ✅

              const SizedBox(width: 16),

              // Nome do produto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.complement.resolvedName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF151515),
                            ),
                          ),
                        ),


                        Tooltip(
                          message: "Editar opção",
                          child: IconButton(
                            icon: const Icon(Icons.mode_edit_outline_outlined, size: 20, color: Colors.black),
                            onPressed: _openEditPanel,




                          ),
                        ),
                        Tooltip(
                          message: "Remover do grupo",
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            onPressed: () => context.read<CreateComplementGroupCubit>().removeComplementOption(widget.complement),
                          ),
                        ),



                      ],
                    ),



                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Seção de preço e código PDV (estilo iFood)
          Row(
            children: [


              // Campo de preço (estilo iFood)
              Expanded(
                child: Row(
                  children: [

                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0,00",
                          hintStyle: TextStyle(color: Color(0xFF666666)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF151515),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CentavosInputFormatter()
                        ],
                        onChanged: (newPrice) {
                          final cents = UtilBrasilFields.converterMoedaParaDouble(newPrice) * 100;
                          _updateCubit(widget.complement.copyWith(price_override: cents.toInt()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Campo de código PDV (estilo iFood)
              Expanded(
                child: TextFormField(
                  controller: _pdvController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Código PDV",
                    hintStyle: TextStyle(color: Color(0xFF666666)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF151515),
                  ),
                  onChanged: (newCode) {
                    _updateCubit(widget.complement.copyWith(pos_code: newCode));
                  },
                ),
              ),
            ],
          ),




        ],
      ),
    );
  }
}

