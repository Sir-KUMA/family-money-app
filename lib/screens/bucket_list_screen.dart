import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

class BucketListScreen extends StatelessWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ほしいものリスト'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in state.bucketItems) ...[
            _BucketItemCard(
              item: item,
              currentAssets: state.totalAssets,
              isRequested: state.isRequested(item),
              isPurchased: state.isPurchased(item),
            ),
            const SizedBox(height: 12),
          ],
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

class _BucketItemCard extends StatelessWidget {
  final BucketItem item;
  final int currentAssets;
  final bool isRequested;
  final bool isPurchased;

  const _BucketItemCard({
    required this.item,
    required this.currentAssets,
    required this.isRequested,
    required this.isPurchased,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentAssets / item.price).clamp(0.0, 1.0);
    final canBuy = currentAssets >= item.price;
    final remaining = item.price - currentAssets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('¥${formatYen(item.price)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                _ActionButton(
                  item: item,
                  canBuy: canBuy,
                  isRequested: isRequested,
                  isPurchased: isPurchased,
                ),
              ],
            ),
            if (!isPurchased) ...[
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
                    canBuy ? '🎉 購入できます！' : 'あと ¥${formatYen(remaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: canBuy ? const Color(0xFF4CAF50) : Colors.grey,
                      fontWeight: canBuy ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text('${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final BucketItem item;
  final bool canBuy;
  final bool isRequested;
  final bool isPurchased;

  const _ActionButton({
    required this.item,
    required this.canBuy,
    required this.isRequested,
    required this.isPurchased,
  });

  @override
  Widget build(BuildContext context) {
    if (isPurchased) {
      return const Chip(
        label: Text('購入済み', style: TextStyle(fontSize: 12)),
        backgroundColor: Color(0xFFE8F5E9),
        labelStyle: TextStyle(color: Color(0xFF4CAF50)),
      );
    }

    if (isRequested) {
      return const Chip(
        label: Text('申請中', style: TextStyle(fontSize: 12)),
        backgroundColor: Color(0xFFFFF3E0),
        labelStyle: TextStyle(color: Colors.orange),
      );
    }

    if (canBuy) {
      return ElevatedButton(
        onPressed: () => context.read<AppState>().requestPurchase(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text('購入申請'),
      );
    }

    return const SizedBox.shrink();
  }
}
