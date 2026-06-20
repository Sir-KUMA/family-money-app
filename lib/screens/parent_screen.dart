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
            _MonthlyUpdateSection(),
            SizedBox(height: 24),
            _CustomFundManagementSection(),
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

// ── 月次更新セクション ────────────────────────────────────────

class _MonthlyUpdateSection extends StatelessWidget {
  const _MonthlyUpdateSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final interest = (state.bankBalance * state.bankAnnualInterestPercent / 100 / 12).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('月次更新', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('銀行年利', style: TextStyle(fontSize: 14)),
                    Row(
                      children: [
                        Text('${state.bankAnnualInterestPercent.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => _InterestRateDialog(
                              current: state.bankAnnualInterestPercent,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('変更'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('今月の利息（予定）: +¥${formatYen(interest)}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const _MonthlyUpdateDialog(),
                    ),
                    icon: const Icon(Icons.update),
                    label: const Text('月次更新を実行'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InterestRateDialog extends StatefulWidget {
  final double current;
  const _InterestRateDialog({required this.current});

  @override
  State<_InterestRateDialog> createState() => _InterestRateDialogState();
}

class _InterestRateDialogState extends State<_InterestRateDialog> {
  late double _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    const options = [0.5, 1.0, 2.0, 3.0, 5.0];

    return AlertDialog(
      title: const Text('銀行年利を設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((rate) => RadioListTile<double>(
          title: Text('${rate.toStringAsFixed(1)}%'),
          value: rate,
          groupValue: _selected,
          onChanged: (v) => setState(() => _selected = v!),
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AppState>().setBankInterestRate(_selected);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('設定'),
        ),
      ],
    );
  }
}

class _MonthlyUpdateDialog extends StatefulWidget {
  const _MonthlyUpdateDialog();

  @override
  State<_MonthlyUpdateDialog> createState() => _MonthlyUpdateDialogState();
}

class _MonthlyUpdateDialogState extends State<_MonthlyUpdateDialog> {
  final _controllers = {
    'sp500': TextEditingController(),
    'nasdaq100': TextEditingController(),
    'nikkei225': TextEditingController(),
    'topix': TextEditingController(),
  };

  static const _labels = {
    'sp500': 'S&P500',
    'nasdaq100': 'NASDAQ100',
    'nikkei225': '日経225',
    'topix': 'TOPIX',
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _apply() {
    final returns = <String, double>{};
    for (final entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text.replaceAll('%', '').trim());
      if (val != null) returns[entry.key] = val / 100;
    }
    context.read<AppState>().applyMonthlyReturns(returns);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('月次更新'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今月の指数リターンを入力してください',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Text('例: +2.3 または -1.5',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            ..._labels.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _controllers[entry.key],
                    decoration: InputDecoration(
                      labelText: entry.value,
                      suffixText: '%',
                      hintText: '0.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                  ),
                )),
            const Divider(),
            const Text('銀行利息も自動で加算されます',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _apply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('適用'),
        ),
      ],
    );
  }
}

// ── カスタムファンド管理セクション ────────────────────────────

class _CustomFundManagementSection extends StatelessWidget {
  const _CustomFundManagementSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('親ファンド管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _AddCustomFundDialog(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('作成'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.customFunds.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('ファンドがありません', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...state.customFunds.map((fund) => _CustomFundCard(fund: fund)),
      ],
    );
  }
}

class _CustomFundCard extends StatelessWidget {
  final CustomFund fund;
  const _CustomFundCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(fund.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fund.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(fund.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ファンドを削除'),
                  content: Text('「${fund.name}」を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().deleteCustomFund(fund);
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

class _AddCustomFundDialog extends StatefulWidget {
  const _AddCustomFundDialog();

  @override
  State<_AddCustomFundDialog> createState() => _AddCustomFundDialogState();
}

class _AddCustomFundDialogState extends State<_AddCustomFundDialog> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '💡';
  String? _baseStockId;
  double _multiplier = 1.0;
  double _bonusMonthlyPercent = 0.0;

  static const _baseStockOptions = [
    (id: null, label: 'なし（固定ボーナスのみ）'),
    (id: 'sp500', label: 'S&P500'),
    (id: 'nasdaq100', label: 'NASDAQ100'),
    (id: 'nikkei225', label: '日経225'),
    (id: 'topix', label: 'TOPIX'),
  ];

  static const _multiplierOptions = [0.5, 1.0, 2.0, 3.0];
  static const _bonusOptions = [0.0, 1.0, 3.0, 5.0];

  static const _emojis = [
    '💡', '🌟', '🚀', '🏆', '💎', '🌈',
    '🦁', '🐉', '🔥', '⚡', '🍀', '🎯',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_baseStockId == null && _bonusMonthlyPercent == 0) return;

    context.read<AppState>().addCustomFund(
          name: name,
          emoji: _selectedEmoji,
          baseStockId: _baseStockId,
          multiplier: _multiplier,
          bonusMonthlyPercent: _bonusMonthlyPercent,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ファンドを作成'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ファンド名', hintText: '例: たろうスペシャル'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('絵文字', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((e) => GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: e == _selectedEmoji
                            ? const Color(0xFFE8F5E9)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: e == _selectedEmoji
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('参照指数', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ..._baseStockOptions.map((opt) => RadioListTile<String?>(
                  title: Text(opt.label, style: const TextStyle(fontSize: 14)),
                  value: opt.id,
                  groupValue: _baseStockId,
                  onChanged: (v) => setState(() => _baseStockId = v),
                  dense: true,
                )),
            if (_baseStockId != null) ...[
              const SizedBox(height: 8),
              const Text('倍率', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _multiplierOptions.map((m) => ChoiceChip(
                      label: Text('${m}x'),
                      selected: _multiplier == m,
                      onSelected: (_) => setState(() => _multiplier = m),
                    )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Text('月次ボーナス', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _bonusOptions.map((b) => ChoiceChip(
                    label: Text(b == 0 ? 'なし' : '+${b.toStringAsFixed(0)}%'),
                    selected: _bonusMonthlyPercent == b,
                    onSelected: (_) => setState(() => _bonusMonthlyPercent = b),
                  )).toList(),
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
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('作成'),
        ),
      ],
    );
  }
}

// ── お仕事管理セクション ─────────────────────────────────────

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
