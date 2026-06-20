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
}

class CustomFund {
  final String id;
  String name;
  String emoji;
  String? baseStockId;
  double multiplier;
  double bonusMonthlyPercent;
  int invested;
  int current;

  CustomFund({
    required this.id,
    required this.name,
    required this.emoji,
    this.baseStockId,
    required this.multiplier,
    required this.bonusMonthlyPercent,
    required this.invested,
    required this.current,
  });

  int get gain => current - invested;
  double get gainPercent => invested == 0 ? 0 : gain / invested * 100;

  String get description {
    final parts = <String>[];
    if (baseStockId != null) {
      const names = {
        'sp500': 'S&P500', 'nasdaq100': 'NASDAQ100',
        'nikkei225': '日経225', 'topix': 'TOPIX',
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
        'invested': invested,
        'current': current,
      };

  factory CustomFund.fromJson(Map<String, dynamic> json) => CustomFund(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        baseStockId: json['baseStockId'] as String?,
        multiplier: (json['multiplier'] as num).toDouble(),
        bonusMonthlyPercent: (json['bonusMonthlyPercent'] as num).toDouble(),
        invested: json['invested'] as int,
        current: json['current'] as int,
      );
}

class BucketItem {
  final String id;
  final String name;
  final int price;
  final String emoji;

  BucketItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'emoji': emoji,
      };

  factory BucketItem.fromJson(Map<String, dynamic> json) => BucketItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int,
        emoji: json['emoji'] as String,
      );
}

class AppState extends ChangeNotifier {
  int bankBalance = 7500;
  int principal = 10000;
  double bankAnnualInterestPercent = 1.0;

  List<Stock> stocks = [
    Stock(id: 'sp500', name: 'S&P500', description: 'アメリカの大きな会社500社のチーム', invested: 2750, current: 3000),
    Stock(id: 'nasdaq100', name: 'NASDAQ100', description: 'アメリカのすごい会社たちのチーム', invested: 1850, current: 2000),
    Stock(id: 'nikkei225', name: '日経225', description: '日本の有名な会社225社のチーム', invested: 0, current: 0),
    Stock(id: 'topix', name: 'TOPIX', description: '日本の会社をたくさん集めたチーム', invested: 0, current: 0),
  ];

  List<CustomFund> customFunds = [];

  List<BucketItem> bucketItems = [
    BucketItem(id: '1', name: 'レゴ スターウォーズ', price: 8000, emoji: '🧱'),
    BucketItem(id: '2', name: 'Nintendo Switch2', price: 6000, emoji: '🎮'),
    BucketItem(id: '3', name: '図鑑 恐竜', price: 2200, emoji: '📚'),
    BucketItem(id: '4', name: '自転車', price: 30000, emoji: '🚲'),
  ];

  List<Job> jobs = [
    Job(id: '1', title: 'お皿洗い', reward: 50, status: JobStatus.pending),
    Job(id: '2', title: 'ゴミ捨て', reward: 30, status: JobStatus.pending),
    Job(id: '3', title: '部屋の掃除', reward: 100, status: JobStatus.waitingApproval),
    Job(id: '4', title: '洗濯物をたたむ', reward: 50, status: JobStatus.done),
    Job(id: '5', title: '犬の散歩', reward: 80, status: JobStatus.done),
  ];

  final Set<String> _requestedItemIds = {};
  final Set<String> _purchasedItemIds = {};

  bool isRequested(BucketItem item) => _requestedItemIds.contains(item.id);
  bool isPurchased(BucketItem item) => _purchasedItemIds.contains(item.id);

  List<BucketItem> get purchaseRequests =>
      bucketItems.where((item) => _requestedItemIds.contains(item.id)).toList();

  int get stocksValue => stocks.fold(0, (sum, s) => sum + s.current);
  int get customFundsValue => customFunds.fold(0, (sum, f) => sum + f.current);
  int get totalAssets => bankBalance + stocksValue + customFundsValue;
  int get gainLoss => totalAssets - principal;

  List<Job> get pendingJobs => jobs.where((j) => j.status == JobStatus.pending).toList();
  List<Job> get waitingJobs => jobs.where((j) => j.status == JobStatus.waitingApproval).toList();
  List<Job> get doneJobs => jobs.where((j) => j.status == JobStatus.done).toList();

  // ── 保存・読み込み ──────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    bankBalance = prefs.getInt('bankBalance') ?? 7500;
    principal = prefs.getInt('principal') ?? 10000;
    bankAnnualInterestPercent = prefs.getDouble('bankAnnualInterestPercent') ?? 1.0;

