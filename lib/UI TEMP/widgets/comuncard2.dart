import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';



import '../../ConstData/typography.dart';

import '../../constdata/staticdata.dart';



class ComunCard2 extends StatefulWidget {
  final String title;
  final Color color;
  final String coin;
  final String price;
  final double pr;

  const ComunCard2({super.key, required this.title, required this.color, required this.coin, required this.price, required this.pr});


  @override
  State<ComunCard2> createState() => _ComunCard2State();
}

class _ComunCard2State extends State<ComunCard2> {


  @override
  Widget build(BuildContext context) {

    return   Container(
      width: 200,
        decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
            //  border: Border.all(color: notifire.getGry700_300Color),
              //color: notifire.getBgColor),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    width: 130,
                    child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: [
                        RadialAxis(
                          annotations:  [
                          //  GaugeAnnotation(widget: Text(widget.title,style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getGry500_600Color)),horizontalAlignment: GaugeAlignment.center,angle: 90 ,)
                          ],
                          showLabels: false,
                          showTicks: false,
                          startAngle: 180,
                          endAngle: 0,
                          radiusFactor: 0.7,
                          canScaleToFit: true,
                          axisLineStyle:  AxisLineStyle(
                            thickness: 0.2,
                           // color: notifire.getGry700_300Color,
                            thicknessUnit: GaugeSizeUnit.factor,
                            cornerStyle: CornerStyle.bothCurve,
                          ),
                          pointers:  <GaugePointer>[
                            RangePointer(
                                color: widget.color,
                                value: widget.pr,
                                width: 0.2,
                                sizeUnit: GaugeSizeUnit.factor,

                                cornerStyle: CornerStyle.bothCurve),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            ),
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     // Text(widget.coin,style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getBgPrimaryColor,fontSize: 20,overflow: TextOverflow.ellipsis),),
                      const SizedBox(height: 10,),
                    //  Text(widget.price,style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color,fontSize: 16,overflow: TextOverflow.ellipsis),),
                    ],
                  ),
          ),
        ],
      ),
    );

  }
}
