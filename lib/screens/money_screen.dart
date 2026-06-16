import 'package:flutter/material.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お金'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BankCard(),
            const SizedBox(height: 16),
            _StocksCard(),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.account_balance, color: Colors.blue),
                SizedBox(width: 8),
                Text('銀行', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('お金を守る場所。利息がつくよ。', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('残高', style: TextStyle(fontSize: 14)),
                Text('¥7,500', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('金利（年率）', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('1.0%', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('今月の利息', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('+¥6', style: TextStyle(fontSize: 13, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StocksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.orange),
                SizedBox(width: 8),
                Text('証券', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('世界の会社に投資できるよ。増えることも減ることもある。', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            const _StockRow(name: 'S&P500', description: 'アメリカの大きな会社500社のチーム', amount: '¥3,000', gain: '+¥250', gainPercent: '+9.1%', isPositive: true),
            const Divider(),
            const _StockRow(name: 'NASDAQ100', description: 'アメリカのすごい会社たちのチーム', amount: '¥2,000', gain: '+¥150', gainPercent: '+8.1%', isPositive: true),
            const Divider(),
            const _StockRow(name: '日経225', description: '日本の有名な会社225社のチーム', amount: '¥0', gain: '¥0', gainPercent: '0.0%', isPositive: true),
            const Divider(),
            const _StockRow(name: 'TOPIX', description: '日本の会社をたくさん集めたチーム', amount: '¥0', gain: '¥0', gainPercent: '0.0%', isPositive: true),
            const Divider(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('合計評価額', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('¥5,000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('評価損益', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('+¥400 (+8.7%)', style: TextStyle(fontSize: 13, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final String name;
  final String description;
  final String amount;
  final String gain;
  final String gainPercent;
  final bool isPositive;

  const _StockRow({
    required this.name,
    required this.description,
    required this.amount,
    required this.gain,
    required this.gainPercent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final gainColor = isPositive ? const Color(0xFF4CAF50) : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('$gain ($gainPercent)', style: TextStyle(fontSize: 12, color: gainColor)),
            ],
          ),
        ],
      ),
    );
  }
}
