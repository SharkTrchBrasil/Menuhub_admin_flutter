// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';
import 'package:kanban_board/custom/board.dart';
import 'package:kanban_board/models/inputs.dart';






class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final List<List<_Order>> columns = [
    [ _Order('Pedido #001', Colors.deepOrange.shade400)],
    [ _Order('Pedido #002', Colors.blue.shade400)],
    [ _Order('Pedido #003', Colors.green.shade400)],
  ];

  void moveToNextColumn(int columnIndex, int itemIndex) {
    if (columnIndex < columns.length - 1) {
      final item = columns[columnIndex].removeAt(itemIndex);
      setState(() {
        columns[columnIndex + 1].add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: KanbanBoard(


        displacementX: 0,
        displacementY: 100,
        [
          _buildBoardColumn(0, 'Em Análise'),
          _buildBoardColumn(1, 'Em Produção'),
          _buildBoardColumn(2, 'Pronto para Entrega'),
        ],
      ),
    );
  }

  BoardListsData _buildBoardColumn(int index, String title) {
    return BoardListsData(
      title: title,
      header: Container(
        height: 30,
        alignment: Alignment.center,
        color: Colors.grey.shade300,
        child: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      items: List.generate(columns[index].length, (itemIndex) {
        final order = columns[index][itemIndex];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: order.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (index < 2)
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  onPressed: () => moveToNextColumn(index, itemIndex),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Order {
  final String title;
  final Color color;
  _Order(this.title, this.color);
}

//
// class BoardViewExample extends StatelessWidget {
//
//
//
//   final List<BoardListObject> _listData = [
//     BoardListObject(title: "Todo", items: [
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//     ]),
//     BoardListObject(title: "Inprogress", items: [
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//     ]),
//     BoardListObject(title: "Onhold", items: [
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//     ]),
//     BoardListObject(title: "Completed", items: [
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//       BoardItemobject(title: "Angular 5 material\nLorem ipsum,dapibus ac facilsis\nin,egestas eget quam.interger\nposuere erat aassg."),
//     ]),
//   ];
//
//
//
//   //Can be used to animate to different sections of the BoardView
//   BoardViewController boardViewController = BoardViewController();
//
//   BoardViewExample({super.key});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     List<BoardList> lists = [];
//     for (int i = 0; i < _listData.length; i++) {
//       lists.add(_createBoardList(_listData[i]) as BoardList);
//     }
//     return BoardView(
//       lists: lists,
//       width: 400,
//       boardViewController: boardViewController,
//     );
//   }
//
//   Widget buildBoardItem(BoardItemobject itemObject,int index) {
//     return  BoardItem(
//           onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState? state) {
//           },
//           onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex, int? oldItemIndex, BoardItemState? state) {
//             //Used to update our local item data
//             var item = _listData[oldListIndex!].items[oldItemIndex!];
//             _listData[oldListIndex].items.removeAt(oldItemIndex);
//             _listData[listIndex!].items.insert(itemIndex!, item);
//
//           },
//           onTapItem: (int? listIndex, int? itemIndex, BoardItemState? state) async {
//           },
//           item: Card(
//             shape: OutlineInputBorder(
//               borderSide: const BorderSide(color: Colors.white),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color:  index ==2 ? const Color(0xffE6FFFA) : index   ==3 ? const Color(0xffFDEDE8) : index ==4 ? const Color(0xffFEF5E5) : index ==5 ? const Color(0xffECF2FF) : index ==3 ?  Colors.deepPurple : Colors.pink ,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(itemObject.title),
//                 ),
//                 const Row(
//                   children: [
//                     SizedBox(width: 10,),
//                     Stack(
//                       children: [
//                         CircleAvatar(backgroundImage: AssetImage('assets/avatar-1 11.png'),radius: 15,),
//                         Padding(
//                           padding: EdgeInsets.only(left: 20),
//                           child: CircleAvatar(backgroundImage: AssetImage('assets/avatar-3 2c.png'),radius: 15,),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 40),
//                           child: CircleAvatar(backgroundImage: AssetImage('assets/avatar-2 11.png'),radius: 15,),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 60),
//                           child: CircleAvatar(backgroundImage: AssetImage('assets/avatar-4 2m.png'),radius: 15,),
//                         ),
//                       ],
//                     ),
//                     Spacer(),
//                     Image(image: AssetImage('assets/trash (1).png'),height: 20,width: 20,),
//                     SizedBox(width: 15,),
//                   ],
//                 ),
//                 const SizedBox(height: 10,),
//               ],
//             ),
//           ),
//     );
//   }
//
//   Widget _createBoardList(BoardListObject list) {
//
//     List<BoardItem> items = [];
//     for (int i = 0; i < list.items.length; i++) {
//       items.insert(i, buildBoardItem(list.items[i],list.items.length) as BoardItem);
//     }
//
//     return BoardList(
//       onStartDragList: (int? listIndex) {
//       },
//       onTapList: (int? listIndex) async {
//
//       },
//       onDropList: (int? listIndex, int? oldListIndex) {
//         //Update our local list data
//         var list = _listData[oldListIndex!];
//         _listData.removeAt(oldListIndex);
//         _listData.insert(listIndex!, list);
//       },
//       headerBackgroundColor: items.length ==2 ? const Color(0xff13DEB9) : items.length ==3 ? const Color(0xffFA896B) : items.length ==4 ? const Color(0xffFFAE1F) : items.length ==5 ? const Color(0xff5D87FF) : items.length ==3 ?  Colors.deepPurple : Colors.pink ,
//       boardView: BoardViewState(),
//       backgroundColor: Colors.white,
//       header: [
//         Expanded(
//             child: Padding(
//                 padding: const EdgeInsets.all(5),
//                 child: Center(
//                   child: Text(
//                     list.title,
//                     style: const TextStyle(fontSize: 15,color: Colors.white),
//                   ),
//                 ))),
//       ],
//       items: items,
//     );
//   }
// }
//
//
//
//
//
//
//
//
// class BoardListObject{
//   String title;
//   List<BoardItemobject> items;
//   BoardListObject({required this.title, required this.items});
// }
//
// class BoardItemobject{
//   late String title;
//   late String from;
//   BoardItemobject({this.title = '',this.from = ''});
//
// }