import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/peak_hours.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'summary_item.dart';

class ActionAndSummaryPanel extends StatelessWidget {
  final Map<int, List<StoreHour>> openingHours;

  const ActionAndSummaryPanel({super.key, required this.openingHours});

  // ✅ NOVA FUNÇÃO PARA FORMATAR A DURAÇÃO DE FORMA INTELIGENTE
  String _formatTotalHours(double totalHours) {
    if (totalHours <= 0) return "0h";

    final int hours = totalHours.truncate();
    final int minutes = ((totalHours - hours) * 60).round();

    if (minutes == 0) {
      return '${hours}h'; // Ex: 4.0 -> "4h"
    }
    if (hours == 0) {
      return '${minutes}m'; // Ex: 0.5 -> "30m"
    }
    // Ex: 4.5 -> "4h30m"
    return '${hours}h${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) {
          return const Card(
            child: SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final peakHours = state.activeStore!.relations.peakHours;
        double totalHours = 0;
        double peakLunchHours = 0;
        double peakDinnerHours = 0;

        // --- Cálculos (permanecem os mesmos) ---
        openingHours.values.expand((e) => e).forEach((slot) {
          if (slot.openingTime != null && slot.closingTime != null) {
            final start =
                slot.openingTime!.hour + slot.openingTime!.minute / 60.0;
            final end =
                slot.closingTime!.hour + slot.closingTime!.minute / 60.0;
            totalHours += (end - start);
          }
        });

        if (peakHours != null) {
          final lunchStart = peakHours.lunchPeakStart.hour +
              peakHours.lunchPeakStart.minute / 60.0;
          final lunchEnd =
              peakHours.lunchPeakEnd.hour + peakHours.lunchPeakEnd.minute / 60.0;
          final dinnerStart = peakHours.dinnerPeakStart.hour +
              peakHours.dinnerPeakStart.minute / 60.0;
          final dinnerEnd = peakHours.dinnerPeakEnd.hour +
              peakHours.dinnerPeakEnd.minute / 60.0;

          openingHours.values.expand((e) => e).forEach((slot) {
            if (slot.openingTime != null && slot.closingTime != null) {
              final slotStart =
                  slot.openingTime!.hour + slot.openingTime!.minute / 60.0;
              final slotEnd =
                  slot.closingTime!.hour + slot.closingTime!.minute / 60.0;

              double lunchOverlap = (slotEnd.clamp(lunchStart, lunchEnd) -
                  slotStart.clamp(lunchStart, lunchEnd))
                  .clamp(0.0, double.infinity);
              peakLunchHours += lunchOverlap;

              double dinnerOverlap = (slotEnd.clamp(dinnerStart, dinnerEnd) -
                  slotStart.clamp(dinnerStart, dinnerEnd))
                  .clamp(0.0, double.infinity);
              peakDinnerHours += dinnerOverlap;
            }
          });
        }
        // --- Fim dos Cálculos ---

        final isMobile = MediaQuery.of(context).size.width < 720;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[300]!)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? _buildMobileLayout(totalHours, peakHours, peakLunchHours, peakDinnerHours)
                : _buildDesktopLayout(totalHours, peakHours, peakLunchHours, peakDinnerHours),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(double totalHours, PeakHours? peakHours, double peakLunchHours, double peakDinnerHours) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(totalHours),
                label: "Totais na semana"),
            const SizedBox(height: 36),
            peakHours == null
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(peakLunchHours),
                label: "Pico Diurno",
                hasWarning: peakLunchHours < 2),
            const SizedBox(height: 36),
            peakHours == null
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(peakDinnerHours),
                label: "Pico Noturno",
                hasWarning: peakDinnerHours < 2)
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(double totalHours, PeakHours? peakHours, double peakLunchHours, double peakDinnerHours) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(totalHours),
                label: "Totais na semana"),
            peakHours == null
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(peakLunchHours),
                label: "No pico de almoço",
                hasWarning: peakLunchHours < 2),
            peakHours == null
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : SummaryItem(
              // ✅ USA A NOVA FORMATAÇÃO
                value: _formatTotalHours(peakDinnerHours),
                label: "No pico de janta",
                hasWarning: peakDinnerHours < 2),
          ],
        ),
      ],
    );
  }
}