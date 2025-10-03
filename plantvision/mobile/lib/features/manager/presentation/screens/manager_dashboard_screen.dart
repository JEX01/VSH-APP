import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen>
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
        title: const Text('Manager Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Photo Review'),
            Tab(text: 'Task Management'),
            Tab(text: 'Audit Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _PhotoReviewTab(),
          _TaskManagementTab(),
          _AuditLogsTab(),
        ],
      ),
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Pending Photos',
                  value: '12',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Active Tasks',
                  value: '8',
                  icon: Icons.task,
                  color: Colors.blue,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Overdue Tasks',
                  value: '3',
                  icon: Icons.warning,
                  color: Colors.red,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Active Workers',
                  value: '15',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent activity section
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Activity list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) => _ActivityItem(
              activity: _getMockActivities()[index],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Assign Task',
                  icon: Icons.add_task,
                  color: Colors.blue,
                  onTap: () => _showAssignTaskDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'Photo Comparison',
                  icon: Icons.compare,
                  color: Colors.purple,
                  onTap: () => _showPhotoComparison(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'type': 'photo_uploaded',
        'user': 'Ramesh Yadav',
        'equipment': 'BOILER-001',
        'time': DateTime.now().subtract(const Duration(minutes: 15)),
        'description': 'uploaded a photo of Main Boiler Unit 1',
      },
      {
        'type': 'task_completed',
        'user': 'Kavita Devi',
        'equipment': 'TURBINE-001',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'description': 'completed turbine inspection task',
      },
      {
        'type': 'photo_approved',
        'user': 'Manager Singh',
        'equipment': 'GEN-001',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'description': 'approved generator maintenance photo',
      },
      {
        'type': 'task_assigned',
        'user': 'Manager Patel',
        'equipment': 'PUMP-001',
        'time': DateTime.now().subtract(const Duration(hours: 3)),
        'description': 'assigned pump inspection to Suresh Kumar',
      },
      {
        'type': 'photo_rejected',
        'user': 'Manager Singh',
        'equipment': 'TRANSFORMER-001',
        'time': DateTime.now().subtract(const Duration(hours: 4)),
        'description': 'rejected transformer photo - poor quality',
      },
    ];
  }

  void _showAssignTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AssignTaskDialog(),
    );
  }

  void _showPhotoComparison(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhotoComparisonScreen(),
      ),
    );
  }
}

// Photo Review Tab
class _PhotoReviewTab extends StatelessWidget {
  const _PhotoReviewTab();

  @override
  Widget build(BuildContext context) {
    final pendingPhotos = _getMockPendingPhotos();
    
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search photos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),
        
        // Photo list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pendingPhotos.length,
            itemBuilder: (context, index) {
              final photo = pendingPhotos[index];
              return _PhotoReviewCard(photo: photo);
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockPendingPhotos() {
    return [
      {
        'id': '1',
        'filename': 'boiler_inspection_001.jpg',
        'user': 'Ramesh Yadav',
        'equipment': 'BOILER-001',
        'equipmentName': 'Main Boiler Unit 1',
        'capturedAt': DateTime.now().subtract(const Duration(minutes: 15)),
        'notes': 'Normal operation, no issues detected',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=1',
      },
      {
        'id': '2',
        'filename': 'turbine_check_002.jpg',
        'user': 'Kavita Devi',
        'equipment': 'TURBINE-001',
        'equipmentName': 'Steam Turbine Unit 1',
        'capturedAt': DateTime.now().subtract(const Duration(hours: 1)),
        'notes': 'Slight vibration noticed during operation',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=2',
      },
    ];
  }
}

// Task Management Tab
class _TaskManagementTab extends StatelessWidget {
  const _TaskManagementTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignTaskDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Assign New Task'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),
        
        // Task statistics
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _TaskStatCard(
                  title: 'Pending',
                  count: 8,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TaskStatCard(
                  title: 'In Progress',
                  count: 5,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TaskStatCard(
                  title: 'Overdue',
                  count: 3,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TaskStatCard(
                  title: 'Completed',
                  count: 24,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Task list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _ManagerTaskCard(
                task: _getMockTasks()[index],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockTasks() {
    return [
      {
        'id': '1',
        'title': 'Inspect Boiler Unit 1',
        'assignedTo': 'Ramesh Yadav',
        'equipment': 'BOILER-001',
        'priority': 'high',
        'status': 'pending',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'title': 'Check Turbine Vibration',
        'assignedTo': 'Kavita Devi',
        'equipment': 'TURBINE-001',
        'priority': 'medium',
        'status': 'in_progress',
        'dueDate': DateTime.now().add(const Duration(days: 3)),
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
  }

  void _showAssignTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AssignTaskDialog(),
    );
  }
}

// Audit Logs Tab
class _AuditLogsTab extends StatelessWidget {
  const _AuditLogsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Action Type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Actions')),
                    DropdownMenuItem(value: 'photo_upload', child: Text('Photo Upload')),
                    DropdownMenuItem(value: 'task_assign', child: Text('Task Assignment')),
                    DropdownMenuItem(value: 'approval', child: Text('Approvals')),
                  ],
                  onChanged: (value) {},
                  value: 'all',
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.date_range),
              ),
            ],
          ),
        ),
        
