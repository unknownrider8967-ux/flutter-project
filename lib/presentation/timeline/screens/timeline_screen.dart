import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  final Event event;

  const TimelineScreen({super.key, required this.event});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.event.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks
        .where((t) => t.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Build milestone list from event dates + tasks
    final milestones = _buildMilestones(tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildEventHeader(),
          Expanded(
            child: milestones.isEmpty
                ? const EmptyStateWidget(
                    title: 'No Timeline Items',
                    subtitle:
                        'Add tasks with due dates to build your event timeline.',
                    icon: Icons.timeline_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.spacingL),
                    itemCount: milestones.length,
                    itemBuilder: (context, index) =>
                        _buildMilestoneRow(milestones[index], index,
                            milestones.length),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.spacingL),
      padding: const EdgeInsets.all(DesignTokens.spacingM),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignTokens.primaryColor, DesignTokens.primaryDark],
        ),
        borderRadius: DesignTokens.radiusL,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              const SizedBox(height: DesignTokens.spacingXS),
              Text(
                '${widget.event.formattedStartDate} → ${widget.event.formattedEndDate}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Text(
              '${widget.event.durationDays} day${widget.event.durationDays != 1 ? 's' : ''}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<_Milestone> _buildMilestones(List<Task> tasks) {
    final milestones = <_Milestone>[];

    // Event start
    milestones.add(_Milestone(
      date: widget.event.startDate,
      title: 'Event Starts',
      subtitle: widget.event.location,
      type: _MilestoneType.event,
      isCompleted: widget.event.startDate.isBefore(DateTime.now()),
    ));

    // Tasks with due dates
    for (final task in tasks) {
      milestones.add(_Milestone(
        date: task.dueDate!,
        title: task.title,
        subtitle: task.assignedTo != null
            ? 'Assigned to ${task.assignedTo}'
            : _priorityLabel(task.priority),
        type: _MilestoneType.task,
        isCompleted: task.isCompleted,
        priority: task.priority,
      ));
    }

    // Event end
    milestones.add(_Milestone(
      date: widget.event.endDate,
      title: 'Event Ends',
      subtitle: '${widget.event.durationDays}-day event concludes',
      type: _MilestoneType.event,
      isCompleted: widget.event.endDate.isBefore(DateTime.now()),
    ));

    milestones.sort((a, b) => a.date.compareTo(b.date));
    return milestones;
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'High priority';
      case 'medium':
        return 'Medium priority';
      default:
        return 'Low priority';
    }
  }

  Widget _buildMilestoneRow(
      _Milestone m, int index, int total) {
    final isFirst = index == 0;
    final isLast = index == total - 1;
    final now = DateTime.now();
    final isPast = m.date.isBefore(now);

    Color dotColor;
    if (m.isCompleted) {
      dotColor = DesignTokens.success;
    } else if (m.type == _MilestoneType.event) {
      dotColor = DesignTokens.primaryColor;
    } else {
      switch (m.priority ?? 'medium') {
        case 'high':
          dotColor = DesignTokens.error;
          break;
        case 'low':
          dotColor = DesignTokens.success;
          break;
        default:
          dotColor = DesignTokens.warning;
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: DesignTokens.surfaceVariant,
                    ),
                  ),
                Container(
                  width: m.type == _MilestoneType.event ? 16 : 12,
                  height: m.type == _MilestoneType.event ? 16 : 12,
                  decoration: BoxDecoration(
                    color: m.isCompleted ? dotColor : Colors.transparent,
                    border: Border.all(color: dotColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: m.isCompleted
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 8)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: DesignTokens.surfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spacingM),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spacingM),
              child: SyncSphereCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (m.type == _MilestoneType.event)
                                const Padding(
                                  padding: EdgeInsets.only(
                                      right: DesignTokens.spacingXS),
                                  child: Icon(Icons.flag_outlined,
                                      size: 14,
                                      color: DesignTokens.primaryColor),
                                ),
                              Expanded(
                                child: Text(
                                  m.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: m.isCompleted
                                        ? DesignTokens.textHint
                                        : null,
                                    decoration: m.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.subtitle,
                            style: const TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('MMM d').format(m.date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPast
                                ? DesignTokens.textHint
                                : dotColor,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy').format(m.date),
                          style: const TextStyle(
                              fontSize: 10,
                              color: DesignTokens.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneType { event, task }

class _Milestone {
  final DateTime date;
  final String title;
  final String subtitle;
  final _MilestoneType type;
  final bool isCompleted;
  final String? priority;

  _Milestone({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.isCompleted,
    this.priority,
  });
}
