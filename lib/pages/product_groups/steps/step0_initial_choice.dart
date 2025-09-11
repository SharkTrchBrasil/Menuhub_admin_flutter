import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';




// Enum para controlar a opção selecionada localmente nesta tela
enum AddGroupOption { create, copy }

class Step0InitialChoice extends StatefulWidget {
  const Step0InitialChoice({super.key});

  @override
  State<Step0InitialChoice> createState() => _Step0InitialChoiceState();
}

class _Step0InitialChoiceState extends State<Step0InitialChoice> {
  // Estado local para controlar qual radio button está selecionado
  AddGroupOption _selectedOption = AddGroupOption.create;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(

        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header fixo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: const Text(
                    "Grupo de complementos",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "Crie um novo grupo de complementos ou copie um que já existe no seu cardápio.",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 56),


              Expanded(
                child: SingleChildScrollView(

                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [



                      _buildOptionCard(
                        title: "Criar novo grupo",
                        subtitle: "Você cria um grupo novo, definindo informações gerais e quais serão os complementos.",
                        icon: Icons.add_circle_outline,
                        value: AddGroupOption.create,
                      ),
                      const SizedBox(height: 16),
                      _buildOptionCard(
                        title: "Copiar grupo",
                        subtitle: "Você reaproveita um grupo que já possui em seu cardápio e a gestão fica mais fácil!",
                        icon: Icons.link_outlined,
                        value: AddGroupOption.copy,
                        tag: _buildTag(),
                      ),
                    ],
                  ),
                ),
              ),

            WizardFooter(
              showBackButton: false,



                onContinue:   () {
      final cubit = context.read<CreateComplementGroupCubit>();
      final bool isCopyFlow = _selectedOption == AddGroupOption.copy;
      cubit.startFlow(isCopyFlow);
      },

            ),


          ],
        ),
      ),
    );
  }








  /// Widget auxiliar para criar o Tag "mais prático"
  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "mais prático",
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Widget auxiliar e reutilizável para criar os cartões de opção
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required AddGroupOption value,
    Widget? tag,
  }) {
    final bool isSelected = _selectedOption == value;

    return InkWell(
      onTap: () => setState(() => _selectedOption = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (ResponsiveBuilder.isDesktop(context)) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        if (tag != null) tag,
                      ],
                    ),
                  ],
                  if (ResponsiveBuilder.isMobile(context))
                    Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!ResponsiveBuilder.isDesktop(context) && tag != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: tag!,
                    ),
                ],
              ),
            ),

            Radio<AddGroupOption>(
              value: value,
              groupValue: _selectedOption,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedOption = newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}