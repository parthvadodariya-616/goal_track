import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../providers/app_provider.dart';
import '../config/app_colors.dart';
import '../screens/update_goal_screen.dart';

class GoalTile extends StatelessWidget {
  final Goal goal;

  const GoalTile({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final goalColor = Color(goal.colorValue);

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.deleteBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        final deletedGoal = goal;
        provider.removeGoal(goal.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${deletedGoal.title}' deleted"),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.amber,
              onPressed: () => provider.restoreGoal(deletedGoal),
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goal.isCompleted ? goalColor.withOpacity(0.5) : Colors.transparent, 
            width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => UpdateGoalScreen(goal: goal))
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: GestureDetector(
              onTap: () => provider.toggleGoalStatus(goal.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: goal.isCompleted ? goalColor : Colors.transparent,
                  border: Border.all(
                    color: goal.isCompleted ? goalColor : Colors.grey.shade400,
                    width: 2
                  ),
                  shape: BoxShape.circle,
                ),
                child: goal.isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
              ),
            ),
            title: Text(
              goal.title,
              style: TextStyle(
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                color: goal.isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Row(
              children: [
                 Icon(Icons.access_time, size: 12, color: goalColor),
                 const SizedBox(width: 4),
                 Text(
                  "${DateFormat('MMM dd').format(goal.date)} • ${DateFormat('jm').format(goal.date)}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            // PLAY BUTTON RESTORED
            trailing: !goal.isCompleted ? IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 32),
              color: goalColor,
              onPressed: () => provider.startGoalSession(goal),
            ) : null,
          ),
        ),
      ),
    );
  }
}