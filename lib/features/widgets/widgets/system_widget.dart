import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

enum SystemMetric { cpu, ram, battery, disk }

class SystemWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  final SystemMetric metric;
  const SystemWidget({super.key, required this.config, required this.metric});

  @override
  ConsumerState<SystemWidget> createState() => _SystemWidgetState();
}

class _SystemWidgetState extends ConsumerState<SystemWidget> {
  final List<double> _history = List.filled(30, 0);

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final sysAsync = ref.watch(systemInfoProvider);

    return sysAsync.when(
      loading: () => const Center(child: ProgressRing()),
      error: (_, __) => Center(
        child: Text('Unavailable',
            style: TextStyle(color: Color(theme.secondaryTextColor))),
      ),
      data: (sys) {
        double value;
        String label;
        Color color;
        String valueStr;

        switch (widget.metric) {
          case SystemMetric.cpu:
            value = sys.cpuPercent.toDouble();
            label = 'CPU';
            valueStr = '${sys.cpuPercent}%';
            color = value > 80 ? Colors.red.normal : Color(theme.accentColor);
            break;
          case SystemMetric.ram:
            value = sys.ramPercent;
            label = 'RAM';
            valueStr =
                '${sys.ramUsedMB}MB / ${sys.ramTotalMB}MB';
            color = value > 80 ? Colors.orange.normal : Color(theme.accentColor);
            break;
          case SystemMetric.battery:
            value = sys.batteryPercent.toDouble();
            label = sys.isCharging ? 'Battery (Charging)' : 'Battery';
            valueStr = '${sys.batteryPercent}%';
            color = value < 20
                ? Colors.red.normal
                : value < 40
                    ? Colors.orange.normal
                    : Colors.green.normal;
            break;
          case SystemMetric.disk:
            value = 0;
            label = 'Disk';
            valueStr = 'N/A';
            color = Color(theme.accentColor);
        }

        _history.removeAt(0);
        _history.add(value);

        final showGraph = widget.config.settings['showGraph'] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.round().toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                Text(
                  widget.metric == SystemMetric.ram ? 'MB' : '%',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(label,
                    style: TextStyle(
                      color: Color(theme.secondaryTextColor),
                      fontSize: 11,
                    )),
              ],
            ),
            const SizedBox(height: 4),
            Text(valueStr,
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: 10,
                )),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
            if (showGraph) ...[
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 29,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _history
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: color.withOpacity(0.7),
                        barWidth: 1.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
