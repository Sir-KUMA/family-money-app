import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum JobStatus { pending, waitingApproval, done }

class Job {
  final String id;
  final String title;
  final int reward;
  JobStatus status;

  Job({required this.id, required this.title, required this.reward, required this.status});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'reward': reward,
        'status': status.name,
      };

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] as String,
        title: json['title'] as String,
        reward: json['reward'] as int,
        status: JobStatus.values.firstWhere((s) => s.name == json['status']),
      );
}

class Stock {
  final String id;
  final String name;
  final String description;
  int invested;
  int current;

  Stock({
    required this.id,
    required this.name,
    required this.description,
    required this.invested,
    required this.current,
  });

  int get gain => current - invested;
  double get gainPercent => invested == 0 ? 0 : gain / invested * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'invested': invested,
        'current': current,
      };

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        invested: json['invested'] as int,
        current: json['current'] as int,
      );

  static List<Stock> defaultList() => [
        Stock(id: 'sp500', name: 'S&P500', description: 'アメリカの大きな会社500社のチーム', invested: 0, current: 0),
        Stock(id: 'nasdaq100', name: 'NASDAQ100', description: 'アメリカのすごい会社たちのチーム', invested: 0, current: 0),
        Stock(id: 'nikkei225', name: '日経225', description: '日本の有名な会社225社のチーム', invested: 0, current: 0),
        Stock(id: 'topix', name: 'TOPIX', description: '日本の会社をたくさん集めたチーム', invested: 0, current: 0),
      ];
}

// 親が作成するカスタムファンドの定義（子どもごとのポジションは ChildFundPosition で管理）
class CustomFund {
  final String id;
  String name;
  String emoji;
  String? baseStockId;
  double multiplier;
  double bonusMonthlyPercent;

  CustomFund({
    required this.id,
    required this.name,
    required this.emoji,
    this.baseStockId,
    required this.multiplier,
    required this.bonusMonthlyPercent,
  });

  String get description {
    final parts = <String>[];
    if (baseStockId != null) {
      const names = {
        'sp500': 'S&P500',
        'nasdaq100': 'NASDAQ100',
        'nikkei225': '日経225',
        'topix': 'TOPIX',
      };
      parts.add('${names[baseStockId]} × $multiplier倍');
    }
    if (bonusMonthlyPercent > 0) {
      parts.add('+${bonusMonthlyPercent.toStringAsFixed(0)}%/月');
    }
    return parts.isEmpty ? 'カスタムファンド' : parts.join('、');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'baseStockId': baseStockId,
        'multiplier': multiplier,
        'bonusMonthlyPercent': bonusMonthlyPercent,
      };

  factory CustomFund.fromJson(Map<String, dynamic> json) => CustomFund(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        baseStockId: json['baseStockId'] as String?,
        multiplier: (json['multiplier'] as num).toDouble(),
        bonusMonthlyPercent: (json['bonusMonthlyPercent'] as num).toDouble(),
      );
}

// 子どもごとのカスタムファンド投資ポジション
class ChildFundPosition {
  final String fundId;
  int invested;
  int current;

  ChildFundPosition({required this.fundId, required this.invested, required this.current});

  int get gain => current - invested;
  double get gainPercent => invested == 0 ? 0 : gain / invested * 100;

  Map<String, dynamic> toJson() => {
        'fundId': fundId,
        'invested': invested,
        'current': current,
      };

  factory ChildFundPosition.fromJson(Map<String, dynamic> json) => ChildFundPosition(
        fundId: json['fundId'] as String,
        invested: json['invested'] as int,
        current: json['current'] as int,
      );
}

// 資産スナップショット（月次更新時に記録）
class AssetSnapshot {
  final DateTime date;
  final int totalAssets;

  AssetSnapshot({required this.date, required this.totalAssets});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'totalAssets': totalAssets,
      };

  factory AssetSnapshot.fromJson(Map<String, dynamic> json) => AssetSnapshot(
        date: DateTime.parse(json['date'] as String),
        totalAssets: json['totalAssets'] as int,
      );
}

enum WithdrawalType { cash, electronic }
enum WithdrawalStatus { pending, approved, rejected }

class WithdrawalRequest {
  final String id;
  final int amount;
  final WithdrawalType type;
  WithdrawalStatus status;
  final DateTime requestedAt;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.requestedAt,
  });

  String get typeLabel => type == WithdrawalType.cash ? '現金' : '電子マネー';

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'status': status.name,
        'requestedAt': requestedAt.toIso8601String(),
      };

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        id: json['id'] as String,
        amount: json['amount'] as int,
        type: WithdrawalType.values.firstWhere((t) => t.name == json['type']),
        status: WithdrawalStatus.values
            .firstWhere((s) => s.name == json['status']),
        requestedAt: DateTime.parse(json['requestedAt'] as String),
      );
}

