import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

import '../../../models/prodcut_category_links.dart';
import '../../../widgets/ds_primary_button.dart';

// -------------------------------------------------------------------
// WIDGET PRINCIPAL (QUASE INALTERADO)
// -------------------------------------------------------------------
class ProductCategoriesManager extends StatelessWidget {
  final List<ProductCategoryLink> categoryLinks;
  final VoidCallback onAddCategory;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final ValueChanged<ProductCategoryLink> onRemoveLink;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const ProductCategoriesManager({
    super.key,
    required this.categoryLinks,
    required this.onAddCategory,
    required this.onUpdateLink,
    required this.onRemoveLink,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        margin: const EdgeInsets.only(top: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 1. CONTAGEM REAL DAS CATEGORIAS
                _buildHeader(),
                const SizedBox(height: 16),

                if (categoryLinks.isEmpty)
                  _buildEmptyState()
                else
                // A lista agora usa o novo widget com estado para cada item
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryLinks.length,
                    itemBuilder: (context, index) {
                      final link = categoryLinks[index];
                      return _CategoryLinkItem(
                        key: ValueKey(link.categoryId), // Chave para performance
                        link: link,
                        onUpdateLink: onUpdateLink,
                        onRemoveLink: onRemoveLink,
                        onTogglePause: onTogglePause,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                  ),

                const SizedBox(height: 24),
                // Botão alinhado à direita
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child:  DsButton(
                      onPressed: onAddCategory,
                      icon: Icons.add_outlined,
                      label: "Adicionar à categoria",
                      style: DsButtonStyle.secondary,


                    )),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 1. CONTAGEM REAL DAS CATEGORIAS
  // O cabeçalho agora mostra a contagem real e não precisa mais
  // de lógica mobile/desktop, pois o layout é simples.
  Widget _buildHeader() {
    return Text(
      "Categorias (${categoryLinks.length})", // Usa o tamanho da lista
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      // ... (sem alterações no empty state)
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Este produto precisa estar em pelo menos uma categoria.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}


// -------------------------------------------------------------------
// NOVO WIDGET COM ESTADO PARA CADA ITEM DA LISTA
// -------------------------------------------------------------------
class _CategoryLinkItem extends StatefulWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final ValueChanged<ProductCategoryLink> onRemoveLink;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const _CategoryLinkItem({
    super.key,
    required this.link,
    required this.onUpdateLink,
    required this.onRemoveLink,
    required this.onTogglePause,
  });

  @override
  State<_CategoryLinkItem> createState() => _CategoryLinkItemState();
}

class _CategoryLinkItemState extends State<_CategoryLinkItem> {
  // Controllers para gerenciar o texto dos campos
  late final TextEditingController _priceController;
  late final TextEditingController _promoPriceController;
  late final TextEditingController _pdvController;

  // Estado local para controlar a visibilidade do campo de promoção
  bool _isPromoActive = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
        text: UtilBrasilFields.obterReal(widget.link.price / 100));
    _promoPriceController = TextEditingController(
        text: widget.link.promotionalPrice != null
            ? UtilBrasilFields.obterReal(widget.link.promotionalPrice! / 100)
            : '');
    _pdvController = TextEditingController(text: widget.link.posCode);

    // Define o estado inicial da promoção baseado no link recebido
    _isPromoActive = widget.link.isOnPromotion;
  }

  // Limpa os controllers para evitar vazamento de memória
  @override
  void dispose() {
    _priceController.dispose();
    _promoPriceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  void _togglePromotion() {
    setState(() {
      _isPromoActive = !_isPromoActive;

      // Se desativou a promoção, limpa o preço e notifica o Cubit/Bloc
      if (!_isPromoActive) {
        _promoPriceController.clear();
        widget.onUpdateLink(widget.link.copyWith(
          isOnPromotion: false,
          promotionalPrice: null, // Limpa o valor
        ));
      } else {
        // Apenas ativa a flag. O valor será enviado no onChanged do campo.
        widget.onUpdateLink(widget.link.copyWith(isOnPromotion: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // A lógica de layout que estava antes foi movida para cá.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(),
          const SizedBox(height: 16),
          _buildChannelAndPriceSection(),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.link.category?.name ?? 'Carregando...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 18),
              onPressed: () { /* Lógica futura */ },
              color: Colors.grey.shade600,
              tooltip: "Adicionar disponibilidade",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => widget.onRemoveLink(widget.link),
              color: Colors.grey.shade600,
              tooltip: "Remover produto da categoria",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelAndPriceSection() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.shopping_bag, size: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            const Text("Cardápio Digital", style: TextStyle(fontSize: 14)),
            const Spacer(),
            IconButton(
              icon: Icon(
                widget.link.isAvailable ? Icons.pause : Icons.play_arrow,
                size: 18,
              ),
              onPressed: () => widget.onTogglePause(widget.link),
              color: Colors.grey.shade600,
              tooltip: widget.link.isAvailable ? "Pausar produto" : "Ativar produto",
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Layout dos campos de preço e PDV
        isMobile ? _buildMobileFields() : _buildDesktopFields(),
      ],
    );
  }

  // Layout para Desktop (lado a lado)
  Widget _buildDesktopFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPriceField()),
        const SizedBox(width: 12),
        // O campo de promoção aparece aqui se ativo
        if (_isPromoActive) ...[
          Expanded(child: _buildPromoPriceField()),
          const SizedBox(width: 12),
        ],
        Expanded(child: _buildPdvField(widget.link)),
      ],
    );
  }

  // Layout para Mobile (empilhado)
  Widget _buildMobileFields() {
    return Column(
      children: [
        _buildPriceField(),
        const SizedBox(height: 12),
        // O campo de promoção aparece aqui se ativo
        if (_isPromoActive) ...[
          _buildPromoPriceField(),
          const SizedBox(height: 12),
        ],
        _buildPdvField(widget.link),
      ],
    );
  }


  // Widget para o campo de Preço Principal
  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Preço',

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        // ✅ 2. ÍCONE DE PROMOÇÃO ATIVA A LÓGICA
        suffixIcon: IconButton(
          icon: Icon(Icons.discount,
            size: 18,
            color: _isPromoActive ? Theme.of(context).primaryColor : Colors.grey.shade600,
          ),
          onPressed: _togglePromotion,
          tooltip: "Aplicar desconto",
        ),
      ),
      style: const TextStyle(fontSize: 14),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CentavosInputFormatter()
      ],
      onChanged: (value) {
        // ✅ CORREÇÃO APLICADA AQUI
        // Se o campo estiver vazio, considera o preço como 0.
        final priceInCents = value.isEmpty
            ? 0
            : (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
        widget.onUpdateLink(widget.link.copyWith(price: priceInCents));
      },
    );
  }

  // ✅ 2. NOVO WIDGET PARA O CAMPO DE PREÇO PROMOCIONAL
  Widget _buildPromoPriceField() {
    return TextFormField(
      controller: _promoPriceController,
      decoration: InputDecoration(
        labelText: 'Preço Promocional',
        prefixText: 'R\$ ',
        // Borda destacada para indicar que é um campo especial
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CentavosInputFormatter()
      ],
      onChanged: (value) {
        // ✅ CORREÇÃO APLICADA AQUI
        // Se o campo estiver vazio, considera o preço promocional como nulo.
        final promoPriceInCents = value.isEmpty
            ? null
            : (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
        widget.onUpdateLink(widget.link.copyWith(promotionalPrice: promoPriceInCents));
      },
    );
  }

  // Widget para o campo de Código PDV
  Widget _buildPdvField(ProductCategoryLink link) {
    return TextFormField(
      controller: _pdvController,
      decoration: InputDecoration(
        labelText: 'Código PDV',
        hintText: 'XGAHTQ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) => widget.onUpdateLink(link.copyWith(posCode: value)),
    );
  }
}