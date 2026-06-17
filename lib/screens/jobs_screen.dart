import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('お仕事'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.pendingJobs.isNotEmpty) ...[
            const _SectionHeader('完了待ち'),
            ...state.pendingJobs.map((job) => _JobCard(job: job)),
            const SizedBox(height: 16),
          ],
          if (state.waitingJobs.isNotEmpty) ...[
            const _SectionHeader('チェック待ち'),
            ...state.waitingJobs.map((job) => _JobCard(job: job)),
            const SizedBox(height: 16),
          ],
          if (state.doneJobs.isNotEmpty) ...[
            const _SectionHeader('完了済み'),
            ...state.doneJobs.map((job) => _JobCard(job: job)),
          ],
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

class _JobCard extends StatelessWidget {
  final Job job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    final statusConfig = switch (job.status) {
      JobStatus.pending => (label: 'できた！', color: const Color(0xFF4CAF50), icon: Icons.check_circle_outline),
      JobStatus.waitingApproval => (label: 'チェック待ち', color: Colors.orange, icon: Icons.hourglass_empty),
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
                  Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('報酬: ¥${job.reward}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            if (job.status == JobStatus.pending)
              TextButton(
                onPressed: () => state.reportDone(job),
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
