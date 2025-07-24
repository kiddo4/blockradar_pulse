// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      hash: json['hash'] as String,
      walletId: json['walletId'] as String,
      blockchain: json['blockchain'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      amount: json['amount'] as String,
      token: json['token'] as String,
      fromAddress: json['fromAddress'] as String?,
      toAddress: json['toAddress'] as String?,
      gasFee: (json['gasFee'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hash': instance.hash,
      'walletId': instance.walletId,
      'blockchain': instance.blockchain,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'token': instance.token,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'gasFee': instance.gasFee,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.deposit: 'deposit',
  TransactionType.sweep: 'sweep',
  TransactionType.transfer: 'transfer',
  TransactionType.withdrawal: 'withdrawal',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
};
