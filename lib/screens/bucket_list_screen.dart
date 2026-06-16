import 'package:flutter/material.dart';

class BucketListScreen extends StatelessWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ほしいものリスト'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _BucketItem(name: 'レゴ スターウォーズ', price: 8000, currentAssets: 12500, emoji: '🧱'),
          SizedBox(height: 12),
          _BucketItem(name: 'Nintendo Switch2', price: 6000, currentAssets: 12500, emoji: '🎮'),
          SizedBox(height: 12),
          _BucketItem(name: '図鑑 恐竜', price: 2200, currentAssets: 12500, emoji: '📚'),
          SizedBox(height: 12),
          _BucketItem(name: '自転車', price: 30000, currentAssets: 12500, emoji: '🚲'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BucketItem extends StatelessWidget {
  final String name;
  final int price;
  final int currentAssets;
  final String emoji;

  const _BucketItem({required this.name, required this.price, required this.currentAssets, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final progress = (currentAssets / price).clamp(0.0, 1.0);
    final canBuy = currentAssets >= price;
    final remaining = price - currentAssets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('¥${_formatPrice(price)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                if (canBuy)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('購入申請'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: canBuy ? const Color(0xFF4CAF50) : Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  canBuy ? '🎉 購入できます！' : 'あと ¥${_formatPrice(remaining)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: canBuy ? const Color(0xFF4CAF50) : Colors.grey,
                    fontWeight: canBuy ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
