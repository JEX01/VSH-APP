import 'package:workmanager/workmanager.dart';

import '../config/app_config.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case AppConfig.backgroundSyncTask:
          // TODO: Implement sync logic
          // 1. Check network connectivity
          // 2. Fetch pending photos from sync_queue
          // 3. Upload photos with retry logic
          // 4. Update sync status
          // 5. Show notification on completion
          break;
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundSyncService {
  static final BackgroundSyncService instance = BackgroundSyncService._internal();
  
  bool _initialized = false;

  BackgroundSyncService._internal();

  Future<void> initialize() async {
    if (_initialized) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    _initialized = true;
  }

  Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      AppConfig.backgroundSyncTask,
      AppConfig.backgroundSyncTask,
      frequency: AppConfig.backgroundSyncFrequency,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: Duration(seconds: 10),
    );
  }

  Future<void> triggerImmediateSync() async {
    await Workmanager().registerOneOffTask(
      '${AppConfig.backgroundSyncTask}_immediate',
      AppConfig.backgroundSyncTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName(AppConfig.backgroundSyncTask);
  }

  Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}
