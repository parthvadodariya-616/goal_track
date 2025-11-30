import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class DashboardBanner extends StatelessWidget {
  const DashboardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // Logic: In Light Mode -> Black Banner. In Dark Mode -> White Banner.
    final isSystemDark = Theme.of(context).brightness == Brightness.dark;
    
    // Reverse logic colors
    final backgroundColor = isSystemDark ? Colors.white : Colors.black;
    final textColor = isSystemDark ? Colors.black : Colors.white;
    final subTextColor = isSystemDark ? Colors.black54 : Colors.white70;
    
    // Use the provider's focused date
    final focusedDate = provider.dashboardFocusedDate;
    final daysInMonth = DateUtils.getDaysInMonth(focusedDate.year, focusedDate.month);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor, // REVERSED COLOR
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Progress Bank", style: TextStyle(color: subTextColor, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("${provider.coins}", 
                    style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.bolt, color: Colors.amber, size: 36),
            ],
          ),
          const SizedBox(height: 20),
          
          // Month/Year Selector with correct text colors
          Row(
            children: [
              _buildDropdown(
                context, 
                value: focusedDate.month, 
                items: List.generate(12, (i) => i + 1),
                labelBuilder: (val) => DateFormat('MMMM').format(DateTime(0, val)),
                textColor: textColor,
                dropdownBg: backgroundColor,
                onChanged: (val) {
                  if (val != null) {
                    provider.setDashboardDate(DateTime(focusedDate.year, val));
                  }
                }
              ),
              const SizedBox(width: 10),
              _buildDropdown(
                context,
                value: focusedDate.year,
                items: List.generate(5, (i) => DateTime.now().year - 2 + i), // 5 year range
                labelBuilder: (val) => val.toString(),
                textColor: textColor,
                dropdownBg: backgroundColor,
                onChanged: (val) {
                  if(val != null) {
                    provider.setDashboardDate(DateTime(val, focusedDate.month));
                  }
                }
              ),
            ],
          ),

          const SizedBox(height: 15),
          
          // Dynamic Grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(daysInMonth, (index) {
              final day = index + 1;
              final date = DateTime(focusedDate.year, focusedDate.month, day);
              Color? activeColor = provider.getColorForDate(date);
              
              // Empty cells should be visible against the reverse background
              final emptyColor = isSystemDark ? Colors.grey[300]! : Colors.white24;

              return Tooltip(
                message: DateFormat('MMM dd').format(date),
                child: Container(
                  width: 18, 
                  height: 18,
                  decoration: BoxDecoration(
                    color: activeColor ?? emptyColor,
                    borderRadius: BorderRadius.circular(4),
                    border: date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year 
                      ? Border.all(color: textColor, width: 1.5) // Highlight today
                      : null
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(BuildContext context, {
    required T value, 
    required List<T> items, 
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
    required Color textColor,
    required Color dropdownBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: dropdownBg,
        icon: Icon(Icons.arrow_drop_down, color: textColor.withOpacity(0.7)),
        underline: const SizedBox(),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(labelBuilder(e)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}