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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // --- CABEÇALHO ---
        _buildSectionTitle('CONTRATO DE PRESTAÇÃO DE SERVIÇOS - MASHI DELIVERY'),
        _buildParagraph(
          'Este instrumento ("Contrato") é celebrado entre:',
        ),

        // --- I. PARTES ---
        _buildSectionTitle('I. PARTES CONTRATANTES'),
        _buildSubSectionTitle('MASHi DELIVERY LTDA'),
        _buildIndentedText('Razão Social: MASHi DELIVERY TECNOLOGIA LTDA'),
        _buildIndentedText('CNPJ: 12.345.678/0001-99'),
        _buildIndentedText('Endereço: Av. Paulista, 1000, Bela Vista'),
        _buildIndentedText('São Paulo/SP - CEP: 01310-100'),
        _buildIndentedText('E-mail: juridico@mashi.com.br'),

        const SizedBox(height: 16),
        _buildSubSectionTitle('PARCEIRO RESTAURANTE'),
        _buildIndentedText('Nome: ${state.responsibleName}'),
        _buildIndentedText('${state.taxIdType == TaxIdType.cnpj ? 'CNPJ' : 'CPF'}: ${state.taxIdType == TaxIdType.cnpj ? state.cnpj : state.cpf}'),
        _buildIndentedText('Endereço: ${state.street}, ${state.number} - ${state.neighborhood}'),
        _buildIndentedText('${state.city}/${state.uf} - CEP: ${state.cep}'),
      //  _buildIndentedText('E-mail: ${state.}'),

        // --- II. DADOS BANCÁRIOS ---
        _buildSectionTitle('II. DADOS BANCÁRIOS'),
        _buildParagraph(
          'O Parceiro deverá cadastrar no Portal Mashi os dados bancários de titularidade exclusiva do estabelecimento para recebimento dos valores. A Mashi não se responsabiliza por repasses a contas de terceiros.',
        ),

        // --- III. VIGÊNCIA ---
        _buildSectionTitle('III. VIGÊNCIA'),
        _buildParagraph(
          '3.1. Prazo inicial de 12 (doze) meses, renovável automaticamente por períodos iguais.\n\n'
              '3.2. O Parceiro poderá rescindir com aviso prévio de 30 dias.',
        ),

        // --- IV. PLANO ---
        _buildSectionTitle('IV. PLANO DE CONTRATAÇÃO'),
        _buildTableHeader(),
        _buildTableRow(
            plano: 'Básico',
            mensalidade: 'R\$ 99,00',
            comissao: '12%',
            taxaPagamento: '3,5%',
            repasse: 'D+30'
        ),
        _buildParagraph(
          '* Mensalidade isenta para faturamento mensal abaixo de R\$ 1.500,00',
        ),

        // --- V. OBRIGAÇÕES ---
        _buildSectionTitle('V. OBRIGAÇÕES DO PARCEIRO'),
        _buildParagraph(
          '5.1. Manter alvará sanitário e documentação em dia\n\n'
              '5.2. Não utilizar imagens sem direitos autorais\n\n'
              '5.3. Atualizar preços e disponibilidade no sistema\n\n'
              '5.4. Cumprir prazos de preparo informados\n\n'
              '5.5. Fornecer informações verídicas aos clientes',
        ),

        // --- VI. PROTEÇÃO DE DADOS ---
        _buildSectionTitle('VI. PROTEÇÃO DE DADOS'),
        _buildParagraph(
          '6.1. O Parceiro é responsável pelos dados de seus clientes\n\n'
              '6.2. É proibido compartilhar dados com terceiros\n\n'
              '6.3. Em caso de vazamento, notificar a Mashi em 24h\n\n'
              '6.4. Aplicam-se as políticas de privacidade disponíveis em: mashi.com.br/privacidade',
        ),

        // --- VII. REAJUSTES ---
        _buildSectionTitle('VII. REAJUSTES'),
        _buildParagraph(
          '7.1. A Mashi poderá reajustar tarifas com aviso prévio de 30 dias\n\n'
              '7.2. Aumentos superiores a 15% dão direito à rescisão sem multa',
        ),

        // --- VIII. NÃO DISCRIMINAÇÃO ---
        _buildSectionTitle('VIII. POLÍTICA DE NÃO DISCRIMINAÇÃO'),
        _buildParagraph(
          '8.1. O Parceiro se compromete a:\n\n'
              'a) Não praticar discriminação por orientação sexual, identidade de gênero, raça ou religião\n\n'
              'b) Respeitar direitos humanos em todas as interações\n\n'
              'c) Cumprir a Lei 14.532/23 (criminalização de LGBTIfobia)',
        ),

        // --- IX. IMAGENS ---
        _buildSectionTitle('IX. USO DE IMAGENS'),
        _buildParagraph(
          '9.1. O Parceiro garante possuir direitos sobre todas as imagens utilizadas\n\n'
              '9.2. A Mashi poderá utilizar imagens do estabelecimento para promoção\n\n'
              '9.3. Fotos de produtos devem refletir fielmente o item servido',
        ),

        // --- X. ASSINATURA ---
        _buildSectionTitle('X. ACEITAÇÃO'),
        _buildParagraph(
          'Ao assinar, o Parceiro declara:\n\n'
              'a) Ter lido e concordado com todos os termos\n\n'
              'b) Que as informações são verídicas\n\n'
              'c) Ciência do valor jurídico desta assinatura digital',
        ),

        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(
            controller: signatureController,
            height: 150,
            backgroundColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  signatureController.clear();
                  isSigned = false;
                });
              },
              child: const Text('Limpar Assinatura'),
            )
          ],
        )
      ],
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