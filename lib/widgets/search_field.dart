import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


import '../ConstData/typography.dart';




class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchField({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//  notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Expanded(
      child: TextField(
        onChanged: onChanged,
        style: Typographyy.bodyMediumMedium.copyWith(
        //  color: notifire.getTextColor,
        ),
        decoration: InputDecoration(
          prefixIcon: SizedBox(
            height: 22,
            width: 22,
            child: Center(
              child: SvgPicture.asset(
                "assets/images/Search.svg",
                height: 20,
                width: 20,
              //  color: notifire.getTextColor,
              ),
            ),
          ),
          hintText: "Buscar...",
          hintStyle: Typographyy.bodyMediumMedium.copyWith(
          //  color: notifire.getGry500_600Color,
          ),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
           //   color: notifire.getGry700_300Color,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
            //  color: notifire.getGry700_300Color,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
          //    color: notifire.getGry700_300Color,
            ),
          ),
        ),
      ),
    );
  }
}
