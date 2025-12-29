import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/goal_model.dart';
import '../widgets/dashboard_banner.dart';
import '../widgets/add_goal_modal.dart';
import '../widgets/goal_tile.dart';
import '../widgets/active_goal_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Store the vertical position of the timer (distance from bottom)
  double _timerBottomOffset = 20.0; 

  @override
  void initState() {
    super.initState();
    // System UI config is now handled in main.dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverdueItems();
    });
  }

  void _checkOverdueItems() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final overdueList = provider.getOverdueGoals();
    if (overdueList.isNotEmpty) _showOverdueDialog(overdueList.first, provider);
  }

  void _showOverdueDialog(Goal goal, AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Time is Over!"),
        content: Text("Did you complete '${goal.title}'?"),
        actions: [
          TextButton(
            child: const Text("No, Remove"),
            onPressed: () {
              provider.removeGoal(goal.id);
              Navigator.pop(ctx);
              _checkOverdueItems();
            },
          ),
           TextButton(
            child: const Text("Reschedule"),
            onPressed: () {
              Navigator.pop(ctx);
              _showReschedulePicker(goal, provider);
            },
          ),
          FilledButton(
            child: const Text("Yes, I did!"),
            onPressed: () {
              provider.toggleGoalStatus(goal.id);
              Navigator.pop(ctx);
              _checkOverdueItems();
            },
          ),
        ],
      ),
    );
  }

  void _showReschedulePicker(Goal goal, AppProvider provider) async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(2030));
    if(d != null && mounted) {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if(t != null) {
        final newDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        provider.rescheduleGoal(goal.id, newDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text("FocusForge", style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, key: ValueKey(isDark))),
            onPressed: () => provider.toggleTheme(),
          ),
        ],
      ),
      // 3. Stack for Draggable Timer + Main Content (No SafeArea wrapper on body, manual padding used)
      body: Stack(
        children: [
          Column(
            children: [
              // Manual top padding for status bar to avoid overlap
              SizedBox(height: MediaQuery.of(context).padding.top),
              const DashboardBanner(),
              Expanded(
                child: provider.goals.isEmpty 
                ? _buildEmptyState() 
                : ListView.builder(
                    // Manual bottom padding for navigation bar + extra space for FAB and Timer
                    padding: EdgeInsets.only(
                      left: 16, 
                      right: 16, 
                      bottom: MediaQuery.of(context).padding.bottom + 100
                    ),
                    itemCount: provider.goals.length,
                    itemBuilder: (context, index) => GoalTile(goal: provider.goals[index]),
                  ),
              ),
            ],
          ),
          
          // 4. Draggable Active Timer (Restored)
          if (provider.activeGoal != null)
            Positioned(
              bottom: _timerBottomOffset,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _timerBottomOffset -= details.delta.dy;
                    // Clamp to keep it on screen
                    double maxHeight = MediaQuery.of(context).size.height - 150;
                    double minHeight = MediaQuery.of(context).padding.bottom + 10;
                    if (_timerBottomOffset < minHeight) _timerBottomOffset = minHeight;
                    if (_timerBottomOffset > maxHeight) _timerBottomOffset = maxHeight;
                  });
                },
                child: const ActiveGoalTimer(),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        // Adjust FAB position to respect system navigation
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => const AddGoalModal(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text("No Missions Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}