import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

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
          children: const [
            _ApprovalSection(),
            SizedBox(height: 24),
            _PurchaseRequestSection(),
            SizedBox(height: 24),
            _JobManagementSection(),
            SizedBox(height: 24),
            _ChildrenAssetsSection(),
            SizedBox(height: 24),
            _FundsSection(),
          ],
        ),
      ),
    );
  }
}

class _ApprovalSection extends StatelessWidget {
  const _ApprovalSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final waiting = state.waitingJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('お仕事チェック待ち',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (waiting.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration:
                    BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text('${waiting.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (waiting.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  SizedBox(width: 8),
                  Text('チェック待ちはありません', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...waiting.map((job) => _ApprovalCard(job: job)),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final Job job;
  const _ApprovalCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF1565C0),
                  child: Text('た', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                const Text('たろう', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const Spacer(),
                Text('¥${job.reward}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => state.rejectJob(job),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('やり直し'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => state.approveJob(job),
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

class _PurchaseRequestSection extends StatelessWidget {
  const _PurchaseRequestSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final requests = state.purchaseRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('購入申請',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (requests.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration:
                    BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text('${requests.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  SizedBox(width: 8),
                  Text('購入申請はありません', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...requests.map((item) => _PurchaseRequestCard(item: item)),
      ],
    );
  }
}

class _PurchaseRequestCard extends StatelessWidget {
  final BucketItem item;
  const _PurchaseRequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canApprove = state.canApprovePurchase(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF1565C0),
                  child: Text('た', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                const Text('たろう', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const Spacer(),
                Text('¥${formatYen(item.price)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(item.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (!canApprove) ...[
              const SizedBox(height: 8),
              const Text('残高不足のため承認できません',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<AppState>().rejectPurchase(item),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('却下'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canApprove
                        ? () => context.read<AppState>().approvePurchase(item)
                        : null,
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

class _JobManagementSection extends StatelessWidget {
  const _JobManagementSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('お仕事管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _AddJobDialog(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.jobs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('お仕事がありません', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...[...state.doneJobs, ...state.waitingJobs, ...state.pendingJobs]
              .map((job) => _JobManagementCard(job: job)),
      ],
    );
  }
}

class _JobManagementCard extends StatelessWidget {
  final Job job;
  const _JobManagementCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (job.status) {
      JobStatus.pending => '未完了',
      JobStatus.waitingApproval => 'チェック待ち',
      JobStatus.done => '完了',
    };
    final statusColor = switch (job.status) {
      JobStatus.pending => Colors.grey,
      JobStatus.waitingApproval => Colors.orange,
      JobStatus.done => const Color(0xFF4CAF50),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('¥${job.reward}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (job.status != JobStatus.pending)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: '未完了に戻す',
                onPressed: () => context.read<AppState>().rejectJob(job),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('お仕事を削除'),
                  content: Text('「${job.title}」を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().deleteJob(job);
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
      ),
    );
  }
}

class _AddJobDialog extends StatefulWidget {
  const _AddJobDialog();

  @override
  State<_AddJobDialog> createState() => _AddJobDialogState();
}

class _AddJobDialogState extends State<_AddJobDialog> {
  final _titleController = TextEditingController();
  final _rewardController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final reward = int.tryParse(_rewardController.text.trim());
    if (title.isEmpty || reward == null || reward <= 0) return;

    context.read<AppState>().addJob(title, reward);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('お仕事を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'お仕事の名前', hintText: '例: お皿洗い'),
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rewardController,
            decoration: const InputDecoration(labelText: '報酬（円）', hintText: '例: 50'),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _submit(),
          ),
        ],
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

class _ChildrenAssetsSection extends StatelessWidget {
  const _ChildrenAssetsSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('子どもの資産', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ChildAssetCard(
          name: 'たろう',
          totalAssets: state.totalAssets,
          bank: state.bankBalance,
          stocks: state.stocksValue,
          gainLoss: state.gainLoss,
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
  final int gainLoss;

  const _ChildAssetCard({
    required this.name,
    required this.totalAssets,
    required this.bank,
    required this.stocks,
    required this.gainLoss,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = gainLoss >= 0;

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
                    Text('¥${formatYen(totalAssets)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      '${isPositive ? '+' : '-'}¥${formatYen(gainLoss)}',
                      style: TextStyle(
                          fontSize: 12, color: isPositive ? const Color(0xFF4CAF50) : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                const Text('銀行', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                Text('¥${formatYen(bank)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                const Text('証券', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                Text('¥${formatYen(stocks)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FundsSection extends StatelessWidget {
  const _FundsSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('準備資金', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('子どもたちが購入申請したときに必要な金額',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('子どもの総資産', style: TextStyle(fontSize: 14)),
                Text('¥${formatYen(state.totalAssets)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('不足額', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('¥0',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
