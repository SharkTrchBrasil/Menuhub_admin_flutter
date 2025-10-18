// lib/pages/products/widgets/universal_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

/// ✅ Widget de filtro universal que funciona em todas as abas
class UniversalFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged; // ✅ NOVO: Callback quando texto muda
  final Widget? customFilterWidget; // Para dropdown de categorias, ordenação, etc.
  final List<Widget>? desktopActions; // Botões extras no desktop
  final VoidCallback? onMobileFilterTap; // Para abrir bottom sheet no mobile
  final bool showMobileFilterButton;

  const UniversalFilterBar({
    super.key,
    required this.searchController,
    required this.searchHint,
    this.onSearchChanged, // ✅ NOVO
    this.customFilterWidget,
    this.desktopActions,
    this.onMobileFilterTap,
    this.showMobileFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric( vertical: 12),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        if (showMobileFilterButton && onMobileFilterTap != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMobileFilterTap,
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Filtrar',
            style: IconButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildSearchField()),
        if (customFilterWidget != null) ...[
          const SizedBox(width: 16),
          Expanded(flex: 2, child: customFilterWidget!),
        ],
        const Spacer(),
        if (desktopActions != null) ...desktopActions!,
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged, // ✅ CORREÇÃO: Chama callback quando texto muda
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}