class BucketItem {
  final String id;
  final String name;
  final int price;
  final String emoji;

  BucketItem({required this.id, required this.name, required this.price, required this.emoji});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'emoji': emoji};

  factory BucketItem.fromJson(Map<String, dynamic> json) => BucketItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int,
        emoji: json['emoji'] as String,
      );
}

class Child {
  final String id;
  String name;
  int bankBalance;
  int principal;
  List<Stock> stocks;
  List<ChildFundPosition> fundPositions;
  List<Job> jobs;
  List<BucketItem> bucketItems;
  final Set<String> requestedItemIds;
  final Set<String> purchasedItemIds;
  List<AssetSnapshot> assetHistory;
  List<WithdrawalRequest> withdrawalRequests;

  Child({
    required this.id,
    required this.name,
    required this.bankBalance,
    required this.principal,
    required this.stocks,
    List<ChildFundPosition>? fundPositions,
    required this.jobs,
    required this.bucketItems,
    Set<String>? requestedItemIds,
    Set<String>? purchasedItemIds,
    List<AssetSnapshot>? assetHistory,
    List<WithdrawalRequest>? withdrawalRequests,
  })  : fundPositions = fundPositions ?? [],
        requestedItemIds = requestedItemIds ?? {},
        purchasedItemIds = purchasedItemIds ?? {},
        assetHistory = assetHistory ?? [],
        withdrawalRequests = withdrawalRequests ?? [];

  List<WithdrawalRequest> get pendingWithdrawals =>
      withdrawalRequests.where((r) => r.status == WithdrawalStatus.pending).toList();

  int get stocksValue => stocks.fold(0, (sum, s) => sum + s.current);
  int get fundsValue => fundPositions.fold(0, (sum, p) => sum + p.current);
  int get totalAssets => bankBalance + stocksValue + fundsValue;
  int get gainLoss => totalAssets - principal;

  bool isRequested(BucketItem item) => requestedItemIds.contains(item.id);
  bool isPurchased(BucketItem item) => purchasedItemIds.contains(item.id);

  List<BucketItem> get purchaseRequests =>
      bucketItems.where((item) => requestedItemIds.contains(item.id)).toList();

