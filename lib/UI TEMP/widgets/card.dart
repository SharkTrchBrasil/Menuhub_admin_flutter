// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../ConstData/typography.dart';
import '../../constdata/staticdata.dart';
import '../controller/dashbordecontroller.dart';

 cardss({required Color bgcolor, required String price, required Color textcolor}){
  return GetBuilder<DashBordeController>(
      builder: (dashBordeController) {
        return Stack(
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    width: 480,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      color: bgcolor,
                       image: const DecorationImage(image: AssetImage("assets/images/Group.png"),fit: BoxFit.cover)
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 390,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                "assets/images/Chips.svg",
                                height: 32,
                                width: 32,
                              ),
                              SvgPicture.asset(
                                "assets/images/Amazon.svg",
                                height: 20,
                                width: 75,
                                color: textcolor,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 95,
                          ),
                          Row(
                            children: [
                              Text("Balance", style: Typographyy.bodySmallMedium.copyWith(color: textcolor.withOpacity(0.6)),),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                onTap: () {
                                  dashBordeController.setistextishide(dashBordeController.istextishide =! dashBordeController.istextishide);
                                },
                                child: SvgPicture.asset(dashBordeController.istextishide? "assets/images/eye.svg" : "assets/images/eye-off.svg",
                                  height: 16,
                                  width: 16,
                                  color: textcolor.withOpacity(0.6),
                                ),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(dashBordeController.istextishide? price : "********", style: Typographyy.heading4.copyWith(color: textcolor,fontSize: dashBordeController.istextishide? 24:35 ), overflow: TextOverflow.ellipsis, maxLines: 1)),
                              SvgPicture.asset(
                                "assets/images/Circle12.svg",
                                width: 60,
                                height: 25,
                                color: textcolor,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
  );
}
