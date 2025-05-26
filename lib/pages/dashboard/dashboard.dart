// // ignore_for_file: deprecated_member_use
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:totem_pro_admin/UI%20TEMP/widgets/card.dart';
//
// import 'package:totem_pro_admin/widgets/welcome_card.dart';
//
//
//
// import '../../../ConstData/typography.dart';
//
//
// import '../../constdata/staticdata.dart';
// import '../../UI TEMP/controller/dashbordecontroller.dart';
// import '../../UI TEMP/controller/drawercontroller.dart';
//
//
//
//
// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});
//
//   @override
//   State<Dashboard> createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {
//
//
//   final controller = PageController();
//   DashBordeController dashBordeController = Get.put(DashBordeController());
//   DrawerControllerr contoller = Get.put(DrawerControllerr());
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       color: notifire.getBgColor,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth < 600) {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     _buildDashBordUi1(width: constraints.maxWidth, count: 2),
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     Container(
//                       color: notifire.getBgColor,
//                       child: _buildDashBordUi2(width: constraints.maxWidth),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           } else if (constraints.maxWidth < 1000) {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Container(
//                           color: notifire.getBgColor,
//                           margin: EdgeInsets.all(padding),
//                           child: _buildDashBordUi1(
//                               width: constraints.maxWidth, count: 3),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Container(
//                           color: notifire.getBgColor,
//                           margin: EdgeInsets.all(padding),
//                           child: _buildDashBordUi2(width: constraints.maxWidth),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           } else {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Container(
//                           // height: 184,
//                           color: notifire.getBgColor,
//                           margin: EdgeInsets.all(padding),
//                           child: _buildDashBordUi1(
//                               width: constraints.maxWidth, count: 4),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Container(
//                           // height: Get.height,
//                           color: notifire.getBgColor,
//                           margin: EdgeInsets.all(padding),
//                           child: _buildDashBordUi2(width: constraints.maxWidth),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//   PopupMenuItem coinselecter({required bool i1or2}){
//     return PopupMenuItem(
//         padding: EdgeInsets.zero,
//         child:
//         SizedBox(
//           height: 200,
//           width: 140,
//           child: ListView.builder(
//             shrinkWrap: true,
//             padding: const EdgeInsets.all(0),
//             itemCount: dashBordeController.coinsName.length,
//             itemBuilder: (context, index) {
//               return InkWell(
//                 onTap: () {
//                   i1or2? dashBordeController.selectcoin(index) : dashBordeController.selectcoin1(index);
//                   Future.delayed(const Duration(milliseconds: 200),() {
//                     Get.back();
//                   },);
//                 },
//                 child: ListTile(
//                   leading:  Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: CircleAvatar(
//                       radius: 15,
//                       backgroundImage: AssetImage(dashBordeController.listOfCoin[index]),
//                       backgroundColor: Colors.transparent,
//                     ),
//                   ),
//                   title: Text(dashBordeController.coinsName[index], style: Typographyy.bodyLargeMedium.copyWith(color:  notifire.getTextColor)),
//                 ),);
//             },),
//         ));
//   }
//
//   Widget _buildDashBordUi1({required double width, required int count}) {
//     return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           //col1
//           DashboardGreetingCard(userName: 'Cristiano',),
//
//           //col2
//           Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: count,
//                         mainAxisExtent: 150,
//                         mainAxisSpacing: 10,
//                         crossAxisSpacing: 10),
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     itemBuilder: (context, index) {
//                       return dashBordeController.cards1[index];
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: count,
//                         mainAxisExtent: 120,
//                         mainAxisSpacing: 10,
//                         crossAxisSpacing: 10),
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     itemBuilder: (context, index) {
//                       return dashBordeController.cards2[index];
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           //col3
//           Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                       height: 450,
//                       padding:  const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(radius),
//                           border: Border.all(color: notifire.getGry700_300Color),
//                           color: notifire.getBgColor),
//                       child: SizedBox(
//                         height: 450,
//                         width: width,
//                         child: ListView(
//                           scrollDirection: Axis.horizontal,
//                           children: [
//                             SizedBox(
//                               width: width<1200 ? 1200 : width*0.8,
//                               child: SingleChildScrollView(
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Text(
//                                                   "Recent Transactions".tr,
//                                                   style: Typographyy.heading6
//                                                       .copyWith(
//                                                       color: notifire
//                                                           .getTextColor),
//                                                   overflow:
//                                                   TextOverflow.ellipsis,
//                                                   maxLines: 1),
//                                               const Spacer(),
//                                               Container(
//                                                 padding: const EdgeInsets.all(8),
//                                                 decoration: BoxDecoration(
//                                                     color: notifire
//                                                         .getContainerColor,
//                                                     borderRadius:
//                                                     BorderRadius.circular(
//                                                         8)),
//                                                 child: Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     Text("View all".tr,
//                                                         style: Typographyy
//                                                             .bodySmallSemiBold
//                                                             .copyWith(
//                                                             color: notifire
//                                                                 .getTextColor),
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         maxLines: 1),
//                                                     const SizedBox(
//                                                       width: 5,
//                                                     ),
//                                                     SvgPicture.asset(
//                                                       "assets/images/chevron-right.svg",
//                                                       height: 16,
//                                                       width: 16,
//                                                       color:
//                                                       notifire.getTextColor,
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//
//                                             ],
//                                           ),
//
//                                           const SizedBox(height: 24,),
//
//                                           Table(
//                                             columnWidths: const {
//                                               0: FixedColumnWidth(80),
//                                               // 1: FixedColumnWidth(200),
//                                               // 2: FixedColumnWidth(200),
//                                               // 3: FixedColumnWidth(200),
//                                               // 4: FixedColumnWidth(200),
//                                               // 5: FixedColumnWidth(200),
//                                             },
//                                             children: [
//                                               TableRow(
//                                                   children: [
//                                                     buildiconandtitle(title: "Coin",context: context),
//                                                     buildiconandtitle(title: "Transaction",context: context),
//                                                     buildiconandtitle(title: "ID",context: context),
//                                                     buildiconandtitle(title: "Date",context: context),
//                                                     buildiconandtitle(title: "Status",context: context),
//                                                     Padding(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(vertical: 10),
//                                                       child: Row(
//                                                         mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                         children: [
//                                                           Text(
//                                                             "Fees",
//                                                             style: Typographyy
//                                                                 .bodyLargeMedium
//                                                                 .copyWith(
//                                                                 color: notifire
//                                                                     .getTextColor),
//                                                           ),
//                                                           const SizedBox(
//                                                             width: 8,
//                                                           ),
//                                                           SvgPicture.asset(
//                                                             "assets/images/Group 47984.svg",
//                                                             height: 15,
//                                                             width: 15,
//                                                             color: notifire
//                                                                 .getGry600_500Color,
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ]),
//                                               tableroww(
//                                                   logo: "assets/images/btc.png",
//                                                   price: "\$659.10 ",
//                                                   subtitle: "Withdraw USDT",
//                                                   id: "#64525152",
//                                                   date: "Mar 21, 2022",
//                                                   status: "Declined",
//                                                   fees: "0.52000 BTC",
//                                                   color: Colors.red,context: context),
//                                               tableroww(
//                                                   logo: "assets/images/eth.png",
//                                                   price: "\$239.10 ",
//                                                   subtitle: "Withdraw USDT",
//                                                   id: "#24525356",
//                                                   date: "Mar 22, 2022",
//                                                   status: "Complited",
//                                                   fees: "0.22000 BTC",
//                                                   color: Colors.green,context: context),
//                                               tableroww(
//                                                   logo:
//                                                   "assets/images/eth-1.png",
//                                                   price: "\$59.10 ",
//                                                   subtitle: "Withdraw USDT",
//                                                   id: "#11425356",
//                                                   date: "Mar 23, 2022",
//                                                   status: "Pending",
//                                                   fees: "1.2600 BTC",
//                                                   color: Colors.yellow,context: context),
//                                               tableroww(
//                                                   logo: "assets/images/trx.png",
//                                                   price: "\$659.10 ",
//                                                   subtitle: "Withdraw USDT",
//                                                   id: "#74525156",
//                                                   date: "Mar 24, 2022",
//                                                   status: "Complited",
//                                                   fees: "0.12000 BTC",
//                                                   color: Colors.green,context: context),
//                                               tableroww(
//                                                   logo:
//                                                   "assets/images/usdt.png",
//                                                   price: "\$659.10 ",
//                                                   subtitle: "Withdraw USDT",
//                                                   id: "#34524156",
//                                                   date: "Mar 25, 2022",
//                                                   status: "Declined",
//                                                   fees: "0.15000 BTC",
//                                                   color: Colors.red,context: context),
//
//                                               // row(
//                                               //     title: "Sent to Antonio",
//                                               //     date: "Jan 14, 2022",
//                                               //     profile:
//                                               //         "assets/images/avatar-10.png",
//                                               //     price: "-\$150.00",
//                                               //     tralling: "Pending",
//                                               //     textcolor: Colors.red),
//
//                                               // row(
//                                               //     title: "Witdraw Paypal",
//                                               //     date: "Jan 13, 2022",
//                                               //     profile:
//                                               //         "assets/images/Frame 24.png",
//                                               //     price: "+\$200.00",
//                                               //     tralling: "Success",
//                                               //     textcolor: Colors.green),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       )),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//   }
//
//
//   Widget _buildDashBordUi2({required double width}) {
//     return Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(radius),
//                   border: Border.all(color: notifire.getGry700_300Color),
//                   color: notifire.getBgColor),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: width < 600 ? 15 : 24),
//                 child: Column(children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Wallet".tr,
//                           style: Typographyy.heading6
//                               .copyWith(color: notifire.getTextColor),
//                         ),
//                         SvgPicture.asset(
//                           "assets/images/dots-vertical.svg",
//                           height: 20,
//                           width: 20,
//                           color: notifire.getGry500_600Color,
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 15,
//                      ),
//                   SizedBox(
//                     height: 233,
//                     child: PageView(
//                       controller: controller,
//                       children:  [
//                         cardss(price: "\$24,098.00",bgcolor: notifire.getBgPrimaryColor,textcolor:  Colors.white),
//                         cardss(price: "\$28,198.00",bgcolor: notifire.getBgPrimaryColor,textcolor:  Colors.white),
//                         cardss(price: "\$10,358.00",bgcolor: notifire.getBgPrimaryColor,textcolor:  Colors.white),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 14,
//                   ),
//                   SmoothPageIndicator(
//                       controller: controller,
//                       effect: ExpandingDotsEffect(
//                           dotColor: notifire.getGry700_300Color,
//                           activeDotColor: notifire.getBgPrimaryColor,
//                           radius: 15,
//                           dotHeight: 10,
//                           dotWidth: 10),
//                       count: 3),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Buy & sell crypto in minutes",
//                         style: Typographyy.heading6
//                             .copyWith(color: notifire.getTextColor),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Wrap(
//                     runAlignment: WrapAlignment.spaceEvenly,
//                     runSpacing: 10,
//                     spacing: 20,
//                     children: [
//                       InkWell(
//
//                           onTap: () => context.go('/stores/${1}/products'),
//                           child: _buildComencards(title: "Send", iconpath: "assets/images/card-send1.svg")),
//
//                       InkWell(
//                         onTap: () {
//                           showDialog(
//                             context: context,
//                             barrierDismissible: true,
//                             builder: (context) => Container()
//                           );
//                         },
//                         child: _buildComencards(
//                             title: "Calculadora",
//                             iconpath: "assets/images/card-receive1.svg"),
//                       ),
//                       InkWell(
//                         onTap: () {
//
//                         },
//
//                         child: _buildComencards(
//                             title: "Invoicing",
//                             iconpath: "assets/images/receipt1.svg"),
//                       ),
//                       InkWell(
//
//                         onTap: () {
//
//                         },
//                         child: _buildComencards(
//                             title: "Currency",
//                             iconpath: "assets/images/dollar-circle.svg"),
//                       ),
//                       InkWell(
//
//                        onTap: () {
//
//                        },
//                         child: _buildComencards(
//                             title: "Transfer",
//                             iconpath: "assets/images/credit-card-convert.svg"),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           Navigator.pushNamed(context, '/creditCard');
//                           contoller.colorSelecter(value: 5);
//                         },
//                         child: _buildComencards(
//                             title: "Buy", iconpath: "assets/images/shop-add.svg"),
//                       ),
//                       InkWell(
//                        onTap: () {
//                          Navigator.pushNamed(context, '/sellCrypto');
//                          contoller.colorSelecter(value: 7);
//                          contoller.function(value: -1);
//                        },
//                         child: _buildComencards(
//                             title: "Sell", iconpath: "assets/images/wallet1.svg"),
//                       ),
//                       _buildComencards(
//                           title: "More",
//                           iconpath: "assets/images/element-plus.svg"),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 24,
//                   ),
//                 ]),
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.only(top: 30),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(radius),
//                   border: Border.all(color: notifire.getGry700_300Color),
//                   color: notifire.getBgColor),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: width < 600 ? 15 : 24,
//                     vertical: width < 600 ? 15 : 29),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Quick Exchage".tr,
//                           style: Typographyy.heading6
//                               .copyWith(color: notifire.getTextColor),
//                         ),
//                         SvgPicture.asset(
//                           "assets/images/Vector99.svg",
//                           height: 22,
//                           width: 22,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 40,
//                     ),
//                     SizedBox(
//                       height: 270,
//                       child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                         Column(
//                           children: [
//                             Container(
//                               height: 120,
//                               decoration: BoxDecoration(
//                                   color: notifire.getDrawerColor,
//                                   borderRadius: BorderRadius.circular(20)),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
//                                 child: Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             "I have :".tr,
//                                             style: Typographyy.bodyMediumMedium
//                                                 .copyWith(color: notifire.getGry600_500Color),
//                                           ),
//                                           Flexible(
//                                             child: Text(
//                                               "0.120 BTC",
//                                               style: Typographyy.bodyMediumMedium
//                                                   .copyWith(color: notifire.getGry600_500Color),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12,),
//                                       isExchange ? _buidlex2() : _buidlex1(),
//
//                                     ]),
//                               ),
//                             ),
//                             const SizedBox(height: 30,),
//                             Container(
//                               height: 120,
//                               decoration: BoxDecoration(
//                                   color: notifire.getDrawerColor,
//                                   borderRadius: BorderRadius.circular(20)),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
//                                 child: Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Flexible(
//                                             child: Text(
//                                               "I want :".tr,
//                                               style: Typographyy.bodyMediumMedium
//                                                   .copyWith(color: notifire.getGry600_500Color),
//                                             ),
//                                           ),
//                                           Flexible(
//                                             child: Text(
//                                               "0.260 ETH",
//                                               style: Typographyy.bodyMediumMedium
//                                                   .copyWith(color: notifire.getGry600_500Color),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12,),
//                                       isExchange? _buidlex1() : _buidlex2()
//                                     ]),
//                               ),
//                             ),
//                           ],
//                         ),
//                          InkWell(
//                            onTap: () {
//                              setState(() {
//                                isExchange =! isExchange;
//
//                              });
//
//                            },
//                            child: Container(
//                              height: 50,
//                              width: 50,
//                              decoration: BoxDecoration(
//                                shape: BoxShape.circle,
//                                color: notifire.getBgPrimaryColor,
//                                border: Border.all(color: Colors.white.withOpacity(0.8),width: 4),
//                              ),
//                              child: Center(child: SvgPicture.asset("assets/images/Path 56640.svg",height: 22,width: 22,)),
//                            ),
//                          )
//                       ]),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//   }
//   bool isExchange = false;
//
// Widget _buidlex1(){
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Column(
//         children: [
//           GetBuilder<DashBordeController>(
//               builder: (appBarController) {
//                 return PopupMenuButton(
//                     constraints: const BoxConstraints(minWidth: 120,maxWidth: 140),
//                     onOpened: () {
//                       appBarController.ismenu(true);
//                     },
//                     onCanceled: () {
//                       appBarController.ismenu(false);
//                     },
//                     color: notifire.getDrawerColor,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     padding: EdgeInsets.zero,
//                     itemBuilder: (ctx) => [
//                       coinselecter(i1or2: true),
//                     ],
//                     child: Container(
//                       height: 48,
//                       width: 140,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(radius),
//                           border: Border.all(color: notifire.getGry700_300Color),
//                           color: Colors.transparent),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Center(
//                           child: ListTile(
//                             dense: true,
//                             contentPadding: const EdgeInsets.all(0),
//                             trailing:  Transform.translate(
//                                 offset: const Offset(-10, 0),
//                                 child: SvgPicture.asset(appBarController.ismenuopen? "assets/images/chevron-up.svg"  :"assets/images/chevron-down.svg")),
//                             leading:  CircleAvatar(
//                               radius: 15,
//                               backgroundImage: AssetImage(dashBordeController.listOfCoin[dashBordeController.coinselecter]),
//                               backgroundColor: Colors.transparent,
//                             ),
//                             title: Transform.translate(
//                                 offset: const Offset(-8, 0),child: Text(appBarController.coinsName[appBarController.coinselecter], style: Typographyy.bodyLargeMedium.copyWith(color:  notifire.getTextColor))),
//                           ),
//                         ),
//                       ),
//                     )
//                 );
//               }
//           ),
//         ],
//       ),
//       Flexible(
//         child: Container(
//           height: 48,
//           width: 80,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(radius),
//               border: Border.all(color: notifire.getGry700_300Color),
//               color: Colors.transparent),
//           child: Center(
//             child: TextField(
//               textAlign: TextAlign.center,
//               style: Typographyy.bodyLargeSemiBold.copyWith(color: notifire.getTextColor),
//               decoration: InputDecoration(
//                 hintStyle: Typographyy.bodyLargeSemiBold.copyWith(color: notifire.getTextColor),
//                 hintText: "\$ 345",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ),
//       )
//     ],
//   );
// }
//   Widget _buidlex2(){
//     return  Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           children: [
//             GetBuilder<DashBordeController>(
//                 builder: (appBarController) {
//                   return PopupMenuButton(
//                       constraints: const BoxConstraints(minWidth: 120,maxWidth: 140),
//                       onOpened: () {
//                         appBarController.ismenu(true);
//                       },
//                       onCanceled: () {
//                         appBarController.ismenu(false);
//                       },
//                       color: notifire.getDrawerColor,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       padding: EdgeInsets.zero,
//                       itemBuilder: (ctx) => [
//                         coinselecter(i1or2: false),
//                       ],
//                       child:
//                       Container(
//                         height: 48,
//                         width: 140,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(radius),
//                             border: Border.all(color: notifire.getGry700_300Color),
//                             color: Colors.transparent),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Center(
//                             child: ListTile(
//                               dense: true,
//                               contentPadding: const EdgeInsets.all(0),
//                               trailing:  Transform.translate(
//                                   offset: const Offset(-5, 0),
//                                   child: SvgPicture.asset(appBarController.ismenuopen1? "assets/images/chevron-up.svg"  :"assets/images/chevron-down.svg")),
//                               leading:  CircleAvatar(
//                                 radius: 15,
//                                 backgroundImage: AssetImage(dashBordeController.listOfCoin[dashBordeController.coinselecter1]),
//                                 backgroundColor: Colors.transparent,
//                               ),
//                               title: Transform.translate(
//                                   offset: const Offset(-8, 0),
//                                   child: Text(appBarController.coinsName[appBarController.coinselecter1], style: Typographyy.bodyLargeMedium.copyWith(color:  notifire.getTextColor))),
//                             ),
//                           ),
//                         ),
//                       )
//                   );
//                 }
//             ),
//           ],
//         ),
//         Flexible(
//           child: Container(
//             height: 48,
//             width: 80,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(radius),
//                 border: Border.all(color: notifire.getGry700_300Color),
//                 color: Colors.transparent),
//             child: Center(
//               child: TextField(
//                 textAlign: TextAlign.center,
//                 style: Typographyy.bodyLargeSemiBold.copyWith(color: notifire.getTextColor),
//                 decoration: InputDecoration(
//                   hintStyle: Typographyy.bodyLargeSemiBold.copyWith(color: notifire.getTextColor),
//                   hintText: "\$ 445",
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//
//   Widget _buildComencards({required String title, required String iconpath}) {
//     return Column(
//       children: [
//         Container(
//           height: 56,
//           width: 56,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: notifire.getGry700_300Color),
//           ),
//           child: Center(
//               child: SvgPicture.asset(
//             iconpath,
//             height: 24,
//             width: 24,
//           )),
//         ),
//         const SizedBox(
//           height: 16,
//         ),
//         Text(title.tr,
//             style: Typographyy.bodyMediumSemiBold
//                 .copyWith(color: notifire.getGry500_600Color)),
//       ],
//     );
//   }
//
//
//   TableRow row(
//       {required String title,
//       required String date,
//       required String profile,
//       required String price,
//       required String tralling,
//       required Color textcolor}) {
//     return TableRow(children: [
//       CircleAvatar(
//           radius: 20,
//           backgroundColor: Colors.transparent,
//           backgroundImage: AssetImage(profile)),
//       Padding(
//         padding: const EdgeInsets.only(top: 10, left: 20),
//         child: Text(title,
//             style: Typographyy.bodyMediumExtraBold
//                 .copyWith(color: notifire.getTextColor)),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(top: 10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: 20,
//               width: 20,
//               child: SvgPicture.asset("assets/images/calendar.svg"),
//             ),
//             const SizedBox(
//               width: 8,
//             ),
//             Text(date,
//                 style: Typographyy.bodyMediumMedium
//                     .copyWith(color: notifire.getGry500_600Color)),
//           ],
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(top: 10),
//         child: Center(
//             child: Text(price,
//                 style: Typographyy.bodyMediumExtraBold
//                     .copyWith(color: notifire.getTextColor))),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(top: 5),
//         child: Center(
//             child: Container(
//               padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                     color: textcolor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8)),
//                  height: 32,
//                  width: 50,
//                 child: Center(
//                     child: Text(tralling,
//                         style: Typographyy.bodySmallMedium
//                             .copyWith(color: textcolor))))),
//       ),
//     ]);
//   }
// }
//
// TableRow tableroww(
//     {required String logo,
//       required String price,
//       required String subtitle,
//       required String id,
//       required String date,
//       required String status,
//       required String fees,
//       required Color color,context}) {
//
//   return TableRow(children: [
//     Padding(
//       padding: const EdgeInsets.only(top: 10, right: 35),
//       child: CircleAvatar(
//           radius: 20,
//           backgroundColor: Colors.transparent,
//           backgroundImage: AssetImage(logo)),
//     ),
//     ListTile(
//       contentPadding: const EdgeInsets.all(0),
//       dense: true,
//       title: Text(
//         price,
//         style: Typographyy.bodyLargeExtraBold
//             .copyWith(color: notifire.getTextColor),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: Typographyy.bodyMediumMedium
//             .copyWith(color: notifire.getGry600_500Color),
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Text(
//         id,
//         style: Typographyy.bodyLargeSemiBold
//             .copyWith(color: notifire.getTextColor),
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Text(
//         date,
//         style: Typographyy.bodyLargeSemiBold
//             .copyWith(color: notifire.getTextColor),
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.only(right: 50, top: 10, bottom: 10),
//       child: Container(
//           width: 100,
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15)),
//           padding: const EdgeInsets.all(8),
//           child: Center(
//               child: Text(
//                 status,
//                 style: Typographyy.bodyLargeSemiBold.copyWith(color: color.withOpacity(0.8)),
//               ))),
//     ),
//     Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Center(
//           child: Text(
//             fees,
//             style: Typographyy.bodyLargeSemiBold
//                 .copyWith(color: notifire.getTextColor),
//           )),
//     ),
//   ]);
// }
//
//
// Widget buildiconandtitle({required String title,context}) {
//
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getTextColor),
//         ),
//         const SizedBox(
//           width: 8,
//         ),
//         SvgPicture.asset(
//           "assets/images/Group 47984.svg",
//           height: 15,
//           width: 15,
//           color: notifire.getGry600_500Color,
//         )
//       ],
//     ),
//   );
// }