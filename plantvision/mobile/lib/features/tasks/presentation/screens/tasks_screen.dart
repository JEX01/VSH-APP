import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TasksList(filter: TaskFilter.all),
          _TasksList(filter: TaskFilter.pending),
          _TasksList(filter: TaskFilter.inProgress),
          _TasksList(filter: TaskFilter.completed),
        ],
      ),
    );
  }
}

enum TaskFilter { all, pending, inProgress, completed }

class _TasksList extends StatelessWidget {
  final TaskFilter filter;

  const _TasksList({required this.filter});

  @override
  Widget build(BuildContext context) {
    // Mock task data
    final tasks = _getMockTasks().where((task) {
      switch (filter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.pending:
          return task['status'] == 'pending';
        case TaskFilter.inProgress:
          return task['status'] == 'in_progress';
        case TaskFilter.completed:
          return task['status'] == 'completed';
      }
    }).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter.name} tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh tasks
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(task: task);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getMockTasks() {
    return [
      {
        'id': '1',
        'title': 'Inspect Boiler Unit 1',
        'description': 'Perform routine inspection of main boiler unit',
        'equipment': 'BOILER-001',
        'equipmentName': 'Main Boiler Unit 1',
        'priority': 'high',
        'status': 'pending',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'assignedBy': 'Manager Singh',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'title': 'Check Turbine Vibration',
        'description': 'Monitor turbine vibration levels and record readings',
        'equipment': 'TURBINE-001',
        'equipmentName': 'Steam Turbine Unit 1',
        'priority': 'medium',
        'status': 'in_progress',
        'dueDate': DateTime.now().add(const Duration(days: 3)),
        'assignedBy': 'Manager Patel',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'startedAt': DateTime.now().subtract(const Duration(hours: 4)),
      },
      {
        'id': '3',
        'title': 'Generator Maintenance Check',
        'description': 'Complete monthly maintenance inspection',
        'equipment': 'GEN-001',
        'equipmentName': 'Generator Unit 1',
        'priority': 'low',
        'status': 'completed',
        'dueDate': DateTime.now().subtract(const Duration(days: 1)),
        'assignedBy': 'Manager Singh',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'completedAt': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'id': '4',
        'title': 'Pump Pressure Test',
        'description': 'Test boiler feed pump pressure and flow rate',
        'equipment': 'PUMP-001',
        'equipmentName': 'Boiler Feed Pump 1A',
        'priority': 'urgent',
        'status': 'pending',
        'dueDate': DateTime.now().subtract(const Duration(hours: 2)), // Overdue
        'assignedBy': 'Manager Patel',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = (task['dueDate'] as DateTime).isBefore(DateTime.now()) &&
        task['status'] != 'completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? Colors.red : null,
                      ),
                    ),
                  ),
                  _PriorityChip(priority: task['priority']),
                ],
              ),
              const SizedBox(height: 8),
              
              // Equipment info
              Row(
                children: [
                  Icon(
                    Icons.precision_manufacturing,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task['equipment']} - ${task['equipmentName']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Description
              if (task['description'] != null)
                Text(
                  task['description'],
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              
              // Footer with status and due date
              Row(
                children: [
                  _StatusChip(status: task['status']),
                  const Spacer(),
                  Icon(
                    isOverdue ? Icons.warning : Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDueDate(task['dueDate']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TaskDetailsSheet(task: task),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      final overdue = now.difference(dueDate);
      if (overdue.inDays > 0) {
        return 'Overdue by ${overdue.inDays} days';
      } else if (overdue.inHours > 0) {
        return 'Overdue by ${overdue.inHours} hours';
      } else {
        return 'Overdue by ${overdue.inMinutes} minutes';
      }
    } else {
      if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'Due in ${difference.inHours} hours';
      } else {
        return 'Due in ${difference.inMinutes} minutes';
      }
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String displayText;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        displayText = 'Pending';
        break;
      case 'in_progress':
        color = Colors.blue;
        displayText = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        displayText = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TaskDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> task;

  const _TaskDetailsSheet({required this.task});

  @override
  State<_TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<_TaskDetailsSheet> {
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Title and priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task['title'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _PriorityChip(priority: widget.task['priority']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Status
                    Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        const Text('Status: '),
                        _StatusChip(status: widget.task['status']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Equipment
                    _DetailRow(
                      icon: Icons.precision_manufacturing,
                      label: 'Equipment',
                      value: '${widget.task['equipment']} - ${widget.task['equipmentName']}',
                    ),
                    
                    // Assigned by
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Assigned by',
                      value: widget.task['assignedBy'],
                    ),
                    
                    // Due date
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Due date',
                      value: _formatDateTime(widget.task['dueDate']),
                    ),
                    
                    // Created date
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatDateTime(widget.task['createdAt']),
                    ),
                    
                    // Started date (if applicable)
                    if (widget.task['startedAt'] != null)
                      _DetailRow(
                        icon: Icons.play_arrow,
                        label: 'Started',
                        value: _formatDateTime(widget.task['startedAt']),
                      ),
                    
                    // Completed date (if applicable)
                    if (widget.task['completedAt'] != null)
                      _DetailRow(
                        icon: Icons.check_circle,
                        label: 'Completed',
                        value: _formatDateTime(widget.task['completedAt']),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    if (widget.task['description'] != null) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.task['description']),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action buttons
                    if (widget.task['status'] != 'completed') ...[
                      if (widget.task['status'] == 'pending')
                        ElevatedButton.icon(
                          onPressed: () => _updateTaskStatus('in_progress'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Task'),
                        ),
                      
                      if (widget.task['status'] == 'in_progress') ...[
                        ElevatedButton.icon(
                          onPressed: () => _showCompleteTaskDialog(),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark Complete'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _updateTaskStatus('pending'),
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause Task'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTaskStatus(String newStatus) {
    // In a real app, this would call an API
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task status updated to ${newStatus.replaceAll('_', ' ')}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCompleteTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add completion notes (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter completion notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateTaskStatus('completed');
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}