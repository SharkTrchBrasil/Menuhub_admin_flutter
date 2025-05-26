import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../ConstData/typography.dart';

import '../../constdata/staticdata.dart';



class ComunCard extends StatefulWidget {
  final String price;
  final Color color2;
  final String subtitle;
  final double pr;
  final Color color1;

  const ComunCard({super.key, required this.price, required this.color2, required this.subtitle, required this.pr, required this.color1});

  @override
  State<ComunCard> createState() => _ComunCardState();
}

class _ComunCardState extends State<ComunCard> {

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 130,
      width: 220,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
        //  border: Border.all(color: notifire.getGry700_300Color),
         // color: notifire.getBgColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.price,
             //   style: Typographyy.bodyLargeExtraBold
                  //  .copyWith(color: notifire.getTextColor, fontSize: 20)),

            ),
            Row(
              children: [
                Container(
                  height: 21,
                  width: 21,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.color1,
                  ),
                  child: Center(
                    child: Container(
                        height: 9,
                        width: 9,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: widget.color2)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(widget.subtitle,
                     // style: Typographyy.bodyMediumMedium
                         // .copyWith(color: notifire.getGry500_600Color),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: widget.pr,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color1),
               ///   backgroundColor: notifire.getGry700_300Color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}