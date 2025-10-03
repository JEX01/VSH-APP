import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'all';

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
        title: const Text('My Photos'),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PhotoGrid(filter: PhotoFilter.all, searchQuery: _searchQuery),
          _PhotoGrid(filter: PhotoFilter.pending, searchQuery: _searchQuery),
          _PhotoGrid(filter: PhotoFilter.approved, searchQuery: _searchQuery),
          _PhotoGrid(filter: PhotoFilter.rejected, searchQuery: _searchQuery),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Photos'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search by equipment, notes, or date...',
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
        title: const Text('Filter Photos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All Photos'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            RadioListTile<String>(
              title: const Text('This Week'),
              value: 'week',
              groupValue: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            RadioListTile<String>(
              title: const Text('This Month'),
              value: 'month',
              groupValue: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            RadioListTile<String>(
              title: const Text('With Notes'),
              value: 'notes',
              groupValue: _selectedFilter,
              onChanged: (value) => setState(() => _selectedFilter = value!),
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
}

enum PhotoFilter { all, pending, approved, rejected }

class _PhotoGrid extends StatelessWidget {
  final PhotoFilter filter;
  final String searchQuery;

  const _PhotoGrid({
    required this.filter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final photos = _getMockPhotos().where((photo) {
      // Filter by status
      bool statusMatch = true;
      switch (filter) {
        case PhotoFilter.all:
          statusMatch = true;
          break;
        case PhotoFilter.pending:
          statusMatch = photo['status'] == 'pending';
          break;
        case PhotoFilter.approved:
          statusMatch = photo['status'] == 'approved';
          break;
        case PhotoFilter.rejected:
          statusMatch = photo['status'] == 'rejected';
          break;
      }

      // Filter by search query
      bool searchMatch = true;
      if (searchQuery.isNotEmpty) {
        searchMatch = photo['equipmentName']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (photo['notes'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }

      return statusMatch && searchMatch;
    }).toList();

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No photos found for "$searchQuery"'
                  : 'No ${filter.name} photos',
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
        // Refresh photos
        await Future.delayed(const Duration(seconds: 1));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoCard(photo: photo);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getMockPhotos() {
    return [
      {
        'id': '1',
        'filename': 'boiler_inspection_001.jpg',
        'equipmentId': 'BOILER-001',
        'equipmentName': 'Main Boiler Unit 1',
        'status': 'approved',
        'capturedAt': DateTime.now().subtract(const Duration(hours: 2)),
        'notes': 'Normal operation, no issues detected',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=1',
        'latitude': 24.1995,
        'longitude': 82.6741,
      },
      {
        'id': '2',
        'filename': 'turbine_check_002.jpg',
        'equipmentId': 'TURBINE-001',
        'equipmentName': 'Steam Turbine Unit 1',
        'status': 'pending',
        'capturedAt': DateTime.now().subtract(const Duration(hours: 4)),
        'notes': 'Slight vibration noticed during operation',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=2',
        'latitude': 24.1997,
        'longitude': 82.6743,
      },
      {
        'id': '3',
        'filename': 'generator_maintenance.jpg',
        'equipmentId': 'GEN-001',
        'equipmentName': 'Generator Unit 1',
        'status': 'approved',
        'capturedAt': DateTime.now().subtract(const Duration(days: 1)),
        'notes': 'Monthly maintenance completed successfully',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=3',
        'latitude': 24.1999,
        'longitude': 82.6745,
      },
      {
        'id': '4',
        'filename': 'pump_pressure_test.jpg',
        'equipmentId': 'PUMP-001',
        'equipmentName': 'Boiler Feed Pump 1A',
        'status': 'rejected',
        'capturedAt': DateTime.now().subtract(const Duration(days: 2)),
        'notes': 'Pressure readings within normal range',
        'rejectionReason': 'Image quality too low, please retake',
        'thumbnailUrl': 'https://picsum.photos/300/400?random=4',
        'latitude': 24.1994,
        'longitude': 82.6740,
      },
      {
        'id': '5',
        'filename': 'transformer_inspection.jpg',
        'equipmentId': 'TRANSFORMER-001',
        'equipmentName': 'Main Power Transformer 1',
        'status': 'pending',
        'capturedAt': DateTime.now().subtract(const Duration(hours: 6)),
        'notes': null,
        'thumbnailUrl': 'https://picsum.photos/300/400?random=5',
        'latitude': 24.2001,
        'longitude': 82.6747,
      },
    ];
  }
}

class _PhotoCard extends StatelessWidget {
  final Map<String, dynamic> photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPhotoDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo thumbnail
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: photo['thumbnailUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _StatusBadge(status: photo['status']),
                  ),
                  
                  // Location indicator
                  if (photo['latitude'] != null && photo['longitude'] != null)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            
            // Photo info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Equipment name
                    Text(
                      photo['equipmentName'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Equipment ID
                    Text(
                      photo['equipmentId'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Capture time
                    Text(
                      _formatCaptureTime(photo['capturedAt']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                    
                    // Notes indicator
                    if (photo['notes'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              photo['notes'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(photo: photo),
      ),
    );
  }

  String _formatCaptureTime(DateTime capturedAt) {
    final now = DateTime.now();
    final difference = now.difference(capturedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          photo['equipmentName'],
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              if (photo['status'] == 'rejected')
                const PopupMenuItem(
                  value: 'retake',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('Retake Photo'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo viewer
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: photo['thumbnailUrl'],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Photo details
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and equipment
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photo['equipmentName'],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                photo['equipmentId'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: photo['status']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Capture info
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Captured',
                      value: _formatDateTime(photo['capturedAt']),
                    ),
                    
                    // Location info
                    if (photo['latitude'] != null && photo['longitude'] != null)
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: '${photo['latitude'].toStringAsFixed(6)}, ${photo['longitude'].toStringAsFixed(6)}',
                      ),
                    
                    // File info
                    _DetailRow(
                      icon: Icons.image,
                      label: 'Filename',
                      value: photo['filename'],
                    ),
                    
                    // Notes
                    if (photo['notes'] != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(photo['notes']),
                      ),
                    ],
                    
                    // Rejection reason
                    if (photo['status'] == 'rejected' && photo['rejectionReason'] != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red[600], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Rejection Reason',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              photo['rejectionReason'],
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        // Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon')),
        );
        break;
      case 'download':
        // Implement download functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download functionality coming soon')),
        );
        break;
      case 'retake':
        // Navigate to camera to retake photo
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to camera to retake photo')),
        );
        break;
    }
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