import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
            _BankCard(balance: state.bankBalance),
            const SizedBox(height: 16),
            _StocksCard(stocks: state.stocks, total: state.stocksValue),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final int balance;
  const _BankCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final monthlyInterest = (balance * 0.01 / 12).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue),
                SizedBox(width: 8),
                Text('銀行', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('お金を守る場所。利息がつくよ。', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('残高', style: TextStyle(fontSize: 14)),
                Text('¥${formatYen(balance)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('今月の利息', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('+¥$monthlyInterest', style: const TextStyle(fontSize: 13, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StocksCard extends StatelessWidget {
  final List<Stock> stocks;
  final int total;
  const _StocksCard({required this.stocks, required this.total});

  @override
  Widget build(BuildContext context) {
    final totalInvested = stocks.fold(0, (sum, s) => sum + s.invested);
    final totalGain = total - totalInvested;
    final totalGainPercent = totalInvested == 0 ? 0.0 : totalGain / totalInvested * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange),
                SizedBox(width: 8),
                Text('証券', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('世界の会社に投資できるよ。増えることも減ることもある。',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            ...stocks.map((s) => Column(
                  children: [
                    _StockRow(stock: s),
                    if (s != stocks.last) const Divider(),
                  ],
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('合計評価額', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('¥${formatYen(total)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('評価損益', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  '${totalGain >= 0 ? '+' : ''}¥${formatYen(totalGain)} (${totalGainPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    color: totalGain >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final Stock stock;
  const _StockRow({required this.stock});

  @override
  Widget build(BuildContext context) {
    final gainColor = stock.gain >= 0 ? const Color(0xFF4CAF50) : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(stock.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('¥${formatYen(stock.current)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (stock.invested > 0)
                Text(
                  '${stock.gain >= 0 ? '+' : ''}¥${formatYen(stock.gain)} (${stock.gainPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 12, color: gainColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
