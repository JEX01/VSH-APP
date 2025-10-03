import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  String _searchQuery = '';
  String _selectedType = 'all';
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedType != 'all' || _selectedStatus != 'all')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedType != 'all')
                    FilterChip(
                      label: Text('Type: $_selectedType'),
                      onDeleted: () => setState(() => _selectedType = 'all'),
                    ),
                  if (_selectedStatus != 'all')
                    FilterChip(
                      label: Text('Status: $_selectedStatus'),
                      onDeleted: () => setState(() => _selectedStatus = 'all'),
                    ),
                ],
              ),
            ),
          
          // Equipment list
          Expanded(
            child: _EquipmentList(
              searchQuery: _searchQuery,
              selectedType: _selectedType,
              selectedStatus: _selectedStatus,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQRScanner,
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan QR Code',
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Equipment'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search by name, code, or location...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equipment Type:'),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              onChanged: (value) => setState(() => _selectedType = value!),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'Boiler', child: Text('Boiler')),
                DropdownMenuItem(value: 'Turbine', child: Text('Turbine')),
                DropdownMenuItem(value: 'Generator', child: Text('Generator')),
                DropdownMenuItem(value: 'Pump', child: Text('Pump')),
                DropdownMenuItem(value: 'Transformer', child: Text('Transformer')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Status:'),
            DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              onChanged: (value) => setState(() => _selectedStatus = value!),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQRScanner() {
    // Navigate to QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner functionality coming soon')),
    );
  }
}

class _EquipmentList extends StatelessWidget {
  final String searchQuery;
  final String selectedType;
  final String selectedStatus;

