import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

enum _Period { threeMonths, oneYear, all }

class HomeScreen extends StatefulWidget {
  final String childId;
  const HomeScreen({super.key, required this.childId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _Period _period = _Period.all;

  List<AssetSnapshot> _filter(List<AssetSnapshot> history) {
    if (history.isEmpty) return [];
    final now = DateTime.now();
    return switch (_period) {
      _Period.threeMonths =>
        history.where((s) => s.date.isAfter(now.subtract(const Duration(days: 90)))).toList(),
      _Period.oneYear =>
        history.where((s) => s.date.isAfter(now.subtract(const Duration(days: 365)))).toList(),
      _Period.all => history,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(widget.childId);
    final filtered = _filter(child.assetHistory);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalAssetsCard(child: child),
            const SizedBox(height: 16),
            _AssetGraphCard(
              history: filtered,
              period: _period,
              onPeriodChanged: (p) => setState(() => _period = p),
            ),
            const SizedBox(height: 16),
            _JobsCard(child: child),
          ],
        ),
      ),
    );
  }
}

class _TotalAssetsCard extends StatelessWidget {
  final Child child;
  const _TotalAssetsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final gain = child.gainLoss;
    final gainPercent =
        child.principal == 0 ? 0.0 : gain / child.principal * 100;
    final gainColor = gain >= 0 ? const Color(0xFF4CAF50) : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('総資産', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '¥${formatYen(child.totalAssets)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  gain >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: gainColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gain >= 0 ? '+' : ''}¥${formatYen(gain)} (${gainPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    color: gainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AssetChip(label: '銀行', value: child.bankBalance, color: Colors.blue),
                const SizedBox(width: 8),
                _AssetChip(label: '証券', value: child.stocksValue, color: Colors.orange),
                if (child.fundsValue > 0) ...[
                  const SizedBox(width: 8),
                  _AssetChip(label: '親ファンド', value: child.fundsValue, color: Colors.purple),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _AssetChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text(
            '¥${formatYen(value)}',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AssetGraphCard extends StatelessWidget {
  final List<AssetSnapshot> history;
  final _Period period;
  final ValueChanged<_Period> onPeriodChanged;

  const _AssetGraphCard({
    required this.history,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('資産推移',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                _PeriodChip(
                    label: '3ヶ月',
                    value: _Period.threeMonths,
                    current: period,
                    onTap: onPeriodChanged),
                const SizedBox(width: 4),
                _PeriodChip(
                    label: '1年',
                    value: _Period.oneYear,
                    current: period,
                    onTap: onPeriodChanged),
                const SizedBox(width: 4),
                _PeriodChip(
                    label: '全期間',
                    value: _Period.all,
                    current: period,
                    onTap: onPeriodChanged),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    '月次更新を実行するとグラフが表示されます',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(height: 200, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalAssets.toDouble()))
        .toList();

    final values = history.map((s) => s.totalAssets.toDouble());
    final minY = values.reduce(min);
    final maxY = values.reduce(max);
    final yRange = (maxY - minY).clamp(1000.0, double.infinity);
    final yPadding = yRange * 0.15;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '¥${formatYen(value.toInt())}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: history.length <= 6
                  ? 1
                  : (history.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= history.length) {
                  return const SizedBox.shrink();
                }
                final date = history[idx].date;
                return Text(
                  '${date.month}月',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (history.length - 1).toDouble(),
        minY: minY - yPadding,
        maxY: maxY + yPadding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4CAF50),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: history.length <= 12),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final _Period value;
  final _Period current;
  final ValueChanged<_Period> onTap;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF50) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _JobsCard extends StatelessWidget {
  final Child child;
  const _JobsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final pending = child.pendingJobs.length;
    final waiting = child.waitingJobs.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.work_outline, color: Color(0xFF4CAF50), size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('お仕事', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  pending > 0
                      ? '$pending件 完了待ち'
                      : waiting > 0
                          ? '$waiting件 チェック待ち'
                          : 'すべて完了！',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
