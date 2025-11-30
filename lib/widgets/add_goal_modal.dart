import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../config/app_colors.dart';

class AddGoalModal extends StatefulWidget {
  const AddGoalModal({super.key});
  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = AppColors.palette[_selectedColorIndex];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("New Mission", 
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          TextField(
            controller: _controller,
            autofocus: true,
            cursorColor: selectedColor, 
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: "What's the goal?",
              filled: true,
              fillColor: theme.cardColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: selectedColor, width: 2),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildPickerButton(
                  context, 
                  icon: Icons.calendar_today,
                  text: DateFormat('MMM dd, yyyy').format(_selectedDate),
                  color: selectedColor,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: theme.copyWith(colorScheme: ColorScheme.light(primary: selectedColor)),
                        child: child!,
                      )
                    );
                    if (d != null) setState(() => _selectedDate = d);
                  }
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPickerButton(
                  context,
                  icon: Icons.access_time,
                  text: _selectedTime.format(context),
                  color: selectedColor,
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                      builder: (context, child) => Theme(
                        data: theme.copyWith(
                          colorScheme: ColorScheme.light(
                            primary: selectedColor, // Header background, active dial hand
                            onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black, // Default text color
                          ),
                          timePickerTheme: TimePickerThemeData(
                            dialHandColor: selectedColor,
                            // Background of the Hour/Minute numbers box
                            hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                                states.contains(WidgetState.selected) ? selectedColor : Colors.grey.shade200),
                            // Text color of the Hour/Minute numbers
                            hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                                states.contains(WidgetState.selected) ? Colors.white : Colors.black87),
                            // AM/PM selector background
                            dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                                states.contains(WidgetState.selected) ? selectedColor : Colors.transparent),
                            // AM/PM selector text color
                            dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                                states.contains(WidgetState.selected) ? Colors.white : Colors.black87),
                            dialBackgroundColor: Colors.grey.shade100, // Background of the clock face
                          ),
                        ),
                        child: child!,
                      )
                    );
                    if (t != null) setState(() => _selectedTime = t);
                  }
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Text("Color Code", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(AppColors.palette.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 35, height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.palette[index],
                    shape: BoxShape.circle,
                    border: _selectedColorIndex == index 
                      ? Border.all(color: theme.dividerColor, width: 3) 
                      : null,
                  ),
                  child: _selectedColorIndex == index 
                    ? const Icon(Icons.check, color: Colors.white, size: 20) 
                    : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  final finalDateTime = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day,
                    _selectedTime.hour, _selectedTime.minute
                  );
                  
                  Provider.of<AppProvider>(context, listen: false)
                    .addGoal(_controller.text, finalDateTime, selectedColor);
                  
                  Navigator.pop(context);
                  _showSuccessNotification(context, selectedColor, "Goal Created!");
                }
              },
              child: const Text("Set Goal", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Custom Top Notification to simulate "Notification Bar" style
  void _showSuccessNotification(BuildContext context, Color color, String message) {
    // We use a SnackBar behaving like a top notification or a simple dialog as requested earlier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150, // Move to Top
          left: 10,
          right: 10
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.access_alarm, color: Colors.white), // "Reverse clock buddy" icon metaphor
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPickerButton(BuildContext context, {required IconData icon, required String text, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}