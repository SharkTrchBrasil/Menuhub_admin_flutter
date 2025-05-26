import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../ConstData/typography.dart';
import '../constdata/staticdata.dart';

class DashboardGreetingCard extends StatefulWidget {
  final String userName;

  const DashboardGreetingCard({super.key, required this.userName});

  @override
  State<DashboardGreetingCard> createState() => _DashboardGreetingCardState();
}

class _DashboardGreetingCardState extends State<DashboardGreetingCard> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getGreeting() {
    final hour = _now.hour;
    if (hour < 12) return "dia";
    if (hour < 18) return "tarde";
    return "noite";
  }

  String getMonthPeriod() {
    int day = _now.day;
    if (day <= 10) return "Início do mês";
    if (day <= 20) return "Meio do mês";
    return "Final do mês";
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
          //    color: notifire.getBgPrimaryColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(width < 600 ? 15 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bom ${getGreeting()}, ${widget.userName} 👋",
                        //  style: Typographyy.heading4.copyWith(color: whiteColor),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          DateFormat.Hm().format(_now),
                       //   style: Typographyy.heading1.copyWith(color: whiteColor),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "${DateFormat("d 'de' MMMM", 'pt_BR').format(_now)} • ${DateFormat('EEEE', 'pt_BR').format(_now)}",
                          style: Typographyy.bodyMediumRegular.copyWith(
                          //  color: whiteColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getMonthPeriod(),
                          style: Typographyy.bodyMediumRegular.copyWith(
                           // color: whiteColor.withOpacity(0.5),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),
                width < 600
                    ? const SizedBox()
                    : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const SizedBox(height: 180, width: 250),
                    Positioned(
                      top: -44,
                      right: 0,
                      left: 0,
                      child: Image.asset(
                        "assets/images/Group 48563.png",
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