        // Audit log list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _AuditLogItem(
                log: _getMockAuditLogs()[index],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getMockAuditLogs() {
    return List.generate(10, (index) => {
      'id': '${index + 1}',
      'action': ['photo_upload', 'task_assign', 'approval', 'rejection'][index % 4],
      'user': ['Ramesh Yadav', 'Kavita Devi', 'Manager Singh', 'Manager Patel'][index % 4],
      'resource': 'BOILER-00${index + 1}',
      'timestamp': DateTime.now().subtract(Duration(hours: index)),
      'details': 'Action performed on equipment',
    });
  }
}

// Helper Widgets

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActivityColor(activity['type']),
          child: Icon(
            _getActivityIcon(activity['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(activity['user']),
        subtitle: Text(activity['description']),
        trailing: Text(
          _formatTime(activity['time']),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'photo_uploaded':
        return Colors.blue;
      case 'task_completed':
        return Colors.green;
      case 'photo_approved':
        return Colors.green;
      case 'task_assigned':
        return Colors.orange;
      case 'photo_rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'photo_uploaded':
        return Icons.camera_alt;
      case 'task_completed':
        return Icons.check_circle;
      case 'photo_approved':
        return Icons.thumb_up;
      case 'task_assigned':
        return Icons.assignment;
      case 'photo_rejected':
        return Icons.thumb_down;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoReviewCard extends StatelessWidget {
  final Map<String, dynamic> photo;

  const _PhotoReviewCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            
            // Photo info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo['equipmentName'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('By: ${photo['user']}'),
                  Text('Equipment: ${photo['equipment']}'),
                  if (photo['notes'] != null)
                    Text(
                      photo['notes'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Column(
              children: [
                IconButton(
                  onPressed: () => _approvePhoto(context, photo['id']),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                ),
                IconButton(
                  onPressed: () => _rejectPhoto(context, photo['id']),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _approvePhoto(BuildContext context, String photoId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectPhoto(BuildContext context, String photoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Photo'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Enter reason for rejection...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _TaskStatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _TaskStatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _ManagerTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(task['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned to: ${task['assignedTo']}'),
            Text('Equipment: ${task['equipment']}'),
            Text('Due: ${_formatDate(task['dueDate'])}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PriorityChip(priority: task['priority']),
            const SizedBox(height: 4),
            _StatusChip(status: task['status']),
          ],
        ),
        onTap: () {
          // Navigate to task details
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class _AuditLogItem extends StatelessWidget {
  final Map<String, dynamic> log;

  const _AuditLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getActionIcon(log['action']),
          color: _getActionColor(log['action']),
        ),
        title: Text('${log['user']} - ${log['action'].replaceAll('_', ' ')}'),
        subtitle: Text('Resource: ${log['resource']}'),
        trailing: Text(
          _formatTime(log['timestamp']),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'photo_upload':
        return Icons.camera_alt;
      case 'task_assign':
        return Icons.assignment;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'photo_upload':
        return Colors.blue;
      case 'task_assign':
        return Colors.orange;
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
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
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Dialogs and Additional Screens

class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key});

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedWorker = '';
  String _selectedEquipment = '';
  String _selectedPriority = 'medium';
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Assign to Worker',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'worker1', child: Text('Ramesh Yadav')),
                DropdownMenuItem(value: 'worker2', child: Text('Kavita Devi')),
                DropdownMenuItem(value: 'worker3', child: Text('Suresh Kumar')),
              ],
              onChanged: (value) => setState(() => _selectedWorker = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Equipment',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'BOILER-001', child: Text('BOILER-001 - Main Boiler Unit 1')),
                DropdownMenuItem(value: 'TURBINE-001', child: Text('TURBINE-001 - Steam Turbine Unit 1')),
                DropdownMenuItem(value: 'GEN-001', child: Text('GEN-001 - Generator Unit 1')),
              ],
              onChanged: (value) => setState(() => _selectedEquipment = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: _selectedPriority,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (value) => setState(() => _selectedPriority = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_dueDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Assign task logic
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task assigned successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Assign Task'),
        ),
      ],
    );
  }
}

class PhotoComparisonScreen extends StatelessWidget {
  const PhotoComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Comparison'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Photo Comparison Feature - Coming Soon'),
      ),
    );
  }
}