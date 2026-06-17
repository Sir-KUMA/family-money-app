import 'package:flutter/material.dart';

enum JobStatus { pending, waitingApproval, done }

class Job {
  final String id;
  final String title;
  final int reward;
  JobStatus status;

  Job({required this.id, required this.title, required this.reward, required this.status});
}

class Stock {
  final String name;
  final String description;
  final int invested;
  final int current;

  const Stock({
    required this.name,
    required this.description,
    required this.invested,
    required this.current,
  });

  int get gain => current - invested;
  double get gainPercent => invested == 0 ? 0 : gain / invested * 100;
}

class BucketItem {
  final String id;
  final String name;
  final int price;
  final String emoji;

  const BucketItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });
}

class AppState extends ChangeNotifier {
  int bankBalance = 7500;
  int principal = 10000;

  final List<Stock> stocks = const [
    Stock(name: 'S&P500', description: 'アメリカの大きな会社500社のチーム', invested: 2750, current: 3000),
    Stock(name: 'NASDAQ100', description: 'アメリカのすごい会社たちのチーム', invested: 1850, current: 2000),
    Stock(name: '日経225', description: '日本の有名な会社225社のチーム', invested: 0, current: 0),
    Stock(name: 'TOPIX', description: '日本の会社をたくさん集めたチーム', invested: 0, current: 0),
  ];

  final List<BucketItem> bucketItems = const [
    BucketItem(id: '1', name: 'レゴ スターウォーズ', price: 8000, emoji: '🧱'),
    BucketItem(id: '2', name: 'Nintendo Switch2', price: 6000, emoji: '🎮'),
    BucketItem(id: '3', name: '図鑑 恐竜', price: 2200, emoji: '📚'),
    BucketItem(id: '4', name: '自転車', price: 30000, emoji: '🚲'),
  ];

  final List<Job> jobs = [
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
  int get totalAssets => bankBalance + stocksValue;
  int get gainLoss => totalAssets - principal;

  List<Job> get pendingJobs => jobs.where((j) => j.status == JobStatus.pending).toList();
  List<Job> get waitingJobs => jobs.where((j) => j.status == JobStatus.waitingApproval).toList();
  List<Job> get doneJobs => jobs.where((j) => j.status == JobStatus.done).toList();

  void reportDone(Job job) {
    job.status = JobStatus.waitingApproval;
    notifyListeners();
  }

  void approveJob(Job job) {
    job.status = JobStatus.done;
    bankBalance += job.reward;
    principal += job.reward;
    notifyListeners();
  }

  void rejectJob(Job job) {
    job.status = JobStatus.pending;
    notifyListeners();
  }

  void requestPurchase(BucketItem item) {
    _requestedItemIds.add(item.id);
    notifyListeners();
  }

  bool canApprovePurchase(BucketItem item) => bankBalance >= item.price;

  void approvePurchase(BucketItem item) {
    if (!canApprovePurchase(item)) return;
    _requestedItemIds.remove(item.id);
    _purchasedItemIds.add(item.id);
    bankBalance -= item.price;
    notifyListeners();
  }

  void rejectPurchase(BucketItem item) {
    _requestedItemIds.remove(item.id);
    notifyListeners();
  }
}
