import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChildManagementSection(),
            SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}

// ── 子ども管理セクション ──────────────────────────────────────

class _ChildManagementSection extends StatelessWidget {
  const _ChildManagementSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('子ども管理',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _AddChildDialog(),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...state.children.map((child) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.child_care, color: Color(0xFF4CAF50)),
                ),
                title: Text(child.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('総資産: ¥${formatYen(child.totalAssets)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => _RenameChildDialog(child: child),
                      ),
                    ),
                    if (state.children.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('子どもを削除'),
                            content: Text('「${child.name}」のデータをすべて削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AppState>().deleteChild(child);
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('削除'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _AddChildDialog extends StatefulWidget {
  const _AddChildDialog();

  @override
  State<_AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<_AddChildDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('子どもを追加'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: '名前', hintText: '例: はなこ'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            context.read<AppState>().addChild(name);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class _RenameChildDialog extends StatefulWidget {
  final Child child;
  const _RenameChildDialog({required this.child});

  @override
  State<_RenameChildDialog> createState() => _RenameChildDialogState();
}

class _RenameChildDialogState extends State<_RenameChildDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.child.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('名前を変更'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: '名前'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return;
            context.read<AppState>().renameChild(widget.child, name);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('変更'),
        ),
      ],
    );
  }
}

// ── お仕事チェック待ちセクション ──────────────────────────────

class _ApprovalSection extends StatelessWidget {
  const _ApprovalSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final waitingAll = [
      for (final child in state.children)
        for (final job in child.waitingJobs) (child: child, job: job),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('お仕事チェック待ち',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (waitingAll.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${waitingAll.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (waitingAll.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  SizedBox(width: 8),
                  Text('チェック待ちはありません',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...waitingAll.map((item) => _JobApprovalCard(
              child: item.child, job: item.job)),
      ],
    );
  }
}

class _JobApprovalCard extends StatelessWidget {
  final Child child;
  final Job job;
  const _JobApprovalCard({required this.child, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(child.name,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4CAF50))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(job.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('¥${job.reward}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.read<AppState>().rejectJob(child, job),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red),
                    child: const Text('やり直し'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<AppState>().approveJob(child, job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('承認 ✓'),
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

// ── 購入申請セクション ────────────────────────────────────────

class _PurchaseRequestSection extends StatelessWidget {
  const _PurchaseRequestSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final requestsAll = [
      for (final child in state.children)
        for (final item in child.purchaseRequests) (child: child, item: item),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('購入申請',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (requestsAll.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${requestsAll.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (requestsAll.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('購入申請はありません',
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...requestsAll.map((r) => _PurchaseApprovalCard(
              child: r.child, item: r.item)),
      ],
    );
  }
}

class _PurchaseApprovalCard extends StatelessWidget {
  final Child child;
  final BucketItem item;
  const _PurchaseApprovalCard({required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canApprove = state.canApprovePurchase(child, item);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(child.name,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4CAF50))),
                ),
                const SizedBox(width: 8),
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('¥${formatYen(item.price)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
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
                    onPressed: () =>
                        context.read<AppState>().rejectPurchase(child, item),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('却下'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canApprove
                        ? () => context
                            .read<AppState>()
                            .approvePurchase(child, item)
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

class _MonthlyUpdateSection extends StatefulWidget {
  const _MonthlyUpdateSection();

  @override
  State<_MonthlyUpdateSection> createState() => _MonthlyUpdateSectionState();
}

class _MonthlyUpdateSectionState extends State<_MonthlyUpdateSection> {
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

  static const _urls = {
    'sp500': 'https://www.google.com/finance/quote/.INX:INDEXSP?hl=ja',
    'nasdaq100': 'https://www.google.com/finance/quote/NDX:INDEXNASDAQ?hl=ja',
    'nikkei225': 'https://www.google.com/finance/quote/NI225:INDEXNIKKEI?hl=ja',
    'topix': 'https://www.google.com/finance/quote/TOPIX:INDEXJPX?hl=ja',
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
      final val = double.tryParse(entry.value.text.trim());
      if (val != null) returns[entry.key] = val / 100;
    }
    context.read<AppState>().applyMonthlyReturns(returns);
    for (final c in _controllers.values) {
      c.clear();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('月次更新を実行しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('月次更新',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // 銀行年利カード
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('銀行年利',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${state.bankAnnualInterestPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => _InterestRateDialog(
                            current: state.bankAnnualInterestPercent),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('変更'),
                    ),
                    const Spacer(),
                    Text(
                      '利息は月次更新で各子どもに加算',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 指数騰落率カード
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('指数騰落率',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const Text('「1M」を選ぶと月次騰落率が確認できます',
                    style: TextStyle(fontSize: 11, color: Colors.blue)),
                const SizedBox(height: 12),
                ..._labels.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(entry.value,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controllers[entry.key],
                              decoration: const InputDecoration(
                                suffixText: '%',
                                hintText: '0.0',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 18),
                            tooltip: '${entry.value}を調べる',
                            color: Colors.blue,
                            onPressed: () async {
                              final url = Uri.parse(_urls[entry.key]!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _apply,
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
        children: options
            .map((rate) => RadioListTile<double>(
                  title: Text('${rate.toStringAsFixed(1)}%'),
                  value: rate,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v!),
                ))
            .toList(),
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
            const Text('親ファンド管理',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              child: Text('ファンドがありません',
                  style: TextStyle(color: Colors.grey)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(fund.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fund.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(fund.description,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
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
              decoration: const InputDecoration(
                  labelText: 'ファンド名', hintText: '例: たろうスペシャル'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('絵文字',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis
                  .map((e) => GestureDetector(
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
                          child: Center(
                              child: Text(e,
                                  style: const TextStyle(fontSize: 22))),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('参照指数',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            ..._baseStockOptions.map((opt) => RadioListTile<String?>(
                  title: Text(opt.label,
                      style: const TextStyle(fontSize: 14)),
                  value: opt.id,
                  groupValue: _baseStockId,
                  onChanged: (v) => setState(() => _baseStockId = v),
                  dense: true,
                )),
            if (_baseStockId != null) ...[
              const SizedBox(height: 8),
              const Text('倍率',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _multiplierOptions
                    .map((m) => ChoiceChip(
                          label: Text('${m}x'),
                          selected: _multiplier == m,
                          onSelected: (_) =>
                              setState(() => _multiplier = m),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Text('月次ボーナス',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _bonusOptions
                  .map((b) => ChoiceChip(
                        label: Text(b == 0
                            ? 'なし'
                            : '+${b.toStringAsFixed(0)}%'),
                        selected: _bonusMonthlyPercent == b,
                        onSelected: (_) =>
                            setState(() => _bonusMonthlyPercent = b),
                      ))
                  .toList(),
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

class _JobManagementSection extends StatefulWidget {
  const _JobManagementSection();

  @override
  State<_JobManagementSection> createState() => _JobManagementSectionState();
}

class _JobManagementSectionState extends State<_JobManagementSection> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.children.isEmpty) return const SizedBox.shrink();

    if (_selectedChildIndex >= state.children.length) {
      _selectedChildIndex = 0;
    }
    final child = state.children[_selectedChildIndex];

    final allJobs = [
      ...child.doneJobs,
      ...child.waitingJobs,
      ...child.pendingJobs,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('お仕事管理',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (state.children.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.children.asMap().entries.map((e) {
                final selected = e.key == _selectedChildIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value.name),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedChildIndex = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ...allJobs.map((job) => _JobManagementRow(
                    child: child,
                    job: job,
                  )),
              ListTile(
                leading: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                title: const Text('お仕事を追加',
                    style: TextStyle(color: Color(0xFF4CAF50))),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => _AddJobDialog(child: child),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobManagementRow extends StatelessWidget {
  final Child child;
  final Job job;
  const _JobManagementRow({required this.child, required this.job});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    final (color, label) = switch (job.status) {
      JobStatus.done => (Colors.grey, '完了'),
      JobStatus.waitingApproval => (Colors.orange, 'チェック待ち'),
      JobStatus.pending => (const Color(0xFF4CAF50), '未完了'),
    };

    return ListTile(
      title: Text(job.title),
      subtitle: Text('¥${job.reward}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ),
          if (job.status == JobStatus.done)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
              tooltip: '未完了に戻す',
              onPressed: () => state.resetJob(child, job),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => state.deleteJob(child, job),
          ),
        ],
      ),
    );
  }
}

class _AddJobDialog extends StatefulWidget {
  final Child child;
  const _AddJobDialog({required this.child});

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('お仕事を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'お仕事名', hintText: '例: お皿洗い'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rewardController,
            decoration:
                const InputDecoration(labelText: '報酬（円）', hintText: '例: 50'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final reward = int.tryParse(_rewardController.text.trim());
            if (title.isEmpty || reward == null || reward <= 0) return;
            context.read<AppState>().addJob(widget.child, title, reward);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          child: const Text('追加'),
        ),
      ],
    );
  }
}

// ── 子どもの資産一覧 ─────────────────────────────────────────

class _ChildrenAssetsSection extends StatelessWidget {
  const _ChildrenAssetsSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('子どもの資産一覧',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...state.children.map((child) {
          final gain = child.gainLoss;
          final gainColor = gain >= 0 ? const Color(0xFF4CAF50) : Colors.red;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(child.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('¥${formatYen(child.totalAssets)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${gain >= 0 ? '+' : ''}¥${formatYen(gain)}',
                        style: TextStyle(fontSize: 13, color: gainColor),
                      ),
                      const SizedBox(width: 12),
                      Text('銀行 ¥${formatYen(child.bankBalance)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text('証券 ¥${formatYen(child.stocksValue)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
