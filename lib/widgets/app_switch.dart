import 'package:flutter/material.dart';

class AppSwitch extends StatefulWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final Function(bool) onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {

  late bool value = widget.value;


  @override
  void didUpdateWidget(AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.value != widget.value) {
      setState(() {
        value = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onChanged(!value),
      child: AnimatedContainer(
        width: 70,
        height: 30,
        color: value ? Colors.blue.withAlpha(80) : Colors.red.withAlpha(10),
        padding: const EdgeInsets.all(4),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: const Duration(milliseconds: 200),
        child: LayoutBuilder(builder: (_, constraints) {
          return Container(
            color: value ? Colors.blue : Colors.red,
            width: constraints.maxWidth / 2,
            height: constraints.maxHeight,
          );
        }),
      ),
    );
  }
}
