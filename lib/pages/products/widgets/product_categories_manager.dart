import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

import '../../../models/products/prodcut_category_links.dart';
import '../../../widgets/ds_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

import '../../../models/products/prodcut_category_links.dart';
import '../../../widgets/ds_primary_button.dart';
// WIDGET PRINCIPAL - ATUALIZADO
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

import '../../../models/products/prodcut_category_links.dart';
import '../../../widgets/ds_primary_button.dart';

// -------------------------------------------------------------------
// WIDGET PRINCIPAL - ATUALIZADO
// -------------------------------------------------------------------
class ProductCategoriesManager extends StatefulWidget {
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
  State<ProductCategoriesManager> createState() => _ProductCategoriesManagerState();
}

class _ProductCategoriesManagerState extends State<ProductCategoriesManager> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // SE NÃO HÁ CATEGORIAS, MOSTRA APENAS O ESTADO VAZIO
    if (widget.categoryLinks.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    // SE HÁ CATEGORIAS, MOSTRA O WIDGET NORMAL
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: isMobile
                ? _buildMobileHeader() // Container simples para mobile
                : _buildDesktopExpansionTile(), // ExpansionTile para desktop
          ),
        ),
      ],
    );
  }

  // ESTADO VAZIO (SUBSTITUI O WIDGET PRINCIPAL)
  Widget _buildEmptyState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
      child: Container(
        margin: const EdgeInsets.only(top: 24),

        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                "Disponível em:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF151515),
                ),
              ),
              const SizedBox(height: 8),

              // Descrição
              const Text(
                "Adicione o produto em uma ou mais categorias, defina preço, código PDV.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Card de estado vazio
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36), // ✅ Aumentei a altura com mais padding vertical
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFFEBEBEB), // ✅ Cor cinza mais suave
                    width: 1.5, // ✅ Largura da borda

                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mensagem de estado vazio
                    const Text(
                      "Este produto ainda não foi adicionado a uma categoria",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center, // ✅ Centraliza o texto
                    ),
                    const SizedBox(height: 36),

                    // Botão de adicionar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAddButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER SIMPLES PARA MOBILE (sem ExpansionTile)
  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e contador
          Text(
            "Categorias (${widget.categoryLinks.length})",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
          const SizedBox(height: 18),

          // Botão adicionar
          Row(
            children: [
              _buildAddButton(),
            ],
          ),
          const SizedBox(height: 16),

          // Conteúdo das categorias
          _buildMobileLayout(),
        ],
      ),
    );
  }

  // EXPANSION TILE PARA DESKTOP
  Widget _buildDesktopExpansionTile() {
    return ExpansionTile(
      initiallyExpanded: true,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      collapsedIconColor: const Color(0xFF3E3E3E),
      iconColor: const Color(0xFF3E3E3E),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Categorias (${widget.categoryLinks.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    color: Color(0xFF151515),
                  ),
                ),
                if (_isExpanded)
                  const Text(
                    "Este produto está nas categorias abaixo.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
              ],
            ),
          ),
          _buildAddButton(),
        ],
      ),
      children: [
        _buildContent(false), // false = não é mobile
      ],
    );
  }

  Widget _buildContent(bool isMobile) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile)
            _buildMobileLayout()
          else
            _buildDesktopLayout(context),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Flexible(
      child: DsButton(
        onPressed: widget.onAddCategory,
        icon: Icons.add_outlined,
        label: "Adicionar à categoria",
        style: DsButtonStyle.secondary,
        maxWidth: 350,
        constrained: true,
      ),
    );
  }

  // ... (o restante dos métodos permanece igual: _buildDesktopLayout, _buildMobileLayout, etc.)
  Widget _buildDesktopLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Definição de colunas responsivas baseadas na largura disponível
        final columnWidths = _getResponsiveColumnWidths(availableWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: availableWidth,
              maxWidth: availableWidth,
            ),
            child: Table(
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.5,
                ),
              ),
              children: [
                // Cabeçalho da tabela
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  children: [
                    _buildTableHeader("Categoria"),
                   // _buildTableHeader("Canal de venda"),
                    _buildTableHeader("Preço"),
                    _buildTableHeader("Código PDV"),
                    _buildTableHeader("Ações"),
                  ],
                ),
                // Linhas da tabela
                for (final link in widget.categoryLinks)
                  TableRow(
                    children: [
                      _buildCategoryCell(link),
                   //   _buildChannelCell(link),
                      _buildPriceCell(link),
                      _buildPdvCell(link),
                      _buildActionsCell(link),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<int, TableColumnWidth> _getResponsiveColumnWidths(double availableWidth) {
    if (availableWidth < 600) {
      return {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FixedColumnWidth(60),
      };
    } else if (availableWidth < 800) {
      return {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FixedColumnWidth(80),
      };
    } else {
      return {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FixedColumnWidth(100),
      };
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final link in widget.categoryLinks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: _MobileCategoryItem(
              link: link,
              onUpdateLink: widget.onUpdateLink,
              onRemoveLink: widget.onRemoveLink,
              onTogglePause: widget.onTogglePause,
            ),
          ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCategoryCell(ProductCategoryLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link.category?.name ?? 'Carregando...',
              style: const TextStyle(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.calendar_today, size: 16),
          //   onPressed: () {},
          //   tooltip: "Adicionar disponibilidade",
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(),
          // ),
        ],
      ),
    );
  }

  Widget _buildChannelCell(ProductCategoryLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.shopping_bag,
              size: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Cardápio Digital",
              style: TextStyle(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell(ProductCategoryLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: _PriceField(
        link: link,
        onUpdateLink: widget.onUpdateLink,
      ),
    );
  }

  Widget _buildPdvCell(ProductCategoryLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: _PdvField(
        link: link,
        onUpdateLink: widget.onUpdateLink,
      ),
    );
  }

  Widget _buildActionsCell(ProductCategoryLink link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        width: 60,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onRemoveLink(link),
            child: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}

// ... (o restante dos widgets _MobileCategoryItem, _PriceField e _PdvField permanecem iguais)
// -------------------------------------------------------------------
// WIDGET PARA ITEM MOBILE
// -------------------------------------------------------------------
class _MobileCategoryItem extends StatelessWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final ValueChanged<ProductCategoryLink> onRemoveLink;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const _MobileCategoryItem({
    required this.link,
    required this.onUpdateLink,
    required this.onRemoveLink,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header do card mobile
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    link.category?.name ?? 'Carregando...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF151515),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    onPressed: () {},
                    color: const Color(0xFF666666),
                    tooltip: "Adicionar disponibilidade",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onRemoveLink(link),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Canal de venda
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Cardápio Digital",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF151515),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Campos de preço e PDV
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preço",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _PriceField(
              link: link,
              onUpdateLink: onUpdateLink,
              isMobile: true,
            ),
            const SizedBox(height: 12),
            const Text(
              "Código PDV",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _PdvField(
              link: link,
              onUpdateLink: onUpdateLink,
              isMobile: true,
            ),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// WIDGETS PARA CAMPOS DE PREÇO E PDV
// -------------------------------------------------------------------
class _PriceField extends StatefulWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final bool isMobile;

  const _PriceField({
    required this.link,
    required this.onUpdateLink,
    this.isMobile = false,
  });

  @override
  State<_PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<_PriceField> {
  late final TextEditingController _priceController;
  bool _isPromoActive = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: UtilBrasilFields.obterReal(widget.link.price / 100),
    );
    _isPromoActive = widget.link.isOnPromotion;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isMobile ? double.infinity : null,
      child: TextFormField(
        controller: _priceController,
        decoration: InputDecoration(
          prefixText: 'R\$ ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0083CC)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _togglePromotion,
              child: Icon(
                Icons.discount,
                size: 18,
                color: _isPromoActive ? Theme.of(context).primaryColor : const Color(0xFF666666),
              ),
            ),
          ),
        ),
        style: const TextStyle(fontSize: 14),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CentavosInputFormatter()
        ],
        onChanged: (value) {
          final priceInCents = value.isEmpty
              ? 0
              : (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
          widget.onUpdateLink(widget.link.copyWith(price: priceInCents));
        },
      ),
    );
  }

  void _togglePromotion() {
    setState(() {
      _isPromoActive = !_isPromoActive;
      if (!_isPromoActive) {
        widget.onUpdateLink(widget.link.copyWith(
          isOnPromotion: false,
          promotionalPrice: null,
        ));
      } else {
        widget.onUpdateLink(widget.link.copyWith(isOnPromotion: true));
      }
    });
  }
}

class _PdvField extends StatefulWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final bool isMobile;

  const _PdvField({
    required this.link,
    required this.onUpdateLink,
    this.isMobile = false,
  });

  @override
  State<_PdvField> createState() => _PdvFieldState();
}

class _PdvFieldState extends State<_PdvField> {
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _pdvController = TextEditingController(text: widget.link.posCode);
  }

  @override
  void dispose() {
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isMobile ? double.infinity : null,
      child: TextFormField(
        controller: _pdvController,
        decoration: InputDecoration(
          hintText: 'XGAHTQ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0083CC)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: (value) => widget.onUpdateLink(widget.link.copyWith(posCode: value)),
      ),
    );
  }
}