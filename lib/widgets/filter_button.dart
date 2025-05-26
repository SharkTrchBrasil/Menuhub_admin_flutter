import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


import '../ConstData/typography.dart';





class FilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FilterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: const Size.fromHeight(42),
      //  backgroundColor: notifire.getBgColor,
      //  side: BorderSide(color: notifire.getGry700_300Color),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/Filter.svg",
            height: 20,
            width: 20,
         //   color: notifire.getTextColor,
          ),
          const SizedBox(width: 8),
          Text(
            "Filters",
            style: Typographyy.bodyMediumExtraBold.copyWith(
           //   color: notifire.getTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
