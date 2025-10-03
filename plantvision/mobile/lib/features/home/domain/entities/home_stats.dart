class HomeStats {
  final int totalPhotos;
  final int pendingPhotos;
  final int approvedPhotos;
  final int rejectedPhotos;
  final int totalTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedTasks;
  final int overdueTasks;
  final int photosThisWeek;
  final int tasksThisWeek;
  final double completionRate;

  const HomeStats({
    required this.totalPhotos,
    required this.pendingPhotos,
    required this.approvedPhotos,
    required this.rejectedPhotos,
    required this.totalTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.photosThisWeek,
    required this.tasksThisWeek,
    required this.completionRate,
  });

  factory HomeStats.empty() {
    return const HomeStats(
      totalPhotos: 0,
      pendingPhotos: 0,
      approvedPhotos: 0,
      rejectedPhotos: 0,
      totalTasks: 0,
      pendingTasks: 0,
      inProgressTasks: 0,
      completedTasks: 0,
      overdueTasks: 0,
      photosThisWeek: 0,
      tasksThisWeek: 0,
      completionRate: 0.0,
    );
  }

  HomeStats copyWith({
    int? totalPhotos,
    int? pendingPhotos,
    int? approvedPhotos,
    int? rejectedPhotos,
    int? totalTasks,
    int? pendingTasks,
    int? inProgressTasks,
    int? completedTasks,
    int? overdueTasks,
    int? photosThisWeek,
    int? tasksThisWeek,
    double? completionRate,
  }) {
    return HomeStats(
      totalPhotos: totalPhotos ?? this.totalPhotos,
      pendingPhotos: pendingPhotos ?? this.pendingPhotos,
      approvedPhotos: approvedPhotos ?? this.approvedPhotos,
      rejectedPhotos: rejectedPhotos ?? this.rejectedPhotos,
      totalTasks: totalTasks ?? this.totalTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      photosThisWeek: photosThisWeek ?? this.photosThisWeek,
      tasksThisWeek: tasksThisWeek ?? this.tasksThisWeek,
      completionRate: completionRate ?? this.completionRate,
    );
  }

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalPhotos: json['totalPhotos'] as int? ?? 0,
      pendingPhotos: json['pendingPhotos'] as int? ?? 0,
      approvedPhotos: json['approvedPhotos'] as int? ?? 0,
      rejectedPhotos: json['rejectedPhotos'] as int? ?? 0,
      totalTasks: json['totalTasks'] as int? ?? 0,
      pendingTasks: json['pendingTasks'] as int? ?? 0,
      inProgressTasks: json['inProgressTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      overdueTasks: json['overdueTasks'] as int? ?? 0,
      photosThisWeek: json['photosThisWeek'] as int? ?? 0,
      tasksThisWeek: json['tasksThisWeek'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPhotos': totalPhotos,
      'pendingPhotos': pendingPhotos,
      'approvedPhotos': approvedPhotos,
      'rejectedPhotos': rejectedPhotos,
      'totalTasks': totalTasks,
      'pendingTasks': pendingTasks,
      'inProgressTasks': inProgressTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
      'photosThisWeek': photosThisWeek,
      'tasksThisWeek': tasksThisWeek,
      'completionRate': completionRate,
    };
  }
}