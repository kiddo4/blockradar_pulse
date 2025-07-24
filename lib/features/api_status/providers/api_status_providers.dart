import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_status_model.dart';
import '../services/api_status_service.dart';
import '../../../core/services/http_service.dart';

final apiStatusServiceProvider = Provider<ApiStatusService>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ApiStatusService(httpService);
});

final apiStatusProvider = FutureProvider<ApiStatusModel>((ref) async {
  final apiStatusService = ref.read(apiStatusServiceProvider);
  return await apiStatusService.getApiStatus();
});

final webhookStatusProvider = FutureProvider<List<WebhookStatus>>((ref) async {
  final apiStatusService = ref.read(apiStatusServiceProvider);
  return await apiStatusService.getWebhookStatus();
});

final serviceStatusProvider = FutureProvider<List<ServiceStatus>>((ref) async {
  final apiStatusService = ref.read(apiStatusServiceProvider);
  return await apiStatusService.getServiceStatus();
});
