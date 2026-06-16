import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お仕事'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader('完了待ち'),
          _JobCard(title: 'お皿洗い', reward: 50, status: JobStatus.pending),
          _JobCard(title: 'ゴミ捨て', reward: 30, status: JobStatus.pending),
          SizedBox(height: 16),
          _SectionHeader('承認待ち'),
          _JobCard(title: '部屋の掃除', reward: 100, status: JobStatus.waitingApproval),
          SizedBox(height: 16),
          _SectionHeader('完了済み'),
          _JobCard(title: '洗濯物をたたむ', reward: 50, status: JobStatus.done),
          _JobCard(title: '犬の散歩', reward: 80, status: JobStatus.done),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}

enum JobStatus { pending, waitingApproval, done }

class _JobCard extends StatelessWidget {
  final String title;
  final int reward;
  final JobStatus status;

  const _JobCard({required this.title, required this.reward, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusConfig = switch (status) {
      JobStatus.pending => (label: '完了報告する', color: const Color(0xFF4CAF50), icon: Icons.check_circle_outline),
      JobStatus.waitingApproval => (label: '承認待ち', color: Colors.orange, icon: Icons.hourglass_empty),
      JobStatus.done => (label: '完了', color: Colors.grey, icon: Icons.check_circle),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusConfig.icon, color: statusConfig.color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('報酬: ¥$reward', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            if (status == JobStatus.pending)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: statusConfig.color),
                child: Text(statusConfig.label),
              )
            else
              Text(statusConfig.label, style: TextStyle(color: statusConfig.color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
