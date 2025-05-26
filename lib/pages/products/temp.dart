
// class ProductsPage extends StatefulWidget {
//   final int storeId;
//
//   const ProductsPage({super.key, required this.storeId});
//
//   @override
//   State<ProductsPage> createState() => _ProductsPageState();
// }
//
// class _ProductsPageState extends State<ProductsPage>{
//
//   late final AppListController<Product> productsController;
//
//
//   late final AppListController<Category> categoriesController =
//   AppListController<Category>(
//     fetch: () => getIt<CategoryRepository>().getCategories(widget.storeId),
//   );
//
//   @override
//    void initState() {
//     super.initState();
//
//      productsController = AppListController<Product>(
//        fetch: () => getIt<ProductRepository>().getProducts(widget.storeId),
//      );
//    }
//
//
//   InboxController inboxController = Get.put(InboxController());
//
//   InvoiceController invoiceController = Get.put(InvoiceController());
//
//   int currentIndex = 0;
//   ColorNotifire notifire = ColorNotifire();
//   @override
//   Widget build(BuildContext context) {
//   notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       color: notifire.bgcolore,
//       // color: Colors.red,
//       child: LayoutBuilder(builder: (context, constraints) {
//         if(constraints.maxWidth<600){
//           return   SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Column(
//               children: [
//                 mainrow(),
//                 const SizedBox(height: 20,),
//                 Row(
//                   children: [
//                     Expanded(child: firstcontain(size: constraints.maxWidth))
//                   ],
//                 ),
//                 const SizedBox(height: 70,),
//               ],
//             ),
//           );
//         }
//         else if(constraints.maxWidth<1000){
//           return   SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(child: mainrow()),
//                   ],
//                 ),
//                 const SizedBox(height: 20,),
//                 Row(
//                   children: [
//                     Expanded(child: firstcontain(size: constraints.maxWidth))
//                   ],
//                 )
//
//               ],),
//           );
//         }
//         else{
//           return   SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(child: mainrow()),
//                   ],
//                 ),
//                 const SizedBox(height: 20,),
//                 Row(
//                   children: [
//                     Expanded(child: firstcontain(size: constraints.maxWidth))
//                   ],
//                 )
//               ],
//             ),
//           );
//         }
//       },),
//     );
//   }
//
//
//
//   Widget mainrow(){
//     return Row(
//       children:  [
//         Expanded(
//           child: SizedBox(
//             // color: Colors.red,
//             height: 50,
//             child: ListTile(
//               leading: Padding(
//                 padding: const EdgeInsets.only(top: 20,left: 0),
//                 child: Text('Produtos',style: TextStyle(fontFamily: 'Jost-SemiBold',fontSize: 20,color: notifire.textcolore,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis),
//               ),
//               trailing:  Padding(
//                 padding: const EdgeInsets.only(top: 20),
//                 child: SizedBox(
//                   height: 80,
//                   width: 150,
//                   child:  AppPrimaryButton(
//               label: 'Novo produto',
//               onPressed: () {
//                 context.go('/stores/${widget.storeId}/products/new');
//               },
//             ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   bool isChecked = false;
//   Widget firstcontain({required double size}){
//     return Padding(
//       padding: const EdgeInsets.only(left: 0,right: 10),
//       child: Container(
//         height: 780,
//         decoration: BoxDecoration(
//           // color: Colors.black,
//           // color: Colors.orangeAccent.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20)
//         ),
//         child: Column(
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10,right: 20),
//                 child: Container(
//                   // height: 660,
//                   width: size<1000 ? 1200 : size,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Table(
//                               // border: TableBorder.all(color: Colors.white),
//                               columnWidths: const <int, TableColumnWidth>{
//                                 0: FixedColumnWidth(50),
//                                 1: FixedColumnWidth(100),
//                                 2: FixedColumnWidth(200),
//                                 3: FixedColumnWidth(100),
//                                 4: FixedColumnWidth(50),
//                                 5: FixedColumnWidth(100),
//                                 6: FixedColumnWidth(100),
//                                 7: FixedColumnWidth(100),
//                               },
//                               children: [
//                                 const TableRow(
//                                     children: [
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                     ]
//                                 ),
//                                 _rowHeader(),
//
//
//                                 const TableRow(
//                                     children: [
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                       SizedBox(height: 20,),
//                                     ]
//                                 ),
//
//
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   TableRow _rowHeader (){
//     return  TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 40,),
//             child: Text('#',style: TextStyle(color: Colors.blue),),
//           ),
//           Text('Name',style: TextStyle(color: notifire.textcolore),),
//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Text('Client Name',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Text('Issued Date',style: TextStyle(color: notifire.textcolore),),
//           Text('Total',style: TextStyle(color: notifire.textcolore),),
//           Padding(
//             padding: const EdgeInsets.only(left: 60),
//             child: Text('Balance',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60),
//             child: Text('Action',style: TextStyle(color: notifire.textcolore),),
//           ),
//         ]
//     );
//   }
//
//
//   SampleItem? selectedMenu;
//   TableRow _row1 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Degin of artic',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-2 1.png'),backgroundColor: Colors.yellow,radius: 20,),
//             title: Text('Ophelia Olson',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@opheliaolson',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('14 Mar 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$400',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffE4F7F4),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('Paid',style: TextStyle(color: Colors.green),maxLines: 1,)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row2 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Stephanie Macdonald',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-4 2.png'),backgroundColor: Colors.pink,radius: 20,),
//             title: Text('Remy Cross',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@remycross',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('12 Feb 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$400',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: Colors.pinkAccent.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('\$400',style: TextStyle(color: Colors.pink),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row3 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Genesis Hampton degn',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-1 1.png'),backgroundColor: Colors.orange,radius: 20,),
//             title: Text('Gia Roy',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@giaroy',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('10 Mar 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$321',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffE4F7F4),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('Paid',style: TextStyle(color: Colors.green),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row4 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Johnathan McCullough',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-5 2.png'),backgroundColor: Colors.deepOrange,radius: 20,),
//             title: Text('Evie Lucas',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@evielucas',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('8 Mar 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$200',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffE4F7F4),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('Paid',style: TextStyle(color: Colors.green),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row5 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Veronica Anderson',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-2 1.png'),backgroundColor: Colors.yellow,radius: 20,),
//             title: Text('Carl Marin',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@carlmarin',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('1 Mar 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$123',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: Colors.pink.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('Paid',style: TextStyle(color: Colors.pink),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row6 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Maximiliano Gonzales',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-4 2.png'),backgroundColor: Colors.pink,radius: 20,),
//             title: Text('June Price',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@juneprice',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('3 Apr 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$99',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: Colors.pink.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: const Center(child: Text('\$99',style: TextStyle(color: Colors.pink),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//   TableRow _row7 (){
//     return   TableRow(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 20,top: 20),
//             child: Text('#14251',style: TextStyle(color: Colors.blue),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('Guadalupe name',style: TextStyle(color: notifire.textcolore),),
//           ),
//           ListTile(
//             leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar-1 1.png'),backgroundColor: Colors.orange,radius: 20,),
//             title: Text('Elle Murillo',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//             subtitle: Text('@ellemurillo',style: TextStyle(color: notifire.textcolore,fontSize: 13),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('14 Mar 2023',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Text('\$400',style: TextStyle(color: notifire.textcolore),),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 60,right: 60,top: 15),
//             child: Container(
//               height: 30,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xffE4F7F4),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: const Center(child: Text('Paid',style: TextStyle(color: Colors.green),maxLines: 1)),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 70,right: 70,top: 13),
//             child: Container(
//               height: 35,
//               width: 50,
//               decoration: BoxDecoration(
//                   color: const Color(0xffF4F5F7),
//                   borderRadius: BorderRadius.circular(5)
//               ),
//               child: Center(child:  PopupMenuButton<SampleItem>(
//                 initialValue: selectedMenu,
//                 child: const Icon(Icons.more_vert,color: Colors.black),
//                 onSelected: (SampleItem item) {
//                   setState(() {
//                     selectedMenu = item;
//                   });
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemOne,
//                     child: Text('Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemTwo,
//                     child: Text('Another Action'),
//                   ),
//                   const PopupMenuItem<SampleItem>(
//                     value: SampleItem.itemThree,
//                     child: Text('Something else Here'),
//                   ),
//                 ],
//               )),
//             ),
//           )
//         ]
//     );
//   }
//
//
//
// }
//


//
//   @override
//   void initState() {
//     super.initState();
//
//     productsController = AppListController<Product>(
//       fetch: () => getIt<ProductRepository>().getProducts(widget.storeId),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//   notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return BasePage(
//
//       mobileBuilder: (BuildContext context) {
//         return body();
//
//
//
//
//
//       },
//       desktopBuilder: (BuildContext context) {
//         return body();
//       },
//       mobileAppBar: AppBarCustom(title: 'Produtos'),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 18.0),
//         child: FloatingActionButton(
//           onPressed: () {
//             context.go('/stores/${widget.storeId}/products/new');
//           },
//           tooltip: 'Novo produto',
//           elevation: 0,
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
//
//   Widget body(){
//     return Column(
//       children: [
//         ResponsiveBuilder.isMobile(context) ?  const SizedBox(height: 26):
//         Row(
//           children: [
//             SearchField(onChanged: (String value) {}),
//
//             const Spacer(),
//
//             FilterButton(onPressed: () {}),
//
//             const SizedBox(width: 16),
//
//             AppPrimaryButton(
//               label: 'Novo produto',
//               onPressed: () {
//                 context.go('/stores/${widget.storeId}/products/new');
//               },
//             ),
//           ],
//         ),
//
//
//
//
//
//         Expanded(
//           child: AnimatedBuilder(
//             animation: productsController,
//             builder: (_, __) {
//               return AppPageStatusBuilder<List<Product>>(
//                 tryAgain: productsController.refresh,
//                 status: productsController.status,
//                 successBuilder: (products) {
//                   return LayoutBuilder(
//                     builder: (context, constraints) {
//                       if (constraints.maxWidth < 600) {
//                         // MOBILE
//                         return ListView.builder(
//                           itemCount: products.length,
//                           itemBuilder: (context, index) {
//                             final product = products[index];
//                             return Card(
//                               elevation: 2,
//                               child: ListTile(
//                                 onTap:
//                                     () => context.go(
//                                   '/stores/${widget.storeId}/products/${product.id}',
//                                 ),
//                                 leading: Image.network(
//                                   product.image!.url ?? '',
//                                 ),
//                                 title: Text(
//                                   product.name,
//                                   style: Typographyy.bodyLargeMedium
//                                       .copyWith(
//                                     color: notifire.getTextColor,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   product.category!.name,
//                                 ),
//                                 trailing: Text(
//                                   NumberFormat.simpleCurrency(
//                                     locale: 'pt-BR',
//                                   ).format(product.basePrice! / 100),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       } else {
//                         // DESKTOP OU TABLET
//                         return SizedBox(
//                           height:
//                           MediaQuery.of(context).size.height +
//                               (constraints.maxWidth < 600 ? 110 : -150),
//                           width: constraints.maxWidth,
//                           child: ListView(
//                             scrollDirection: Axis.horizontal,
//                             children: [
//                               SizedBox(
//                                 width:
//                                 constraints.maxWidth < 1400
//                                     ? 1500
//                                     : constraints.maxWidth,
//                                 child: Column(
//                                   children: [
//                                     // Cabeçalho fixo
//                                     Container(
//                                       color: Colors.white,
//                                       child: Table(
//                                         children: [
//                                           TableRow(
//                                             children: [
//                                               Center(
//                                                 child: dataColumn1(
//                                                   title: "Ação",
//                                                   iscenter: true,
//                                                 ),
//                                               ),
//                                               dataColumn1(
//                                                 title: "Imagem",
//                                                 iscenter: false,
//                                               ),
//                                               dataColumn1(
//                                                 title: "Nome",
//                                                 iscenter: false,
//                                               ),
//
//                                               dataColumn1(
//                                                 title: "Código",
//                                                 iscenter: false,
//                                               ),
//                                               dataColumn1(
//                                                 title: "Observações",
//                                                 iscenter: true,
//                                               ),
//                                               dataColumn1(
//                                                 title: "Preço de venda",
//                                                 iscenter: false,
//                                               ),
//                                               dataColumn1(
//                                                 title: "Estoque atual",
//                                                 iscenter: false,
//                                               ),
//                                               dataColumn1(
//                                                 title: "EAN",
//                                                 iscenter: false,
//                                               ),
//                                               Center(
//                                                 child: dataColumn1(
//                                                   title: "Status",
//                                                   iscenter: true,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Divider
//                                     // Divider após cabeçalho
//                                     Table(
//                                       children: [
//                                         TableRow(
//                                           children: List.generate(6, (_) {
//                                             return Divider(
//                                               color:
//                                               notifire
//                                                   .getGry700_300Color,
//                                               height: 30,
//                                             );
//                                           }),
//                                         ),
//                                       ],
//                                     ),
//                                     // Conteúdo rolável
//                                     Expanded(
//                                       child: ListView.builder(
//                                         itemCount: products.length,
//                                         itemBuilder: (context, index) {
//                                           final product = products[index];
//                                           return Table(
//                                             // columnWidths: const {
//                                             //   0: FixedColumnWidth(140), // Coluna "Ação" bem estreita
//                                             // },
//                                             children: [
//                                               TableRow(
//                                                 children: [
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 8,
//                                                       horizontal: 10,
//                                                     ),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .start,
//                                                       children: [
//                                                         // Botão de três pontinhos
//                                                         PopupMenuButton(
//                                                           tooltip: "",
//                                                           color:
//                                                           notifire
//                                                               .getDrawerColor,
//                                                           offset:
//                                                           const Offset(
//                                                             0,
//                                                             45,
//                                                           ),
//                                                           shape: RoundedRectangleBorder(
//                                                             borderRadius:
//                                                             BorderRadius.circular(
//                                                               12,
//                                                             ),
//                                                           ),
//                                                           child: Container(
//                                                             height: 30,
//                                                             width: 30,
//                                                             decoration: BoxDecoration(
//                                                               borderRadius:
//                                                               BorderRadius.circular(
//                                                                 8,
//                                                               ),
//                                                               color:
//                                                               Colors
//                                                                   .transparent,
//                                                               border: Border.all(
//                                                                 color:
//                                                                 notifire
//                                                                     .getGry700_300Color,
//                                                               ),
//                                                             ),
//                                                             child: Center(
//                                                               child: SvgPicture.asset(
//                                                                 "assets/images/dots-vertical.svg",
//                                                                 height: 20,
//                                                                 width: 20,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           itemBuilder: (
//                                                               context,
//                                                               ) {
//                                                             return [
//                                                               PopupMenuItem(
//                                                                 padding:
//                                                                 const EdgeInsets.all(
//                                                                   8,
//                                                                 ),
//                                                                 child: Column(
//                                                                   children: [
//                                                                     _buildRow(
//                                                                       iconpath:
//                                                                       "assets/images/copy.svg",
//                                                                       title:
//                                                                       "Copiar",
//                                                                     ),
//                                                                     const SizedBox(
//                                                                       height:
//                                                                       8,
//                                                                     ),
//                                                                     _buildRow(
//                                                                       iconpath:
//                                                                       "assets/images/printer.svg",
//                                                                       title:
//                                                                       "Imprimir",
//                                                                     ),
//                                                                     const SizedBox(
//                                                                       height:
//                                                                       8,
//                                                                     ),
//                                                                     _buildRow(
//                                                                       iconpath:
//                                                                       "assets/images/file-download.svg",
//                                                                       title:
//                                                                       "Baixar PDF",
//                                                                     ),
//                                                                     const SizedBox(
//                                                                       height:
//                                                                       8,
//                                                                     ),
//                                                                     _buildRow(
//                                                                       iconpath:
//                                                                       "assets/images/share-two.svg",
//                                                                       title:
//                                                                       "Compartilhar",
//                                                                     ),
//                                                                     const SizedBox(
//                                                                       height:
//                                                                       8,
//                                                                     ),
//                                                                     _buildRow(
//                                                                       iconpath:
//                                                                       "assets/images/archive.svg",
//                                                                       title:
//                                                                       "Arquivar",
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ];
//                                                           },
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 12,
//                                                         ),
//
//                                                         // Botão Editar
//                                                         GestureDetector(
//                                                           onTap:
//                                                               () => context.go(
//                                                             '/stores/${widget.storeId}/products/${product.id}',
//                                                           ),
//                                                           child: Container(
//                                                             padding:
//                                                             const EdgeInsets.symmetric(
//                                                               horizontal:
//                                                               10,
//                                                               vertical:
//                                                               6,
//                                                             ),
//                                                             decoration: BoxDecoration(
//                                                               border: Border.all(
//                                                                 color:
//                                                                 Colors
//                                                                     .blue,
//                                                               ),
//                                                               borderRadius:
//                                                               BorderRadius.circular(
//                                                                 6,
//                                                               ),
//                                                             ),
//                                                             child: Text(
//                                                               "Editar",
//                                                               style: TextStyle(
//                                                                 color:
//                                                                 Colors
//                                                                     .blue,
//                                                                 fontSize:
//                                                                 12,
//                                                                 fontWeight:
//                                                                 FontWeight
//                                                                     .w500,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 8,
//                                                     ),
//                                                     child: ListTile(
//                                                       leading: CircleAvatar(
//                                                         radius: 24,
//                                                         backgroundColor:
//                                                         notifire.getBgPrimaryColor
//                                                             .withOpacity(
//                                                           0.2,
//                                                         ),
//                                                         child:
//                                                         Image.network(
//                                                           product
//                                                               .image!
//                                                               .url!,
//                                                         ),
//                                                       ),
//                                                       dense: true,
//                                                       contentPadding:
//                                                       const EdgeInsets.all(
//                                                         0,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 8,
//                                                     ),
//                                                     child: ListTile(
//                                                       title: Text(
//                                                         product.name,
//                                                         style: Typographyy
//                                                             .bodyLargeMedium
//                                                             .copyWith(
//                                                           color:
//                                                           notifire
//                                                               .getTextColor,
//                                                         ),
//                                                       ),
//
//                                                       dense: true,
//                                                       contentPadding:
//                                                       const EdgeInsets.all(
//                                                         0,
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                     ),
//                                                     child: Text(
//                                                       product.ean,
//                                                       style: Typographyy
//                                                           .bodyLargeSemiBold
//                                                           .copyWith(
//                                                         color:
//                                                         notifire
//                                                             .getTextColor,
//                                                       ),
//                                                       overflow:
//                                                       TextOverflow
//                                                           .ellipsis,
//                                                     ),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                     ),
//                                                     child: Center(
//                                                       child: Text(
//                                                         product.observation,
//                                                         style: Typographyy
//                                                             .bodyLargeSemiBold
//                                                             .copyWith(
//                                                           color:
//                                                           notifire
//                                                               .getTextColor,
//                                                         ),
//                                                         overflow:
//                                                         TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                     ),
//                                                     child: Text(
//                                                       NumberFormat.simpleCurrency(
//                                                         locale: 'pt-BR',
//                                                       ).format(
//                                                         product.basePrice! /
//                                                             100,
//                                                       ),
//                                                       style: Typographyy
//                                                           .bodyLargeExtraBold
//                                                           .copyWith(
//                                                         color:
//                                                         notifire
//                                                             .getTextColor,
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                     ),
//                                                     child: Text(
//                                                       product.stockQuantity
//                                                           .toString(),
//
//                                                       style: Typographyy
//                                                           .bodyLargeSemiBold
//                                                           .copyWith(
//                                                         color:
//                                                         notifire
//                                                             .getTextColor,
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 20,
//                                                     ),
//                                                     child: Text(
//                                                       product.ean,
//                                                       style: Typographyy
//                                                           .bodyLargeSemiBold
//                                                           .copyWith(
//                                                         color:
//                                                         notifire
//                                                             .getTextColor,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                     const EdgeInsets.symmetric(
//                                                       vertical: 10,
//                                                     ),
//                                                     child: Center(
//                                                       child: Container(
//                                                         height: 40,
//                                                         width: 96,
//                                                         decoration: BoxDecoration(
//                                                           borderRadius:
//                                                           BorderRadius.circular(
//                                                             8,
//                                                           ),
//                                                           color:
//                                                           product.available
//                                                               ? Colors
//                                                               .green
//                                                               .withOpacity(
//                                                             0.10,
//                                                           )
//                                                               : Colors
//                                                               .red
//                                                               .withOpacity(
//                                                             0.10,
//                                                           ),
//                                                         ),
//                                                         child: Center(
//                                                           child: Text(
//                                                             product.available
//                                                                 ? "Ativo"
//                                                                 : "Inativo",
//                                                             style: Typographyy
//                                                                 .bodyMediumMedium
//                                                                 .copyWith(
//                                                               color:
//                                                               product.available
//                                                                   ? Colors.green
//                                                                   : Colors.red,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _filters() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         fixedSize: const Size.fromHeight(42),
//         backgroundColor: notifire.getBgColor,
//         side: BorderSide(color: notifire.getGry700_300Color),
//       ),
//       onPressed: () {},
//       child: Row(
//         children: [
//           SvgPicture.asset(
//             "assets/images/Filter.svg",
//             height: 20,
//             width: 20,
//             color: notifire.getTextColor,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "Filters",
//             style: Typographyy.bodyMediumExtraBold.copyWith(
//               color: notifire.getTextColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget dataColumn1({required String title, required bool iscenter}) {
//     return Row(
//       mainAxisAlignment:
//       iscenter ? MainAxisAlignment.center : MainAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Typographyy.bodyLargeExtraBold.copyWith(
//             color: notifire.getGry500_600Color,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRow({required String iconpath, required String title}) {
//     return Row(
//       children: [
//         SvgPicture.asset(
//           iconpath,
//           width: 20,
//           height: 20,
//           color: notifire.getGry500_600Color,
//         ),
//         const SizedBox(width: 10),
//         Text(
//           title,
//           style: Typographyy.bodySmallSemiBold.copyWith(
//             color: notifire.getGry500_600Color,
//           ),
//         ),
//       ],
//     );
//   }
// }
