import 'package:json_annotation/json_annotation.dart';

part 'api_status_model.g.dart';

@JsonSerializable()
class ApiStatusModel {
  final String status;
  final DateTime lastCheck;
  final int responseTime;
  final List<WebhookStatus> webhooks;
  final List<ServiceStatus> services;
  final Map<String, dynamic>? metadata;

  const ApiStatusModel({
    required this.status,
    required this.lastCheck,
    required this.responseTime,
    required this.webhooks,
    required this.services,
    this.metadata,
  });

  factory ApiStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ApiStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiStatusModelToJson(this);

  bool get isHealthy => status == 'healthy';
  String get overallStatus => status;
}

@JsonSerializable()
class WebhookStatus {
  final String id;
  final String url;
  final String status;
  final DateTime lastDelivery;
  final int successRate;
  final List<WebhookEvent> recentEvents;

  const WebhookStatus({
    required this.id,
    required this.url,
    required this.status,
    required this.lastDelivery,
    required this.successRate,
    required this.recentEvents,
  });

  factory WebhookStatus.fromJson(Map<String, dynamic> json) =>
      _$WebhookStatusFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookStatusToJson(this);

  bool get isHealthy => status == 'healthy';
  int get totalEvents => recentEvents.length;
  int get failedEvents =>
      recentEvents.where((e) => e.status != 'success').length;
}

@JsonSerializable()
class WebhookEvent {
  final String id;
  final String eventType;
  final DateTime timestamp;
  final int responseCode;
  final String status;
  final Map<String, dynamic>? payload;

  const WebhookEvent({
    required this.id,
    required this.eventType,
    required this.timestamp,
    required this.responseCode,
    required this.status,
    this.payload,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) =>
      _$WebhookEventFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookEventToJson(this);

  bool get success => status == 'success';
}

@JsonSerializable()
class ServiceStatus {
  final String name;
  final String status;
  final int responseTime;
  final DateTime lastCheck;
  final double uptime;

  const ServiceStatus({
    required this.name,
    required this.status,
    required this.responseTime,
    required this.lastCheck,
    required this.uptime,
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceStatusToJson(this);

  bool get healthy => status == 'healthy';
  bool get degraded => status == 'degraded';
  bool get down => status == 'down';
}
