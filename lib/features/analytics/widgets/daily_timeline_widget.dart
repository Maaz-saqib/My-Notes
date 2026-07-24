import 'package:flutter/material.dart';
import '../analytics_view_model.dart';

class DailyTimelineWidget extends StatelessWidget {
  final DailyFocusStats dayStats;

  const DailyTimelineWidget({
    super.key,
    required this.dayStats,
  });

  @override
  Widget build(BuildContext context) {
    // 1440 minutes in a day, we map 1 minute to 1 pixel for easy scrolling
    const double timelineWidth = 1440.0;
    const double blockHeight = 40.0;

    int pomodoroCount = 0;
    int openFocusCount = 0;

    for (var session in dayStats.sessions) {
      if (session.mode == 'pomodoro') {
        pomodoroCount++;
      } else {
        openFocusCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Focus',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                Text(
                  '${dayStats.totalMinutes} minutes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Sessions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                Text(
                  '${dayStats.sessions.length} total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          children: [
            _LegendItem(
              color: Colors.deepOrange.shade700,
              label: 'Pomodoro ($pomodoroCount)',
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: Colors.indigo.shade600,
              label: 'Open Focus ($openFocusCount)',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Scrollable Timeline
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SizedBox(
                width: timelineWidth,
                height: 80,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base timeline line
                    Positioned(
                      top: blockHeight / 2 - 1,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    
                    // Time markers every 3 hours
                    ...List.generate(9, (index) {
                      final hour = index * 3;
                      final leftPos = hour * 60.0;
                      String label;
                      if (hour == 0 || hour == 24) {
                        label = '12 AM';
                      } else if (hour < 12) {
                        label = '$hour AM';
                      } else if (hour == 12) {
                        label = '12 PM';
                      } else {
                        label = '${hour - 12} PM';
                      }

                      return Positioned(
                        top: blockHeight + 12,
                        left: leftPos - 20, // Center text somewhat
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      );
                    }),
                    
                    // Tick marks
                    ...List.generate(25, (index) {
                      final leftPos = index * 60.0;
                      return Positioned(
                        top: blockHeight / 2 - 4,
                        left: leftPos,
                        child: Container(
                          width: 2,
                          height: 8,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      );
                    }),

                    // Session Blocks
                    ...dayStats.sessions.map((session) {
                      final startMinutes = session.startTime.hour * 60 + session.startTime.minute;
                      final isPomodoro = session.mode == 'pomodoro';
                      
                      // Ensure a minimum width of 6 pixels so very short sessions (e.g. 1 min) are visible
                      final width = (session.durationMinutes.toDouble() < 6.0) 
                          ? 6.0 
                          : session.durationMinutes.toDouble();
                      
                      // Use high-visibility dark colors
                      final color = isPomodoro 
                          ? Colors.deepOrange.shade700 
                          : Colors.indigo.shade600;

                      final startTimeStr = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';
                      final endTimeStr = '${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}';

                      return Positioned(
                        top: 0,
                        left: startMinutes.toDouble(),
                        child: Tooltip(
                          message: '${isPomodoro ? 'Pomodoro' : 'Open Focus'}\n$startTimeStr - $endTimeStr\n${session.durationMinutes} mins',
                          triggerMode: TooltipTriggerMode.tap,
                          child: Container(
                            height: blockHeight,
                            width: width,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
