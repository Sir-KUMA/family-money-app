import 'package:flutter/material.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('親画面'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ApprovalSection(),
            const SizedBox(height: 24),
            _ChildrenAssetsSection(),
            const SizedBox(height: 24),
            _FundsSection(),
          ],
        ),
      ),
    );
  }
}

// 承認待ちセクション
class _ApprovalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('承認待ち', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ApprovalCard(
          childName: 'たろう',
          jobTitle: '部屋の掃除',
          reward: 100,
        ),
        const SizedBox(height: 8),
        _ApprovalCard(
          childName: 'はなこ',
          jobTitle: '洗濯物をたたむ',
          reward: 50,
        ),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String childName;
  final String jobTitle;
  final int reward;

  const _ApprovalCard({
    required this.childName,
    required this.jobTitle,
    required this.reward,
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
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(childName[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(childName, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const Spacer(),
                Text('¥$reward', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
              ],
            ),
            const SizedBox(height: 8),
            Text(jobTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('却下'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('承認'),
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

// 子ども別資産セクション
class _ChildrenAssetsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('子どもの資産', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ChildAssetCard(
          name: 'たろう',
          totalAssets: 12500,
          bank: 7500,
          stocks: 5000,
          gain: 2500,
          isPositive: true,
        ),
        const SizedBox(height: 8),
        _ChildAssetCard(
          name: 'はなこ',
          totalAssets: 8200,
          bank: 6000,
          stocks: 2200,
          gain: -300,
          isPositive: false,
        ),
      ],
    );
  }
}

class _ChildAssetCard extends StatelessWidget {
  final String name;
  final int totalAssets;
  final int bank;
  final int stocks;
  final int gain;
  final bool isPositive;

  const _ChildAssetCard({
    required this.name,
    required this.totalAssets,
    required this.bank,
    required this.stocks,
    required this.gain,
    required this.isPositive,
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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(name[0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('¥${_format(totalAssets)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      '${isPositive ? '+' : ''}¥${_format(gain)}',
                      style: TextStyle(fontSize: 12, color: isPositive ? const Color(0xFF4CAF50) : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            _MiniLabel(icon: Icons.account_balance, color: Colors.blue, label: '銀行', value: '¥${_format(bank)}'),
            const SizedBox(height: 8),
            _MiniLabel(icon: Icons.trending_up, color: Colors.orange, label: '証券', value: '¥${_format(stocks)}'),
          ],
        ),
      ),
    );
  }

  String _format(int value) {
    return value.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MiniLabel({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 準備資金セクション
class _FundsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('準備資金', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('子どもたちが購入申請したときに必要な金額', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('子どもの総資産合計', style: TextStyle(fontSize: 14)),
                Text('¥20,700', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('承認済み購入予定', style: TextStyle(fontSize: 14)),
                Text('¥8,000', style: TextStyle(fontSize: 14, color: Colors.orange)),
              ],
            ),
            const Divider(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('不足額', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('¥0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
