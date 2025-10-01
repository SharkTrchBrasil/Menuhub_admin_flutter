import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signature/signature.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup-state.dart';

class ContractStep extends StatefulWidget {
  const ContractStep({super.key});

  @override
  State<ContractStep> createState() => ContractStepState();
}

class ContractStepState extends State<ContractStep> {
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool isSigned = false;

  @override
  void initState() {
    super.initState();
    signatureController.addListener(() {
      if (signatureController.isNotEmpty && !isSigned) {
        setState(() {
          isSigned = true;
        });
      }
    });
  }

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<StoreSetupCubit>().state;

    return  SingleChildScrollView(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('I. ACEITAÇÃO DOS TERMOS'),
          _buildParagraph(
            'Ao utilizar os serviços da MenuHub, você declara que leu, compreendeu e concorda com estes Termos de Uso. A continuidade do uso do serviço implica na aceitação integral destas condições.',
          ),

          _buildSectionTitle('II. SERVIÇO PRESTADO'),
          _buildParagraph(
            '2.1. A MenuHub fornece exclusivamente serviço de cardápio digital para estabelecimentos comerciais.\n\n'
                '2.2. O serviço não inclui hospedagem de sites, infraestrutura de rede, APIs de terceiros ou quaisquer outros serviços externos.',
          ),

          _buildSectionTitle('III. ISENÇÃO DE RESPONSABILIDADE POR TERCEIROS'),
          _buildParagraph(
            '3.1. A MenuHub não se responsabiliza por:\n\n'
                'a) Falhas em serviços de hospedagem de terceiros\n\n'
                'b) Problemas em APIs externas integradas ao sistema\n\n'
                'c) Instabilidade em serviços de internet ou infraestrutura\n\n'
                'd) Qualquer problema originado em serviços não gerenciados diretamente pela MenuHub',
          ),

          _buildSectionTitle('IV. REAJUSTES E ALTERAÇÕES'),
          _buildParagraph(
            '4.1. A MenuHub poderá reajustar anualmente os valores do plano único contratado.\n\n'
                '4.2. As regras e condições do plano único podem ser alteradas a qualquer momento, com aviso prévio aos usuários.\n\n'
                '4.3. O uso continuado do serviço após alterações implica em aceitação das novas condições.',
          ),

          _buildSectionTitle('V. RESPONSABILIDADES DO LOJISTA'),
          _buildParagraph(
            '5.1. Todas as informações do cardápio são de inteira responsabilidade do lojista, incluindo:\n\n'
                'a) Preços e descrições dos produtos\n\n'
                'b) Imagens e direitos autorais\n\n'
                'c) Disponibilidade e estoque\n\n'
                'd) Informações nutricionais e alergênicos\n\n'
                'e) Conformidade com legislação sanitária e consumerista',
          ),

          _buildSectionTitle('VI. INATIVIDADE'),
          _buildParagraph(
            '6.1. Contas inativas por período superior a 90 (noventa) dias poderão ser desativadas permanentemente.\n\n'
                '6.2. Considera-se inatividade a ausência total de acesso ao sistema e atualizações no cardápio.\n\n'
                '6.3. A desativação resultará na perda irreversível de todos os dados cadastrados.',
          ),

          _buildSectionTitle('VII. LIMITAÇÃO DE RESPONSABILIDADE'),
          _buildParagraph(
            '7.1. A MenuHub não será responsável por:\n\n'
                'a) Danos diretos ou indiretos decorrentes do uso do serviço\n\n'
                'b) Perdas financeiras oriundas de indisponibilidade temporária\n\n'
                'c) Problemas relacionados a equipamentos ou conexão do usuário\n\n'
                'd. Ações judiciais movidas contra o lojista por informações incorretas no cardápio',
          ),

          _buildSectionTitle('VIII. PROPRIEDADE INTELECTUAL'),
          _buildParagraph(
            '8.1. O lojista garante possuir direitos sobre todo o conteúdo por ele inserido no sistema.\n\n'
                '8.2. A MenuHub não se responsabiliza por violações de direitos autorais cometidas pelo lojista.',
          ),

          _buildSectionTitle('IX. RESCISÃO'),
          _buildParagraph(
            '9.1. O lojista pode cancelar o serviço a qualquer momento.\n\n'
                '9.2. A MenuHub pode suspender ou cancelar contas que violem estes termos.\n\n'
                '9.3. O cancelamento resultará na exclusão definitiva de todos os dados.',
          ),

          _buildSectionTitle('X. ACEITAÇÃO'),
          _buildParagraph(
            'Ao clicar em "Aceitar e Continuar", você declara:\n\n'
                'a) Ter lido e compreendido todos os termos acima\n\n'
                'b) Concordar integralmente com todas as condições\n\n'
                'c) Isentar a MenuHub de responsabilidades conforme estabelecido\n\n'
                'd) Assumir total responsabilidade pelas informações do cardápio',
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, textAlign: TextAlign.justify),
    );
  }

  Widget _buildIndentedText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(text),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Plano', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Mensalidade', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Comissão', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Taxa Pagto', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Repasse', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String plano,
    required String mensalidade,
    required String comissao,
    required String taxaPagamento,
    required String repasse,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(plano)),
          Expanded(child: Text(mensalidade)),
          Expanded(child: Text(comissao)),
          Expanded(child: Text(taxaPagamento)),
          Expanded(child: Text(repasse)),
        ],
      ),
    );
  }
}