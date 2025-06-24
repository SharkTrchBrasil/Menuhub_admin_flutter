import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';


import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/page_status.dart';


import '../../repositories/store_repository.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_toasts.dart';
import '../../widgets/mobileappbar.dart';
import '../base/BasePage.dart';

class OpeningHoursPage extends StatefulWidget {
  final int storeId;

  const OpeningHoursPage({super.key, required this.storeId});

  @override
  State<OpeningHoursPage> createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends State<OpeningHoursPage> {
  final StoreRepository storeHourRepository = getIt();
  final formKey = GlobalKey<FormState>();

  late final AppListController<StoreHour> hoursController =
  AppListController<StoreHour>(
    fetch: () => storeHourRepository.getHours(widget.storeId),
  );

  // Mapa fixo para guardar os horários agrupados por dia (0=Dom,1=Seg...)
  final Map<int, List<StoreHour>> _openingHours = {
    for (var i = 0; i < 7; i++) i: [],
  };

  final List<String> days = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];


  // Flag para saber se já atualizamos _openingHours com dados da API
  bool _loaded = false;

  bool hasAnySlot() {
    return _openingHours.values.any((slots) => slots.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();

    hoursController.addListener(() {
      final status = hoursController.status;

      if (status is PageStatusSuccess<List<StoreHour>> && !_loaded) {
        final loadedHours = status.data;

        setState(() {
          _loaded = true;
          for (var i = 0; i < 7; i++) {
            _openingHours[i] = [];
          }
          for (final hour in loadedHours) {
            if (hour.dayOfWeek != null) {
              _openingHours[hour.dayOfWeek!]!.add(hour);
            }
          }
        });
      }
    });


    hoursController.refresh();
  }

  void _updateOpeningHoursMap(List<StoreHour> hours) {
    setState(() {
      for (var i = 0; i < 7; i++) {
        _openingHours[i] = [];
      }
      for (final hour in hours) {
        if (hour.dayOfWeek != null) {
          _openingHours[hour.dayOfWeek!]!.add(hour);
        }
      }
      print('_openingHours atualizado: $_openingHours'); // Debug aqui
    });
  }

  bool _validateHours() {
    for (var weekday = 0; weekday < 7; weekday++) {
      final slots = _openingHours[weekday]!;
      for (final slot in slots) {
        if (slot.openingTime == null || slot.closingTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Horário inválido em ${days[weekday]}')),
          );
          return false;
        }

        final opening = slot.openingTime!;
        final closing = slot.closingTime!;
        final openingMinutes = opening.hour * 60 + opening.minute;
        final closingMinutes = closing.hour * 60 + closing.minute;

        if (openingMinutes >= closingMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Horário de abertura deve ser antes do fechamento em ${days[weekday]}')),
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _save() async {
    final l = showLoading();
    if (!_validateHours()) return;

    final allSlots = _openingHours.values
        .expand((slots) => slots)
        .where((slot) => slot.openingTime != null && slot.closingTime != null)
        .toList();

    if (allSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum horário válido para salvar.')),
      );
      return;
    }

    bool success = true;

    for (final slot in allSlots) {
      final result = await storeHourRepository.saveStoreHour(widget.storeId, slot);
      if (result.isLeft) {
        success = false;
        break;
      }
    }
    l();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horários salvos com sucesso!')),
      );
      _loaded = false; // Reset para permitir atualização do mapa
      await hoursController.refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os horários.')),
      );
    }
  }

  Future<void> _removeHourFromDatabase(int hourId) async {
    final l = showLoading();
    final result = await storeHourRepository.deleteStoreHour(widget.storeId, hourId);
    l();
    result.fold(
          (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover o horário.')),
        );
        //  print(error);
      },
          (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horário removido com sucesso.')),
        );
        _loaded = false; // Reset para recarregar os horários
        hoursController.refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BasePage(
        mobileAppBar: AppBarCustom(title:'Horários de funcionamento'),
        mobileBuilder: (BuildContext context) { return

          SingleChildScrollView(

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: _buildOpeningHoursList(),
                ),
              ],
            ),
          );

