// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      blockchain: json['blockchain'] as String,
      status: $enumDecode(_$WalletStatusEnumMap, json['status']),
      balances: (json['balances'] as List<dynamic>)
          .map((e) => TokenBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'blockchain': instance.blockchain,
      'status': _$WalletStatusEnumMap[instance.status]!,
      'balances': instance.balances,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$WalletStatusEnumMap = {
  WalletStatus.active: 'active',
  WalletStatus.inactive: 'inactive',
  WalletStatus.suspended: 'suspended',
};

TokenBalance _$TokenBalanceFromJson(Map<String, dynamic> json) => TokenBalance(
      token: json['token'] as String,
      symbol: json['symbol'] as String,
      balance: (json['balance'] as num).toDouble(),
      usdValue: (json['usdValue'] as num).toDouble(),
      decimals: (json['decimals'] as num).toInt(),
    );

Map<String, dynamic> _$TokenBalanceToJson(TokenBalance instance) =>
    <String, dynamic>{
      'token': instance.token,
      'symbol': instance.symbol,
      'balance': instance.balance,
      'usdValue': instance.usdValue,
      'decimals': instance.decimals,
    };

WalletSummary _$WalletSummaryFromJson(Map<String, dynamic> json) =>
    WalletSummary(
      totalWallets: (json['totalWallets'] as num).toInt(),
      activeChains: (json['activeChains'] as num).toInt(),
      tokenSummaries: (json['tokenSummaries'] as List<dynamic>)
          .map((e) => TokenSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      chainSummaries: (json['chainSummaries'] as List<dynamic>)
          .map((e) => ChainSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUsdValue: (json['totalUsdValue'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$WalletSummaryToJson(WalletSummary instance) =>
    <String, dynamic>{
      'totalWallets': instance.totalWallets,
      'activeChains': instance.activeChains,
      'tokenSummaries': instance.tokenSummaries,
      'chainSummaries': instance.chainSummaries,
      'totalUsdValue': instance.totalUsdValue,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

TokenSummary _$TokenSummaryFromJson(Map<String, dynamic> json) => TokenSummary(
      symbol: json['symbol'] as String,
      totalBalance: (json['totalBalance'] as num).toDouble(),
      usdValue: (json['usdValue'] as num).toDouble(),
      walletCount: (json['walletCount'] as num).toInt(),
    );

Map<String, dynamic> _$TokenSummaryToJson(TokenSummary instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'totalBalance': instance.totalBalance,
      'usdValue': instance.usdValue,
      'walletCount': instance.walletCount,
    };

ChainSummary _$ChainSummaryFromJson(Map<String, dynamic> json) => ChainSummary(
      name: json['name'] as String,
      walletCount: (json['walletCount'] as num).toInt(),
      totalUsdValue: (json['totalUsdValue'] as num).toDouble(),
      topTokens: (json['topTokens'] as List<dynamic>)
          .map((e) => TokenBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChainSummaryToJson(ChainSummary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'walletCount': instance.walletCount,
      'totalUsdValue': instance.totalUsdValue,
      'topTokens': instance.topTokens,
    };
