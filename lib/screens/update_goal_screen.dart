import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/goal_model.dart';
import '../config/app_colors.dart';

class UpdateGoalScreen extends StatefulWidget {
  final Goal goal;
  const UpdateGoalScreen({super.key, required this.goal});

  @override
  State<UpdateGoalScreen> createState() => _UpdateGoalScreenState();
}

class _UpdateGoalScreenState extends State<UpdateGoalScreen> {
  late TextEditingController _controller;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.goal.title);
    _selectedDate = widget.goal.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.goal.date);
    
    // Find color index
    Color goalColor = Color(widget.goal.colorValue);
    _selectedColorIndex = AppColors.palette.indexOf(goalColor);
    if(_selectedColorIndex == -1) _selectedColorIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = AppColors.palette[_selectedColorIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Mission"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).removeGoal(widget.goal.id);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              cursorColor: selectedColor, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Goal Title",
                labelStyle: TextStyle(color: selectedColor),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: selectedColor)),
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: _buildPickerButton(
                    context, 
                    icon: Icons.calendar_today,
                    label: "Date",
                    text: DateFormat('MMM dd, yyyy').format(_selectedDate),
                    color: selectedColor,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) => Theme(
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
                    label: "Time",
                    text: _selectedTime.format(context),
                    color: selectedColor,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        builder: (ctx, child) => Theme(
                          data: theme.copyWith(
                            colorScheme: ColorScheme.light(primary: selectedColor, onSurface: Colors.black87),
                            timePickerTheme: TimePickerThemeData(
                              dialHandColor: selectedColor,
                              hourMinuteTextColor: selectedColor,
                              dayPeriodTextColor: selectedColor,
                            )
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
            
            const SizedBox(height: 30),
            const Text("Update Color", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
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

            const Spacer(),
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
                    
                    Provider.of<AppProvider>(context, listen: false).updateGoal(
                      widget.goal.id, 
                      _controller.text, 
                      finalDateTime, 
                      selectedColor
                    );
                    
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton(BuildContext context, {required IconData icon, required String label, required String text, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}