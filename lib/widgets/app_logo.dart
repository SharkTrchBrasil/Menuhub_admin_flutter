// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';




class AppLogo extends StatefulWidget {

  final Color? logoColor;
  final Color? textColor;
  final double? size;
  const AppLogo({super.key, this.logoColor, this.textColor, this.size});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        SvgPicture.asset("assets/images/logo.png",color:widget.textColor ?? Colors.blue,width: widget.size,height: 20),
      ],
    );
  }
}
