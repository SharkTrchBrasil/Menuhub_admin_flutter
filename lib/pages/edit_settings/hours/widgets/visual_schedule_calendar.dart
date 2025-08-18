// lib/pages/opening_hours/widgets/visual_schedule_calendar.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/models/store_hour.dart';

class VisualScheduleCalendar extends StatefulWidget {
  final Map<int, List<StoreHour>> openingHours;
  final Map<int, String> dayNames;
  final List<int> displayOrder;
  final Function(StoreHour) onShiftTap;
  final Function(int, TimeOfDay) onEmptySpaceTap;

  const VisualScheduleCalendar({
    super.key,
    required this.openingHours,
    required this.dayNames,
    required this.displayOrder,
    required this.onShiftTap,
    required this.onEmptySpaceTap,
  });

  @override
  State<VisualScheduleCalendar> createState() => _VisualScheduleCalendarState();
}

class _VisualScheduleCalendarState extends State<VisualScheduleCalendar> {
  static const double _pixelsPerHour = 23.0;
  static const double _timeAxisWidth = 50.0;
  static const double _mobileBreakpoint = 800.0;

  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    final todayWeekday = DateTime.now().weekday % 7;
    _currentPageIndex = widget.displayOrder.indexOf(todayWeekday);
    if (_currentPageIndex == -1) {
      _currentPageIndex = 0;
    }
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ 2. NOVA FUNÇÃO PARA FORMATAR O TEMPO DE FORMA INTELIGENTE
  String _formatTotalHours(double totalHours) {
    if (totalHours <= 0) return '0h';

    final int hours = totalHours.truncate();
    final int minutes = ((totalHours - hours) * 60).round();

    if (minutes == 0) {
      return '${hours}h';
    }
    if (hours == 0) {
      return '${minutes}m';
    }
    return '${hours}h${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    // ✅ 3. LAYOUT UNIFICADO DENTRO DE UM ÚNICO CONTAINER
    // Isso resolve o problema da linha vertical que não se conectava.
    return Column(
      children: [

        // O cabeçalho agora está DENTRO do container principal
        isMobile ? _buildMobileDaySelector() : _buildDesktopHeaders(),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [

             // Divisor invisível para garantir a linha
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),


            ],
          ),
        ),
        SizedBox(height: 150,)

      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeAxis(),
        Expanded(
          child: Row(
            children: widget.displayOrder.asMap().entries.map((entry) {
              int index = entry.key;
              int dayIndex = entry.value;
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: index > 0
                        ? Border(left: BorderSide(color: Colors.grey[200]!))
                        : null,
                  ),
                  child: _buildDayScheduleGrid(
                    context,
                    dayIndex,
                    widget.openingHours[dayIndex]!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaders() {
    return Row(
      children: [
        const SizedBox(width: _timeAxisWidth),
        Expanded(
          child: Row(
            children: widget.displayOrder.asMap().entries.map((entry) {
              int index = entry.key;
              int dayIndex = entry.value;
              return Expanded(
                child: Container(

                  child: _buildDayHeader(
                    dayIndex,
                    widget.openingHours[dayIndex]!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeAxis(),
        Expanded(
          child: SizedBox(
            height: 24 * _pixelsPerHour,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.displayOrder.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final dayIndex = widget.displayOrder[index];
                return Container(
                  decoration: BoxDecoration(
                      border:
                      Border(left: BorderSide(color: Colors.grey[200]!))),
                  child: _buildDayScheduleGrid(
                      context, dayIndex, widget.openingHours[dayIndex]!),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDaySelector() {
    final int dayIndex = widget.displayOrder[_currentPageIndex];
    final List<StoreHour> slots = widget.openingHours[dayIndex]!;
    double totalOpenHours = slots.fold(0.0, (sum, slot) {
      if (slot.openingTime == null || slot.closingTime == null) return sum;
      return sum +
          (slot.closingTime!.toDouble() - slot.openingTime!.toDouble());
    });

    // ✅ 1. COR DINÂMICA (Laranja ou Verde)
    final Color totalHoursColor = totalOpenHours >= 4 ? Colors.green.shade700 : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            // ✅ FUNÇÃO RESTAURADA
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.dayNames[dayIndex]!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12,),
                Text('Aberta por',
                    style: TextStyle(color: totalHoursColor, fontSize: 13 )),

                if (totalOpenHours > 0)
                  Text(
                    _formatTotalHours(totalOpenHours),
                    style: TextStyle(
                      color: totalHoursColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Text('Fechado',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            // ✅ FUNÇÃO RESTAURADA
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(int dayIndex, List<StoreHour> slots) {
    double totalOpenHours = slots.fold(0.0, (sum, slot) {
      if (slot.openingTime == null || slot.closingTime == null) return sum;
      return sum +
          (slot.closingTime!.toDouble() - slot.openingTime!.toDouble());
    });

    // ✅ 1. COR DINÂMICA (Laranja ou Verde)
    final Color totalHoursColor = totalOpenHours >= 4 ? Colors.green.shade700 : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      width: double.infinity,
      child: Column(
        children: [
          Text(widget.dayNames[dayIndex]!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12,),
          Text('Aberta por',
              style: TextStyle(color: totalHoursColor, fontSize: 13 )),

          if (totalOpenHours > 0)
            Text(
              _formatTotalHours(totalOpenHours), // ✅ 2. USA A NOVA FORMATAÇÃO
              style: TextStyle(
                color: totalHoursColor, // ✅ 1. USA A COR DINÂMICA
                fontSize: 12,

              ),
            )
          else
            const Text('Fechado',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // O restante do código (buildDayScheduleGrid, buildTimeAxis, buildShiftBlock) permanece o mesmo.
  Widget _buildDayScheduleGrid(
      BuildContext context, int dayIndex, List<StoreHour> slots) {
    final List<Widget> gridLines = [];
    for (int hour = 2; hour <= 22; hour += 2) {
      gridLines.add(
        Positioned(
          top: hour * _pixelsPerHour,
          left: 0,
          right: 0,
          child: Container(height: 1, color: Colors.grey[100]),
        ),
      );
    }
    return SizedBox(
      height: 24 * _pixelsPerHour,
      // ✅ O Stack agora é o widget principal, sem o GestureDetector em volta.
      child: Stack(
        children: [
          // ✅ O GestureDetector para o espaço vazio é o PRIMEIRO FILHO (o do fundo).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                double hourFraction = details.localPosition.dy / _pixelsPerHour;
                int hour = hourFraction.floor();
                int minute = ((hourFraction - hour) * 60).round();
                widget.onEmptySpaceTap(
                    dayIndex, TimeOfDay(hour: hour, minute: minute));
              },
            ),
          ),
          // As linhas do grid vêm a seguir...
          ...gridLines,
          // ✅ Os blocos de horário são os ÚLTIMOS FILHOS (ficam por cima de tudo).
          ...slots.map((slot) => _buildShiftBlock(context, slot)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeAxis() {
    return SizedBox(
      width: _timeAxisWidth,
      child: Column(
        children: List.generate(25, (hour) {
          final String label = (hour == 24) ? '0h' : '${hour}h';
          return Container(
            height: _pixelsPerHour,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            child: hour % 2 == 0
                ? Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12))
                : null,
          );
        }),
      ),
    );
  }

  Widget _buildShiftBlock(BuildContext context, StoreHour slot) {
    if (slot.openingTime == null || slot.closingTime == null)
      return const SizedBox.shrink();
    final top = slot.openingTime!.toDouble() * _pixelsPerHour;
    final height =
        (slot.closingTime!.toDouble() - slot.openingTime!.toDouble()) *
            _pixelsPerHour;
    final minHeight = 20.0;
    final displayHeight = height < minHeight ? minHeight : height;
    return Positioned(
      top: top,
      left: 8,
      right: 8,
      height: displayHeight,
      child: Material(
        color: Colors.blue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.blue[300]!),
        ),
        child: InkWell(
          onTap: () => widget.onShiftTap(slot),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '${slot.openingTime!.format(context)} - ${slot.closingTime!.format(context)}',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}