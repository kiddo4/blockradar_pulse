import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String id;
  final String hash;
  final String walletId;
  final String blockchain;
  final TransactionType type;
  final TransactionStatus status;
  final String amount;
  final String token;
  final String? fromAddress;
  final String? toAddress;
  final double? gasFee;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const TransactionModel({
    required this.id,
    required this.hash,
    required this.walletId,
    required this.blockchain,
    required this.type,
    required this.status,
    required this.amount,
    required this.token,
    this.fromAddress,
    this.toAddress,
    this.gasFee,
    required this.timestamp,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

enum TransactionType {
  @JsonValue('deposit')
  deposit,
  @JsonValue('sweep')
  sweep,
  @JsonValue('transfer')
  transfer,
  @JsonValue('withdrawal')
  withdrawal,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}
