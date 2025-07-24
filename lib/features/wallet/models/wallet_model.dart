import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final String id;
  final String name;
  final String address;
  final String blockchain;
  final WalletStatus status;
  final List<TokenBalance> balances;
  final DateTime createdAt;
  final DateTime lastActivity;
  final Map<String, dynamic>? metadata;

  const WalletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.blockchain,
    required this.status,
    required this.balances,
    required this.createdAt,
    required this.lastActivity,
    this.metadata,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}

@JsonSerializable()
class TokenBalance {
  final String token;
  final String symbol;
  final double balance;
  final double usdValue;
  final int decimals;

  const TokenBalance({
    required this.token,
    required this.symbol,
    required this.balance,
    required this.usdValue,
    required this.decimals,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) =>
      _$TokenBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBalanceToJson(this);
}

@JsonSerializable()
class WalletSummary {
  final int totalWallets;
  final int activeChains;
  final List<TokenSummary> tokenSummaries;
  final List<ChainSummary> chainSummaries;
  final double totalUsdValue;
  final DateTime lastUpdated;

  const WalletSummary({
    required this.totalWallets,
    required this.activeChains,
    required this.tokenSummaries,
    required this.chainSummaries,
    required this.totalUsdValue,
    required this.lastUpdated,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) =>
      _$WalletSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$WalletSummaryToJson(this);
}

@JsonSerializable()
class TokenSummary {
  final String symbol;
  final double totalBalance;
  final double usdValue;
  final int walletCount;

  const TokenSummary({
    required this.symbol,
    required this.totalBalance,
    required this.usdValue,
    required this.walletCount,
  });

  factory TokenSummary.fromJson(Map<String, dynamic> json) =>
      _$TokenSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TokenSummaryToJson(this);
}

@JsonSerializable()
class ChainSummary {
  final String name;
  final int walletCount;
  final double totalUsdValue;
  final List<TokenBalance> topTokens;

  const ChainSummary({
    required this.name,
    required this.walletCount,
    required this.totalUsdValue,
    required this.topTokens,
  });

  factory ChainSummary.fromJson(Map<String, dynamic> json) =>
      _$ChainSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ChainSummaryToJson(this);
}

enum WalletStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}