  List<Job> get pendingJobs => jobs.where((j) => j.status == JobStatus.pending).toList();
  List<Job> get waitingJobs => jobs.where((j) => j.status == JobStatus.waitingApproval).toList();
  List<Job> get doneJobs => jobs.where((j) => j.status == JobStatus.done).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bankBalance': bankBalance,
        'principal': principal,
        'stocks': stocks.map((s) => s.toJson()).toList(),
        'fundPositions': fundPositions.map((p) => p.toJson()).toList(),
        'jobs': jobs.map((j) => j.toJson()).toList(),
        'bucketItems': bucketItems.map((b) => b.toJson()).toList(),
        'requestedItemIds': requestedItemIds.toList(),
        'purchasedItemIds': purchasedItemIds.toList(),
        'assetHistory': assetHistory.map((s) => s.toJson()).toList(),
        'withdrawalRequests': withdrawalRequests.map((r) => r.toJson()).toList(),
      };

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['id'] as String,
        name: json['name'] as String,
        bankBalance: json['bankBalance'] as int,
        principal: json['principal'] as int,
        stocks: (json['stocks'] as List)
            .map((e) => Stock.fromJson(e as Map<String, dynamic>))
            .toList(),
        fundPositions: (json['fundPositions'] as List? ?? [])
            .map((e) => ChildFundPosition.fromJson(e as Map<String, dynamic>))
            .toList(),
        jobs: (json['jobs'] as List)
            .map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList(),
        bucketItems: (json['bucketItems'] as List)
            .map((e) => BucketItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        requestedItemIds:
            Set<String>.from((json['requestedItemIds'] as List? ?? []).cast<String>()),
        purchasedItemIds:
            Set<String>.from((json['purchasedItemIds'] as List? ?? []).cast<String>()),
        assetHistory: (json['assetHistory'] as List? ?? [])
            .map((e) => AssetSnapshot.fromJson(e as Map<String, dynamic>))
            .toList(),
        withdrawalRequests: (json['withdrawalRequests'] as List? ?? [])
            .map((e) => WithdrawalRequest.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static Child createSample({required String id, required String name}) => Child(
        id: id,
        name: name,
        bankBalance: 7500,
        principal: 10000,
        stocks: [
          Stock(id: 'sp500', name: 'S&P500', description: 'アメリカの大きな会社500社のチーム', invested: 2750, current: 3000),
          Stock(id: 'nasdaq100', name: 'NASDAQ100', description: 'アメリカのすごい会社たちのチーム', invested: 1850, current: 2000),
          Stock(id: 'nikkei225', name: '日経225', description: '日本の有名な会社225社のチーム', invested: 0, current: 0),
          Stock(id: 'topix', name: 'TOPIX', description: '日本の会社をたくさん集めたチーム', invested: 0, current: 0),
        ],
        jobs: [
          Job(id: '1', title: 'お皿洗い', reward: 50, status: JobStatus.pending),
          Job(id: '2', title: 'ゴミ捨て', reward: 30, status: JobStatus.pending),
          Job(id: '3', title: '部屋の掃除', reward: 100, status: JobStatus.waitingApproval),
          Job(id: '4', title: '洗濯物をたたむ', reward: 50, status: JobStatus.done),
          Job(id: '5', title: '犬の散歩', reward: 80, status: JobStatus.done),
        ],
        bucketItems: [
          BucketItem(id: '1', name: 'レゴ スターウォーズ', price: 8000, emoji: '🧱'),
          BucketItem(id: '2', name: 'Nintendo Switch2', price: 6000, emoji: '🎮'),
          BucketItem(id: '3', name: '図鑑 恐竜', price: 2200, emoji: '📚'),
          BucketItem(id: '4', name: '自転車', price: 30000, emoji: '🚲'),
        ],
      );

  static Child createEmpty({required String id, required String name}) => Child(
        id: id,
        name: name,
        bankBalance: 0,
        principal: 0,
        stocks: Stock.defaultList(),
        jobs: [],
        bucketItems: [],
      );
}

class AppState extends ChangeNotifier {
  List<Child> children;
  double bankAnnualInterestPercent;
  List<CustomFund> customFunds;

  AppState({
    List<Child>? children,
    this.bankAnnualInterestPercent = 1.0,
    List<CustomFund>? customFunds,
  })  : children = children ?? [Child.createSample(id: '1', name: 'たろう')],
        customFunds = customFunds ?? [];

  Child childById(String id) => children.firstWhere((c) => c.id == id);

  // ── 子ども管理 ─────────────────────────────────────────────

  void addChild(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    children.add(Child.createEmpty(id: id, name: name));
    notifyListeners();
    _save();
  }

  void deleteChild(Child child) {
    children.remove(child);
    notifyListeners();
    _save();
  }

  void renameChild(Child child, String name) {
    child.name = name;
    notifyListeners();
    _save();
  }

  // ── お仕事 ──────────────────────────────────────────────────

  void addJob(Child child, String title, int reward) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    child.jobs.add(Job(id: id, title: title, reward: reward, status: JobStatus.pending));
    notifyListeners();
    _save();
  }

  void deleteJob(Child child, Job job) {
    child.jobs.remove(job);
    notifyListeners();
    _save();
  }

  void reportDone(Child child, Job job) {
    job.status = JobStatus.waitingApproval;
    notifyListeners();
    _save();
  }

  void approveJob(Child child, Job job) {
    job.status = JobStatus.done;
    child.bankBalance += job.reward;
    child.principal += job.reward;
    notifyListeners();
    _save();
  }

  void rejectJob(Child child, Job job) {
    job.status = JobStatus.pending;
    notifyListeners();
    _save();
  }

  void resetJob(Child child, Job job) {
    job.status = JobStatus.pending;
    notifyListeners();
    _save();
  }

  // ── 投資 ────────────────────────────────────────────────────

  bool canInvest(Child child, int amount) => amount > 0 && child.bankBalance >= amount;

  void invest(Child child, Stock stock, int amount) {
    if (!canInvest(child, amount)) return;
    child.bankBalance -= amount;
    stock.invested += amount;
    stock.current += amount;
    notifyListeners();
    _save();
  }

  ChildFundPosition? fundPositionFor(Child child, CustomFund fund) {
    final idx = child.fundPositions.indexWhere((p) => p.fundId == fund.id);
    return idx == -1 ? null : child.fundPositions[idx];
  }

  void investInCustomFund(Child child, CustomFund fund, int amount) {
    if (!canInvest(child, amount)) return;
    child.bankBalance -= amount;
    final idx = child.fundPositions.indexWhere((p) => p.fundId == fund.id);
    if (idx == -1) {
      child.fundPositions.add(ChildFundPosition(fundId: fund.id, invested: amount, current: amount));
    } else {
      child.fundPositions[idx].invested += amount;
      child.fundPositions[idx].current += amount;
    }
    notifyListeners();
    _save();
  }

  // ── 引き出し申請 ─────────────────────────────────────────────

  void requestWithdrawal(Child child, int amount, WithdrawalType type) {
    if (amount <= 0 || child.bankBalance < amount) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    child.withdrawalRequests.add(WithdrawalRequest(
      id: id,
      amount: amount,
      type: type,
      status: WithdrawalStatus.pending,
      requestedAt: DateTime.now(),
    ));
    notifyListeners();
    _save();
  }

  void approveWithdrawal(Child child, WithdrawalRequest req) {
    if (child.bankBalance < req.amount) return;
    req.status = WithdrawalStatus.approved;
    child.bankBalance -= req.amount;
    notifyListeners();
    _save();
  }

  void rejectWithdrawal(Child child, WithdrawalRequest req) {
    req.status = WithdrawalStatus.rejected;
    notifyListeners();
    _save();
  }

  // ── ほしいものリスト ─────────────────────────────────────────

  void addBucketItem(Child child, String name, int price, String emoji) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    child.bucketItems.add(BucketItem(id: id, name: name, price: price, emoji: emoji));
    notifyListeners();
    _save();
  }

  void deleteBucketItem(Child child, BucketItem item) {
    child.bucketItems.remove(item);
    child.requestedItemIds.remove(item.id);
    child.purchasedItemIds.remove(item.id);
    notifyListeners();
    _save();
  }

  void requestPurchase(Child child, BucketItem item) {
    child.requestedItemIds.add(item.id);
    notifyListeners();
    _save();
  }

  bool canApprovePurchase(Child child, BucketItem item) => child.bankBalance >= item.price;

  void approvePurchase(Child child, BucketItem item) {
    if (!canApprovePurchase(child, item)) return;
    child.requestedItemIds.remove(item.id);
    child.purchasedItemIds.add(item.id);
    child.bankBalance -= item.price;
    notifyListeners();
    _save();
  }

  void rejectPurchase(Child child, BucketItem item) {
    child.requestedItemIds.remove(item.id);
    notifyListeners();
    _save();
  }

  // ── 親ファンド・利率 ─────────────────────────────────────────

  void setBankInterestRate(double percent) {
    bankAnnualInterestPercent = percent;
    notifyListeners();
    _save();
  }

  void addCustomFund({
    required String name,
    required String emoji,
    String? baseStockId,
    required double multiplier,
    required double bonusMonthlyPercent,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    customFunds.add(CustomFund(
      id: id,
      name: name,
      emoji: emoji,
      baseStockId: baseStockId,
      multiplier: multiplier,
      bonusMonthlyPercent: bonusMonthlyPercent,
    ));
    notifyListeners();
    _save();
  }

  void deleteCustomFund(CustomFund fund) {
    customFunds.remove(fund);
    for (final child in children) {
      child.fundPositions.removeWhere((p) => p.fundId == fund.id);
    }
    notifyListeners();
    _save();
  }

  void applyMonthlyReturns(Map<String, double> indexMonthlyReturns) {
    for (final child in children) {
      for (final stock in child.stocks) {
        final ret = indexMonthlyReturns[stock.id] ?? 0.0;
        if (ret != 0 && stock.current > 0) {
          stock.current += (stock.current * ret).round();
        }
      }

      for (final position in child.fundPositions) {
        final fundIdx = customFunds.indexWhere((f) => f.id == position.fundId);
        if (fundIdx == -1) continue;
        final fund = customFunds[fundIdx];
        double monthlyReturn = fund.bonusMonthlyPercent / 100;
        if (fund.baseStockId != null) {
          final indexReturn = indexMonthlyReturns[fund.baseStockId] ?? 0.0;
          monthlyReturn += indexReturn * fund.multiplier;
        }
        if (position.current > 0) {
          position.current += (position.current * monthlyReturn).round();
        }
      }

      final interest = (child.bankBalance * bankAnnualInterestPercent / 100 / 12).round();
      child.bankBalance += interest;

      child.assetHistory.add(AssetSnapshot(date: DateTime.now(), totalAssets: child.totalAssets));
    }
    notifyListeners();
    _save();
  }

  // ── 保存・読み込み ──────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    bankAnnualInterestPercent = prefs.getDouble('bankAnnualInterestPercent') ?? 1.0;

    final customFundsJson = prefs.getString('customFunds');
    if (customFundsJson != null) {
      customFunds = (jsonDecode(customFundsJson) as List)
          .map((e) => CustomFund.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final childrenJson = prefs.getString('children');
    if (childrenJson != null) {
      children = (jsonDecode(childrenJson) as List)
          .map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bankAnnualInterestPercent', bankAnnualInterestPercent);
    await prefs.setString(
        'customFunds', jsonEncode(customFunds.map((f) => f.toJson()).toList()));
    await prefs.setString(
        'children', jsonEncode(children.map((c) => c.toJson()).toList()));
  }
}
