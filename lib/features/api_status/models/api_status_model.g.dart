// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiStatusModel _$ApiStatusModelFromJson(Map<String, dynamic> json) =>
    ApiStatusModel(
      status: json['status'] as String,
      lastCheck: DateTime.parse(json['lastCheck'] as String),
      responseTime: (json['responseTime'] as num).toInt(),
      webhooks: (json['webhooks'] as List<dynamic>)
          .map((e) => WebhookStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>)
          .map((e) => ServiceStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiStatusModelToJson(ApiStatusModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'lastCheck': instance.lastCheck.toIso8601String(),
      'responseTime': instance.responseTime,
      'webhooks': instance.webhooks,
      'services': instance.services,
      'metadata': instance.metadata,
    };

WebhookStatus _$WebhookStatusFromJson(Map<String, dynamic> json) =>
    WebhookStatus(
      id: json['id'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      lastDelivery: DateTime.parse(json['lastDelivery'] as String),
      successRate: (json['successRate'] as num).toInt(),
      recentEvents: (json['recentEvents'] as List<dynamic>)
          .map((e) => WebhookEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WebhookStatusToJson(WebhookStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'status': instance.status,
      'lastDelivery': instance.lastDelivery.toIso8601String(),
      'successRate': instance.successRate,
      'recentEvents': instance.recentEvents,
    };

WebhookEvent _$WebhookEventFromJson(Map<String, dynamic> json) => WebhookEvent(
  id: json['id'] as String,
  eventType: json['eventType'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  responseCode: (json['responseCode'] as num).toInt(),
  status: json['status'] as String,
  payload: json['payload'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WebhookEventToJson(WebhookEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'timestamp': instance.timestamp.toIso8601String(),
      'responseCode': instance.responseCode,
      'status': instance.status,
      'payload': instance.payload,
    };

ServiceStatus _$ServiceStatusFromJson(Map<String, dynamic> json) =>
    ServiceStatus(
      name: json['name'] as String,
      status: json['status'] as String,
      responseTime: (json['responseTime'] as num).toInt(),
      lastCheck: DateTime.parse(json['lastCheck'] as String),
      uptime: (json['uptime'] as num).toDouble(),
    );

Map<String, dynamic> _$ServiceStatusToJson(ServiceStatus instance) =>
    <String, dynamic>{
      'name': instance.name,
      'status': instance.status,
      'responseTime': instance.responseTime,
      'lastCheck': instance.lastCheck.toIso8601String(),
      'uptime': instance.uptime,
    };
