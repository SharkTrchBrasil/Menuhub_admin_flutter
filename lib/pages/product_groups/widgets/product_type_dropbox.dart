import 'package:flutter/material.dart';

class ProductTypeDropdown extends StatefulWidget {
  final bool isPrepared;
  final Function(bool) onChanged;

  const ProductTypeDropdown({
    Key? key,
    required this.isPrepared,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ProductTypeDropdownState createState() => _ProductTypeDropdownState();
}

class _ProductTypeDropdownState extends State<ProductTypeDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipo de complemento",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF151515), // ifdl-text-color-primary
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFEBEBEB), // ifdl-outline-color-default
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8), // ifdl-border-radius-md
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: widget.isPrepared,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF151515), // ifdl-text-color-primary
                fontFamily: 'iFood RC Textos, Helvetica, Arial, sans-serif',
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF666666), // ifdl-text-color-secondary
                ),
              ),
              items: const [
                DropdownMenuItem<bool>(
                  value: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Preparado"),
                  ),
                ),
                DropdownMenuItem<bool>(
                  value: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Industrializado"),
                  ),
                ),
              ],
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  widget.onChanged(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}