    final jobsJson = prefs.getString('jobs');
    if (jobsJson != null) {
      jobs = (jsonDecode(jobsJson) as List)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final stocksJson = prefs.getString('stocks');
    if (stocksJson != null) {
      stocks = (jsonDecode(stocksJson) as List)
          .map((e) => Stock.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final customFundsJson = prefs.getString('customFunds');
    if (customFundsJson != null) {
      customFunds = (jsonDecode(customFundsJson) as List)
          .map((e) => CustomFund.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final requestedJson = prefs.getString('requestedItemIds');
    if (requestedJson != null) {
      _requestedItemIds.addAll((jsonDecode(requestedJson) as List).cast<String>());
    }

    final purchasedJson = prefs.getString('purchasedItemIds');
    if (purchasedJson != null) {
      _purchasedItemIds.addAll((jsonDecode(purchasedJson) as List).cast<String>());
    }

    final bucketJson = prefs.getString('bucketItems');
    if (bucketJson != null) {
      bucketItems = (jsonDecode(bucketJson) as List)
          .map((e) => BucketItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bankBalance', bankBalance);
    await prefs.setInt('principal', principal);
    await prefs.setDouble('bankAnnualInterestPercent', bankAnnualInterestPercent);
    await prefs.setString('jobs', jsonEncode(jobs.map((j) => j.toJson()).toList()));
    await prefs.setString('stocks', jsonEncode(stocks.map((s) => s.toJson()).toList()));
    await prefs.setString('customFunds', jsonEncode(customFunds.map((f) => f.toJson()).toList()));
    await prefs.setString('requestedItemIds', jsonEncode(_requestedItemIds.toList()));
    await prefs.setString('purchasedItemIds', jsonEncode(_purchasedItemIds.toList()));
    await prefs.setString('bucketItems', jsonEncode(bucketItems.map((b) => b.toJson()).toList()));
  }

  // ── お仕事操作 ───────────────────────────────────────────────

  void addJob(String title, int reward) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    jobs.add(Job(id: id, title: title, reward: reward, status: JobStatus.pending));
    notifyListeners();
    _save();
  }

  void deleteJob(Job job) {
    jobs.remove(job);
    notifyListeners();
    _save();
  }

  void reportDone(Job job) {
    job.status = JobStatus.waitingApproval;
    notifyListeners();
    _save();
  }

  void approveJob(Job job) {
    job.status = JobStatus.done;
    bankBalance += job.reward;
    principal += job.reward;
    notifyListeners();
    _save();
  }

  void rejectJob(Job job) {
    job.status = JobStatus.pending;
    notifyListeners();
    _save();
  }

  // ── 投資操作 ────────────────────────────────────────────────

  bool canInvest(int amount) => amount > 0 && bankBalance >= amount;

  void invest(Stock stock, int amount) {
    if (!canInvest(amount)) return;
    bankBalance -= amount;
    stock.invested += amount;
    stock.current += amount;
    notifyListeners();
    _save();
  }

  void investInCustomFund(CustomFund fund, int amount) {
    if (!canInvest(amount)) return;
    bankBalance -= amount;
    fund.invested += amount;
    fund.current += amount;
    notifyListeners();
    _save();
  }

  // ── 親ファンド・利率操作 ─────────────────────────────────────

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
      invested: 0,
      current: 0,
    ));
    notifyListeners();
    _save();
  }

  void deleteCustomFund(CustomFund fund) {
    customFunds.remove(fund);
    notifyListeners();
    _save();
  }

  // indexMonthlyReturns: 各指数の今月のリターン（例: {'sp500': 0.023} = +2.3%）
  void applyMonthlyReturns(Map<String, double> indexMonthlyReturns) {
    // 通常の指数ファンドを更新
    for (final stock in stocks) {
      final ret = indexMonthlyReturns[stock.id] ?? 0.0;
      if (ret != 0 && stock.current > 0) {
        stock.current += (stock.current * ret).round();
      }
    }

    // カスタムファンドを更新
    for (final fund in customFunds) {
      double monthlyReturn = fund.bonusMonthlyPercent / 100;
      if (fund.baseStockId != null) {
        final indexReturn = indexMonthlyReturns[fund.baseStockId] ?? 0.0;
        monthlyReturn += indexReturn * fund.multiplier;
      }
      if (fund.current > 0) {
        fund.current += (fund.current * monthlyReturn).round();
      }
    }

    // 銀行利息を加算（利息は gainLoss に反映、principal は増やさない）
    final interest = (bankBalance * bankAnnualInterestPercent / 100 / 12).round();
    bankBalance += interest;

    notifyListeners();
    _save();
  }

  // ── ほしいものリスト操作 ─────────────────────────────────────

  void addBucketItem(String name, int price, String emoji) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    bucketItems.add(BucketItem(id: id, name: name, price: price, emoji: emoji));
    notifyListeners();
    _save();
  }

  void deleteBucketItem(BucketItem item) {
    bucketItems.remove(item);
    _requestedItemIds.remove(item.id);
    _purchasedItemIds.remove(item.id);
    notifyListeners();
    _save();
  }

  // ── 購入申請操作 ─────────────────────────────────────────────

  void requestPurchase(BucketItem item) {
    _requestedItemIds.add(item.id);
    notifyListeners();
    _save();
  }

  bool canApprovePurchase(BucketItem item) => bankBalance >= item.price;

  void approvePurchase(BucketItem item) {
    if (!canApprovePurchase(item)) return;
    _requestedItemIds.remove(item.id);
    _purchasedItemIds.add(item.id);
    bankBalance -= item.price;
    notifyListeners();
    _save();
  }

  void rejectPurchase(BucketItem item) {
    _requestedItemIds.remove(item.id);
    notifyListeners();
    _save();
  }
}