  const _EquipmentList({
    required this.searchQuery,
    required this.selectedType,
    required this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    final equipment = _getMockEquipment().where((item) {
      // Filter by search query
      bool searchMatch = true;
      if (searchQuery.isNotEmpty) {
        searchMatch = item['equipmentName']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            item['equipmentCode']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (item['locationArea'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }

      // Filter by type
      bool typeMatch = selectedType == 'all' || item['equipmentType'] == selectedType;

      // Filter by status
      bool statusMatch = selectedStatus == 'all' || item['status'] == selectedStatus;

      return searchMatch && typeMatch && statusMatch;
    }).toList();

    if (equipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.precision_manufacturing_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No equipment found for "$searchQuery"'
                  : 'No equipment found',
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
        // Refresh equipment list
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: equipment.length,
        itemBuilder: (context, index) {
          final item = equipment[index];
          return _EquipmentCard(equipment: item);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getMockEquipment() {
    return [
      {
        'id': '1',
        'equipmentCode': 'BOILER-001',
        'equipmentName': 'Main Boiler Unit 1',
        'equipmentType': 'Boiler',
        'description': 'Primary steam generation boiler for Unit 1',
        'manufacturer': 'BHEL',
        'model': 'BH-500MW',
        'locationArea': 'Boiler Area',
        'status': 'active',
        'plantName': 'NTPC Plant A',
        'installationDate': DateTime(2020, 1, 15),
        'lastInspection': DateTime.now().subtract(const Duration(days: 7)),
        'photoCount': 15,
        'taskCount': 3,
      },
      {
        'id': '2',
        'equipmentCode': 'TURBINE-001',
        'equipmentName': 'Steam Turbine Unit 1',
        'equipmentType': 'Turbine',
        'description': 'High pressure steam turbine for Unit 1',
        'manufacturer': 'BHEL',
        'model': 'ST-500MW',
        'locationArea': 'Turbine Area',
        'status': 'active',
        'plantName': 'NTPC Plant A',
        'installationDate': DateTime(2020, 3, 20),
        'lastInspection': DateTime.now().subtract(const Duration(days: 3)),
        'photoCount': 8,
        'taskCount': 1,
      },
      {
        'id': '3',
        'equipmentCode': 'GEN-001',
        'equipmentName': 'Generator Unit 1',
        'equipmentType': 'Generator',
        'description': 'Synchronous generator for Unit 1',
        'manufacturer': 'BHEL',
        'model': 'GEN-500MW',
        'locationArea': 'Generator Area',
        'status': 'maintenance',
        'plantName': 'NTPC Plant A',
        'installationDate': DateTime(2020, 5, 10),
        'lastInspection': DateTime.now().subtract(const Duration(days: 1)),
        'photoCount': 12,
        'taskCount': 5,
      },
      {
        'id': '4',
        'equipmentCode': 'PUMP-001',
        'equipmentName': 'Boiler Feed Pump 1A',
        'equipmentType': 'Pump',
        'description': 'Primary boiler feed water pump',
        'manufacturer': 'KSB',
        'model': 'BFP-250',
        'locationArea': 'Boiler Area',
        'status': 'active',
        'plantName': 'NTPC Plant A',
        'installationDate': DateTime(2020, 2, 28),
        'lastInspection': DateTime.now().subtract(const Duration(days: 14)),
        'photoCount': 6,
        'taskCount': 2,
      },
      {
        'id': '5',
        'equipmentCode': 'TRANSFORMER-001',
        'equipmentName': 'Main Power Transformer 1',
        'equipmentType': 'Transformer',
        'description': 'Step-up transformer for Unit 1',
        'manufacturer': 'ABB',
        'model': 'TXF-500MVA',
        'locationArea': 'Switchyard',
        'status': 'active',
        'plantName': 'NTPC Plant A',
        'installationDate': DateTime(2020, 4, 15),
        'lastInspection': DateTime.now().subtract(const Duration(days: 21)),
        'photoCount': 4,
        'taskCount': 0,
      },
    ];
  }
}

class _EquipmentCard extends StatelessWidget {
  final Map<String, dynamic> equipment;

  const _EquipmentCard({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEquipmentDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment['equipmentName'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          equipment['equipmentCode'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: equipment['status']),
                ],
              ),
              const SizedBox(height: 12),
              
              // Equipment details
              Row(
                children: [
                  Icon(
                    _getEquipmentIcon(equipment['equipmentType']),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    equipment['equipmentType'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      equipment['locationArea'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Manufacturer and model
              Text(
                '${equipment['manufacturer']} - ${equipment['model']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              
              // Footer with stats and last inspection
              Row(
                children: [
                  _StatChip(
                    icon: Icons.photo_camera,
                    count: equipment['photoCount'],
                    label: 'Photos',
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.task,
                    count: equipment['taskCount'],
                    label: 'Tasks',
                  ),
                  const Spacer(),
                  Text(
                    'Last: ${_formatLastInspection(equipment['lastInspection'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
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

  void _showEquipmentDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EquipmentDetailScreen(equipment: equipment),
      ),
    );
  }

  IconData _getEquipmentIcon(String type) {
    switch (type) {
      case 'Boiler':
        return Icons.local_fire_department;
      case 'Turbine':
        return Icons.settings;
      case 'Generator':
        return Icons.electrical_services;
      case 'Pump':
        return Icons.water_drop;
      case 'Transformer':
        return Icons.power;
      default:
        return Icons.precision_manufacturing;
    }
  }

  String _formatLastInspection(DateTime lastInspection) {
    final now = DateTime.now();
    final difference = now.difference(lastInspection);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Today';
    }
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
      case 'active':
        color = Colors.green;
        displayText = 'Active';
        break;
      case 'maintenance':
        color = Colors.orange;
        displayText = 'Maintenance';
        break;
      case 'inactive':
        color = Colors.red;
        displayText = 'Inactive';
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
        border: Border.all(color: color.withOpacity(0.3)),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class EquipmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipment['equipmentName']),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showQRCode(context),
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getEquipmentIcon(equipment['equipmentType']),
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipment['equipmentName'],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                equipment['equipmentCode'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(status: equipment['status']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      equipment['description'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Equipment details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equipment Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.category,
                      label: 'Type',
                      value: equipment['equipmentType'],
                    ),
                    _DetailRow(
                      icon: Icons.business,
                      label: 'Manufacturer',
                      value: equipment['manufacturer'],
                    ),
                    _DetailRow(
                      icon: Icons.model_training,
                      label: 'Model',
                      value: equipment['model'],
                    ),
                    _DetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: equipment['locationArea'],
                    ),
                    _DetailRow(
                      icon: Icons.home_work,
                      label: 'Plant',
                      value: equipment['plantName'],
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Installation Date',
                      value: _formatDate(equipment['installationDate']),
                    ),
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Last Inspection',
                      value: _formatDate(equipment['lastInspection']),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.photo_camera,
                            count: equipment['photoCount'],
                            label: 'Photos',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.task,
                            count: equipment['taskCount'],
                            label: 'Active Tasks',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPhotos(context),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('View Photos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToTasks(context),
                    icon: const Icon(Icons.task),
                    label: const Text('View Tasks'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _capturePhoto(context),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture Photo'),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipment QR Code'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('QR Code\nPlaceholder'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToPhotos(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to equipment photos')),
    );
  }

  void _navigateToTasks(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to equipment tasks')),
    );
  }

  void _capturePhoto(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to camera for this equipment')),
    );
  }

  IconData _getEquipmentIcon(String type) {
    switch (type) {
      case 'Boiler':
        return Icons.local_fire_department;
      case 'Turbine':
        return Icons.settings;
      case 'Generator':
        return Icons.electrical_services;
      case 'Pump':
        return Icons.water_drop;
      case 'Transformer':
        return Icons.power;
      default:
        return Icons.precision_manufacturing;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}