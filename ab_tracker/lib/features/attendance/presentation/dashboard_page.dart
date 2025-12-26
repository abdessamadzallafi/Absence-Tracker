import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/stat_card.dart';
import 'dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (s) {
          final total = s.total == 0 ? 1 : s.total;

          return LayoutBuilder(
            builder: (context, c) {
              final isTablet = c.maxWidth > 720;
              final chart = PieChart(
                PieChartData(
                  centerSpaceRadius: 42,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                        value: s.present.toDouble(), title: 'Présent'),
                    PieChartSectionData(
                        value: s.absent.toDouble(), title: 'Absent'),
                    PieChartSectionData(
                        value: s.justified.toDouble(), title: 'Justifié'),
                  ],
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      StatCard(
                          title: 'Taux de présence',
                          value: '${s.presenceRate.toStringAsFixed(1)}%'),
                      StatCard(title: 'Présents', value: '${s.present}'),
                      StatCard(title: 'Absents', value: '${s.absent}'),
                      StatCard(title: 'Justifiés', value: '${s.justified}'),
                      StatCard(title: 'Total marquages', value: '$total'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: isTablet
                            ? Row(
                                children: [
                                  Expanded(child: chart),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Les statistiques se basent sur les lignes enregistrées dans la table absences.\n'
                                      'Crée des séances et fais le marquage pour voir les chiffres évoluer.',
                                    ),
                                  ),
                                ],
                              )
                            : chart,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
