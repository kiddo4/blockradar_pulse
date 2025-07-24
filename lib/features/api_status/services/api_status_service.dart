import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../models/api_status_model.dart';

class ApiStatusService {
  final HttpService _httpService;

  ApiStatusService(this._httpService);

  Future<ApiStatusModel> getApiStatus() async {
    try {
      final response = await _httpService.get('/status');
      return ApiStatusModel.fromJson(response.data);
    } catch (e) {
      return _getMockApiStatus();
    }
  }

  Future<List<WebhookStatus>> getWebhookStatus() async {
    try {
      final response = await _httpService.get('/webhooks/status');
      final List<dynamic> data = response.data['webhooks'] ?? [];
      return data.map((json) => WebhookStatus.fromJson(json)).toList();
    } catch (e) {
      return _getMockWebhookStatus();
    }
  }

  Future<List<ServiceStatus>> getServiceStatus() async {
    try {
      final response = await _httpService.get('/services/status');
      final List<dynamic> data = response.data['services'] ?? [];
      return data.map((json) => ServiceStatus.fromJson(json)).toList();
    } catch (e) {
      return _getMockServiceStatus();
    }
  }

  ApiStatusModel _getMockApiStatus() {
    return ApiStatusModel(
      status: 'healthy',
      lastCheck: DateTime.now(),
      responseTime: 125,
      webhooks: _getMockWebhookStatus(),
      services: _getMockServiceStatus(),
      metadata: {'version': '1.2.3', 'uptime': '99.9%', 'region': 'us-east-1'},
    );
  }

  List<WebhookStatus> _getMockWebhookStatus() {
    final now = DateTime.now();
    return [
      WebhookStatus(
        id: 'webhook_1',
        url: 'https://api.yourapp.com/webhooks/blockradar',
        status: 'active',
        lastDelivery: now.subtract(const Duration(minutes: 5)),
        successRate: 98,
        recentEvents: [
          WebhookEvent(
            id: 'event_1',
            eventType: 'transaction.deposit',
            timestamp: now.subtract(const Duration(minutes: 5)),
            responseCode: 200,
            status: 'delivered',
            payload: {
              'transaction_id': '1',
              'amount': '1000000000',
              'token': 'USDC',
            },
          ),
          WebhookEvent(
            id: 'event_2',
            eventType: 'transaction.sweep',
            timestamp: now.subtract(const Duration(minutes: 15)),
            responseCode: 200,
            status: 'delivered',
            payload: {
              'transaction_id': '2',
              'amount': '500000000',
              'token': 'USDT',
            },
          ),
        ],
      ),
      WebhookStatus(
        id: 'webhook_2',
        url: 'https://backup.yourapp.com/webhooks/blockradar',
        status: 'inactive',
        lastDelivery: now.subtract(const Duration(hours: 2)),
        successRate: 95,
        recentEvents: [
          WebhookEvent(
            id: 'event_3',
            eventType: 'transaction.failed',
            timestamp: now.subtract(const Duration(hours: 1)),
            responseCode: 500,
            status: 'failed',
            payload: {'transaction_id': '4', 'error': 'Internal server error'},
          ),
        ],
      ),
    ];
  }

  List<ServiceStatus> _getMockServiceStatus() {
    final now = DateTime.now();
    return [
      ServiceStatus(
        name: 'Wallet API',
        status: 'healthy',
        responseTime: 89,
        lastCheck: now,
        uptime: 99.95,
      ),
      ServiceStatus(
        name: 'Transaction API',
        status: 'healthy',
        responseTime: 156,
        lastCheck: now,
        uptime: 99.87,
      ),
      ServiceStatus(
        name: 'Webhook Service',
        status: 'degraded',
        responseTime: 245,
        lastCheck: now,
        uptime: 98.5,
      ),
      ServiceStatus(
        name: 'Blockchain Sync',
        status: 'healthy',
        responseTime: 67,
        lastCheck: now,
        uptime: 99.99,
      ),
    ];
  }
}
