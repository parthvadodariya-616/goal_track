import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ActiveGoalTimer extends StatelessWidget {
  const ActiveGoalTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final goal = provider.activeGoal;

    if (goal == null) return const SizedBox.shrink();

    final color = Color(goal.colorValue);
    final isPaused = provider.isPaused;
    final duration = provider.remainingTime;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: isPaused ? Colors.orange : Colors.greenAccent,
              shape: BoxShape.circle
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(goal.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white70, fontFamily: 'Monospace', fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
            onPressed: () => isPaused ? provider.resumeGoalSession() : provider.pauseGoalSession(),
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.redAccent),
            onPressed: () => provider.stopGoalSession(),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}