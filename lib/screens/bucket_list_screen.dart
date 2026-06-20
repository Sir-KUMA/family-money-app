import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

const _presetEmojis = [
  '🎮', '🧸', '📚', '🚲', '⚽', '🎸',
  '🎨', '🏊', '🍕', '🚗', '✈️', '🎁',
  '🤖', '🦄', '🍦', '🎯', '🎲', '🧩',
  '👟', '🎀', '🌈', '🐶', '🐱', '🦖',
];

class BucketListScreen extends StatelessWidget {
  final String childId;
  const BucketListScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(childId);

    return Scaffold(
      body: child.bucketItems.isEmpty
          ? const Center(
              child: Text('ほしいものを追加しよう！',
                  style: TextStyle(color: Colors.grey)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in child.bucketItems) ...[
                  _BucketItemCard(
                    childId: childId,
                    item: item,
                    currentAssets: child.totalAssets,
                    isRequested: child.isRequested(item),
                    isPurchased: child.isPurchased(item),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _AddBucketItemDialog(childId: childId),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BucketItemCard extends StatelessWidget {
  final String childId;
  final BucketItem item;
  final int currentAssets;
  final bool isRequested;
  final bool isPurchased;

  const _BucketItemCard({
    required this.childId,
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
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('¥${formatYen(item.price)}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                _ActionButton(
                  childId: childId,
                  item: item,
                  canBuy: canBuy,
                  isRequested: isRequested,
                  isPurchased: isPurchased,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('削除'),
                      content: Text('「${item.name}」を削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<AppState>()
                                .deleteBucketItem(
                                    context.read<AppState>().childById(childId),
                                    item);
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('削除'),
                        ),
                      ],
                    ),
                  ),
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
                      fontWeight:
                          canBuy ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text('${(progress * 100).toStringAsFixed(0)}%',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
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
  final String childId;
  final BucketItem item;
  final bool canBuy;
  final bool isRequested;
  final bool isPurchased;

  const _ActionButton({
    required this.childId,
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
        onPressed: () {
          final state = context.read<AppState>();
          state.requestPurchase(state.childById(childId), item);
        },
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

class _AddBucketItemDialog extends StatefulWidget {
  final String childId;
  const _AddBucketItemDialog({required this.childId});

  @override
  State<_AddBucketItemDialog> createState() => _AddBucketItemDialogState();
}

class _AddBucketItemDialogState extends State<_AddBucketItemDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedEmoji = '⭐';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.replaceAll(',', ''));
    if (name.isEmpty || price == null || price <= 0) return;
    final state = context.read<AppState>();
    state.addBucketItem(state.childById(widget.childId), name, price, _selectedEmoji);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ほしいものを追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: '名前', hintText: '例: レゴ'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                  labelText: '値段（円）', hintText: '例: 3,000'),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorFormatter()],
            ),
            const SizedBox(height: 16),
            const Text('絵文字', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetEmojis.map((emoji) {
                final selected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE8F5E9)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child:
                          Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          child: const Text('追加'),
        ),
      ],
    );
  }
}
