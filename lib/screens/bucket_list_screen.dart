import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

const _presetEmojis = [
  '🎮', '🧸', '📚', '🚲', '⚽', '🎸',
  '🎨', '🏊', '🍕', '🚗', '✈️', '🎁',
  '🤖', '🦄', '🍦', '🎯', '🎲', '🧩',
  '👟', '🎀', '🌈', '🐶', '🐱', '🦖',
];

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    if (int.tryParse(digits) == null) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
      body: state.bucketItems.isEmpty
          ? const Center(
              child: Text('ほしいものを追加しよう！', style: TextStyle(color: Colors.grey)),
            )
          : ListView(
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
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddBucketItemDialog(),
        ),
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
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
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
                            context.read<AppState>().deleteBucketItem(item);
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

class _AddBucketItemDialog extends StatefulWidget {
  const _AddBucketItemDialog();

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

    context.read<AppState>().addBucketItem(name, price, _selectedEmoji);
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
              decoration: const InputDecoration(labelText: '名前', hintText: '例: レゴ'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '値段（円）', hintText: '例: 3,000'),
              keyboardType: TextInputType.number,
              inputFormatters: [_ThousandsSeparatorFormatter()],
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
                      color: selected ? const Color(0xFFE8F5E9) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? const Color(0xFF4CAF50) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
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
