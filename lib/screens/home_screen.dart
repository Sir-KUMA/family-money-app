import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalAssetsCard(state: state),
            const SizedBox(height: 16),
            _AssetBreakdownCard(state: state),
            const SizedBox(height: 16),
            _TodayJobsCard(count: state.pendingJobs.length),
            const SizedBox(height: 16),
            const _GoalCard(),
          ],
        ),
      ),
    );
  }
}

class _TotalAssetsCard extends StatelessWidget {
  final AppState state;
  const _TotalAssetsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isPositive = state.gainLoss >= 0;
    return Card(
      color: const Color(0xFF4CAF50),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('総資産', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text('¥${formatYen(state.totalAssets)}',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white30, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AssetLabel(label: '元本', value: '¥${formatYen(state.principal)}'),
                _AssetLabel(
                  label: '評価損益',
                  value: '${isPositive ? '+' : ''}¥${formatYen(state.gainLoss)}',
                  isPositive: isPositive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _AssetLabel({required this.label, required this.value, this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: isPositive ? Colors.lightGreenAccent : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AssetBreakdownCard extends StatelessWidget {
  final AppState state;
  const _AssetBreakdownCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('内訳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _BreakdownRow(
                label: '銀行残高',
                value: '¥${formatYen(state.bankBalance)}',
                icon: Icons.account_balance,
                color: Colors.blue),
            const Divider(),
            _BreakdownRow(
                label: '証券評価額',
                value: '¥${formatYen(state.stocksValue)}',
                icon: Icons.trending_up,
                color: Colors.orange),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BreakdownRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TodayJobsCard extends StatelessWidget {
  final int count;
  const _TodayJobsCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.work, color: Color(0xFF4CAF50), size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('今日のお仕事', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(count > 0 ? '$count件 完了待ち' : 'すべて完了！',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('目標商品', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('レゴ スターウォーズ', style: TextStyle(fontSize: 14)),
                Spacer(),
                Text('¥8,000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF4CAF50),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            const Text('達成！購入できます 🎉', style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50))),
          ],
        ),
      ),
    );
  }
}
