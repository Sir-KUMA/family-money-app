import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/format.dart';

class MoneyScreen extends StatelessWidget {
  final String childId;
  const MoneyScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(childId);

    final availableFunds = state.customFunds;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BankCard(
                childId: childId,
                balance: child.bankBalance,
                annualInterestPercent: state.bankAnnualInterestPercent),
            const SizedBox(height: 16),
            _StocksCard(childId: childId, stocks: child.stocks, total: child.stocksValue),
            if (availableFunds.isNotEmpty) ...[
              const SizedBox(height: 16),
              _CustomFundsCard(childId: childId, funds: availableFunds, positions: child.fundPositions),
            ],
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final String childId;
  final int balance;
  final double annualInterestPercent;
  const _BankCard({required this.childId, required this.balance, required this.annualInterestPercent});

  @override
  Widget build(BuildContext context) {
    final monthlyInterest = (balance * annualInterestPercent / 100 / 12).round();

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
            const Text('お金を守る場所。利息がつくよ。',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('残高',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('¥${formatYen(balance)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('金利（年率）', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('${annualInterestPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('今月の利息', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('+¥$monthlyInterest',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4CAF50))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _WithdrawalDialog(childId: childId),
                ),
                icon: const Icon(Icons.savings_outlined, size: 18),
                label: const Text('引き出し申請'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalDialog extends StatefulWidget {
  final String childId;
  const _WithdrawalDialog({required this.childId});

  @override
  State<_WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<_WithdrawalDialog> {
  final _amountController = TextEditingController();
  WithdrawalType _type = WithdrawalType.cash;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final state = context.read<AppState>();
    final child = state.childById(widget.childId);
    if (child.bankBalance < amount) return;
    state.requestWithdrawal(child, amount, _type);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('引き出し申請を送りました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(widget.childId);
    final amount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final canSubmit = amount > 0 && child.bankBalance >= amount;

    return AlertDialog(
      title: const Text('引き出し申請'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('銀行残高: ¥${formatYen(child.bankBalance)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '引き出す金額（円）',
              hintText: '例: 1,000',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorFormatter()],
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          const Text('種類', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: '💴 現金',
                  selected: _type == WithdrawalType.cash,
                  onTap: () => setState(() => _type = WithdrawalType.cash),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TypeChip(
                  label: '📱 電子マネー',
                  selected: _type == WithdrawalType.electronic,
                  onTap: () => setState(() => _type = WithdrawalType.electronic),
                ),
              ),
            ],
          ),
          if (amount > 0 && child.bankBalance < amount) ...[
            const SizedBox(height: 8),
            const Text('残高が不足しています',
                style: TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: canSubmit ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('申請する'),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.blue : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              )),
        ),
      ),
    );
  }
}

class _StocksCard extends StatelessWidget {
  final String childId;
  final List<Stock> stocks;
  final int total;
  const _StocksCard({required this.childId, required this.stocks, required this.total});

  @override
  Widget build(BuildContext context) {
    final totalInvested = stocks.fold(0, (sum, s) => sum + s.invested);
    final totalGain = total - totalInvested;
    final totalGainPercent =
        totalInvested == 0 ? 0.0 : totalGain / totalInvested * 100;

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
            const Text('合計',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 6),
            Row(
              children: [
                _StockStat(label: '元本', value: '¥${formatYen(totalInvested)}'),
                const SizedBox(width: 16),
                _StockStat(
                  label: '含み益',
                  value: totalInvested == 0
                      ? '—'
                      : '${totalGain >= 0 ? '+' : ''}¥${formatYen(totalGain)}',
                  sub: totalInvested == 0
                      ? null
                      : '(${totalGainPercent.toStringAsFixed(1)}%)',
                  valueColor: totalInvested == 0
                      ? Colors.grey
                      : (totalGain >= 0 ? const Color(0xFF4CAF50) : Colors.red),
                ),
                const Spacer(),
                _StockStat(
                  label: '評価額',
                  value: '¥${formatYen(total)}',
                  align: CrossAxisAlignment.end,
                  valueBold: true,
                  valueColor: Colors.orange,
                ),
              ],
            ),
            const Divider(height: 24),
            ...stocks.map((s) => Column(
                  children: [
                    _StockRow(childId: childId, stock: s),
                    if (s != stocks.last) const Divider(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final String childId;
  final Stock stock;
  const _StockRow({required this.childId, required this.stock});

  @override
  Widget build(BuildContext context) {
    final gainColor = stock.gain >= 0 ? const Color(0xFF4CAF50) : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(stock.description,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _InvestDialog(childId: childId, stock: stock),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('投資する', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StockStat(label: '元本', value: '¥${formatYen(stock.invested)}'),
              const SizedBox(width: 16),
              _StockStat(
                label: '含み益',
                value: stock.invested == 0
                    ? '—'
                    : '${stock.gain >= 0 ? '+' : ''}¥${formatYen(stock.gain)}',
                sub: stock.invested == 0
                    ? null
                    : '(${stock.gainPercent.toStringAsFixed(1)}%)',
                valueColor: stock.invested == 0 ? Colors.grey : gainColor,
              ),
              const Spacer(),
              _StockStat(
                label: '評価額',
                value: '¥${formatYen(stock.current)}',
                align: CrossAxisAlignment.end,
                valueBold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomFundsCard extends StatelessWidget {
  final String childId;
  final List<CustomFund> funds;
  final List<ChildFundPosition> positions;
  const _CustomFundsCard(
      {required this.childId, required this.funds, required this.positions});

  @override
  Widget build(BuildContext context) {
    final totalInvested = positions.fold(0, (sum, p) => sum + p.invested);
    final totalCurrent = positions.fold(0, (sum, p) => sum + p.current);
    final totalGain = totalCurrent - totalInvested;
    final totalGainPercent =
        totalInvested == 0 ? 0.0 : totalGain / totalInvested * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.purple),
                SizedBox(width: 8),
                Text('親ファンド',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('パパ・ママが作った特別なファンド！',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 24),
            const Text('合計',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple)),
            const SizedBox(height: 6),
            Row(
              children: [
                _StockStat(label: '元本', value: '¥${formatYen(totalInvested)}'),
                const SizedBox(width: 16),
                _StockStat(
                  label: '含み益',
                  value: totalInvested == 0
                      ? '—'
                      : '${totalGain >= 0 ? '+' : ''}¥${formatYen(totalGain)}',
                  sub: totalInvested == 0
                      ? null
                      : '(${totalGainPercent.toStringAsFixed(1)}%)',
                  valueColor: totalInvested == 0
                      ? Colors.grey
                      : (totalGain >= 0 ? const Color(0xFF4CAF50) : Colors.red),
                ),
                const Spacer(),
                _StockStat(
                  label: '評価額',
                  value: '¥${formatYen(totalCurrent)}',
                  align: CrossAxisAlignment.end,
                  valueBold: true,
                  valueColor: Colors.purple,
                ),
              ],
            ),
            const Divider(height: 24),
            ...funds.map((fund) {
              final posIdx = positions.indexWhere((p) => p.fundId == fund.id);
              final pos = posIdx == -1
                  ? null
                  : positions[posIdx];
              return Column(
                children: [
                  _CustomFundRow(childId: childId, fund: fund, position: pos),
                  if (fund != funds.last) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CustomFundRow extends StatelessWidget {
  final String childId;
  final CustomFund fund;
  final ChildFundPosition? position;
  const _CustomFundRow(
      {required this.childId, required this.fund, required this.position});

  @override
  Widget build(BuildContext context) {
    final invested = position?.invested ?? 0;
    final current = position?.current ?? 0;
    final gain = current - invested;
    final gainPercent = invested == 0 ? 0.0 : gain / invested * 100;
    final gainColor = gain >= 0 ? const Color(0xFF4CAF50) : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(fund.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fund.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(fund.description,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      _CustomFundInvestDialog(childId: childId, fund: fund),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('投資する', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StockStat(label: '元本', value: '¥${formatYen(invested)}'),
              const SizedBox(width: 16),
              _StockStat(
                label: '含み益',
                value: invested == 0
                    ? '—'
                    : '${gain >= 0 ? '+' : ''}¥${formatYen(gain)}',
                sub: invested == 0
                    ? null
                    : '(${gainPercent.toStringAsFixed(1)}%)',
                valueColor: invested == 0 ? Colors.grey : gainColor,
              ),
              const Spacer(),
              _StockStat(
                label: '評価額',
                value: '¥${formatYen(current)}',
                align: CrossAxisAlignment.end,
                valueBold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockStat extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final CrossAxisAlignment align;
  final bool valueBold;

  const _StockStat({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.align = CrossAxisAlignment.start,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: valueBold ? 20 : 13,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(width: 2),
              Text(sub!, style: TextStyle(fontSize: 11, color: valueColor)),
            ],
          ],
        ),
      ],
    );
  }
}

class _InvestDialog extends StatefulWidget {
  final String childId;
  final Stock stock;
  const _InvestDialog({required this.childId, required this.stock});

  @override
  State<_InvestDialog> createState() => _InvestDialogState();
}

class _InvestDialogState extends State<_InvestDialog> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final state = context.read<AppState>();
    final child = state.childById(widget.childId);
    if (!state.canInvest(child, amount)) return;
    state.invest(child, widget.stock, amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(widget.childId);
    final amount =
        int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final canInvest = state.canInvest(child, amount);

    return AlertDialog(
      title: Text('${widget.stock.name} に投資'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('銀行残高: ¥${formatYen(child.bankBalance)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '投資する金額（円）',
              hintText: '例: 1,000',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorFormatter()],
            autofocus: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (amount > 0 && !canInvest) ...[
            const SizedBox(height: 8),
            const Text('残高が不足しています',
                style: TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: canInvest ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('投資する'),
        ),
      ],
    );
  }
}

class _CustomFundInvestDialog extends StatefulWidget {
  final String childId;
  final CustomFund fund;
  const _CustomFundInvestDialog({required this.childId, required this.fund});

  @override
  State<_CustomFundInvestDialog> createState() =>
      _CustomFundInvestDialogState();
}

class _CustomFundInvestDialogState extends State<_CustomFundInvestDialog> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final state = context.read<AppState>();
    final child = state.childById(widget.childId);
    if (!state.canInvest(child, amount)) return;
    state.investInCustomFund(child, widget.fund, amount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.childById(widget.childId);
    final amount =
        int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final canInvest = state.canInvest(child, amount);

    return AlertDialog(
      title: Text('${widget.fund.emoji} ${widget.fund.name} に投資'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('銀行残高: ¥${formatYen(child.bankBalance)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '投資する金額（円）',
              hintText: '例: 1,000',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorFormatter()],
            autofocus: true,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (amount > 0 && !canInvest) ...[
            const SizedBox(height: 8),
            const Text('残高が不足しています',
                style: TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: canInvest ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('投資する'),
        ),
      ],
    );
  }
}