        //   AnimatedBuilder(
        //   animation: hoursController,
        //   builder: (_, __) {
        //
        //
        //     // ----------------------------------------
        //     return AppPageStatusBuilder<List<StoreHour>>(
        //       status: hoursController.status,
        //
        //       successBuilder: (_) {
        //         return SizedBox(
        //           width: MediaQuery.of(context).size.width < 600
        //               ? MediaQuery.of(context).size.width
        //               : MediaQuery.of(context).size.width * 0.7,
        //           child: ConstrainedBox(
        //             constraints: const BoxConstraints(maxWidth: 900),
        //             child: SingleChildScrollView(
        //               scrollDirection: Axis.vertical,
        //               child: Padding(
        //                 padding: const EdgeInsets.all(28.0),
        //                 child: _buildOpeningHoursList(),
        //               ),
        //             )
        //
        //
        //
        //
        //           ),
        //         );
        //       },
        //     );
        //   },
        // );





          },
        desktopBuilder: (BuildContext context) {     return Column(
          children: [
            FixedHeader(
              title: 'Horários de Funcionamento',
              actions: [
                AppPrimaryButton(
                  label: 'Salvar',
                  onPressed: _save,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: _buildOpeningHoursList(),
                ),
              ),
            ),
          ],
        ); },
        // floatingActionButton: !hasAnySlot()
        //     ? Padding(
        //   padding: const EdgeInsets.only(bottom: 18.0),
        //   child: FloatingActionButton(
        //     onPressed: () => _addSlot(0), // exemplo: adiciona para o dia atual
        //     tooltip: 'Novo horário',
        //     child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
        //   ),
        // )
        //     : null,
        mobileBottomNavigationBar: hasAnySlot()
            ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppPrimaryButton(
            label: 'Salvar',
            onPressed: _save,
          ),
        )
            : null,



      ),
    );
  }

// ... código anterior ...

  Widget _buildOpeningHoursList() {

    int crossAxisCount = 1;
    if (MediaQuery.of(context).size.width >= 1200) {
      crossAxisCount = 3;
    } else if (MediaQuery.of(context).size.width >= 800) {
      crossAxisCount = 2;
    } else if (MediaQuery.of(context).size.width >= 600) {
      crossAxisCount = 1;
    } else {
      crossAxisCount = 1;
    }



    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {


                return Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 7, // 7 dias da semana

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: 220,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                      itemBuilder: (context, weekday) {
                        final slots = _openingHours[weekday] ?? [];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                days[weekday],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Aqui começa o scroll limitado dos slots
                              Expanded(
                                child: slots.isEmpty
                                    ? const Center(child: Text('Sem turnos cadastrados'))
                                    : ListView.builder(
                                  itemCount: slots.length,
                                  itemBuilder: (context, index) =>
                                      _buildSlotTile(slots[index], weekday, index),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue.shade800,
                                  ),
                                  onPressed: () => _addSlot(weekday),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Adicionar'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

  }

// ... restante do seu código ...

  Widget _buildSlotTile(StoreHour slot, int weekday, int index) {
    return ListTile(
      title: Row(
        children: [
          _timeButton(slot.openingTime, (t) => _updateOpeningTime(weekday, index, t)),
          const Text(' – '),
          _timeButton(slot.closingTime, (t) => _updateClosingTime(weekday, index, t)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          // Verifica se o slot tem um ID antes de tentar remover do banco
          if (slot.id != null) {
            _removeHourFromDatabase(slot.id!);
          } else {
            // Se o slot não tem ID, significa que ele ainda não foi salvo no banco
            // Podemos apenas removê-lo da lista local
            _removeLocalSlot(weekday, index);
          }
        },
      ),
    );
  }

  Widget _timeButton(TimeOfDay? time, ValueChanged<TimeOfDay> onPicked) {
    return TextButton(
      child: Text(time?.format(context) ?? 'Selecionar'),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  void _addSlot(int weekday) {
    setState(() {
      _openingHours[weekday]!.add(
        StoreHour(
          dayOfWeek: weekday,
          openingTime: const TimeOfDay(hour: 9, minute: 0),
          closingTime: const TimeOfDay(hour: 18, minute: 0),
          shiftNumber: _openingHours[weekday]!.length + 1,
          isActive: true,
        ),
      );
    });
  }

  void _updateOpeningTime(int weekday, int index, TimeOfDay newTime) {
    setState(() {
      final slot = _openingHours[weekday]![index];
      _openingHours[weekday]![index] = slot.copyWith(openingTime: newTime);
    });
  }

  void _updateClosingTime(int weekday, int index, TimeOfDay newTime) {
    setState(() {
      final slot = _openingHours[weekday]![index];
      _openingHours[weekday]![index] = slot.copyWith(closingTime: newTime);
    });
  }



  void _removeLocalSlot(int weekday, int index) {
    setState(() {
      _openingHours[weekday]!.removeAt(index);
    });
  }
}