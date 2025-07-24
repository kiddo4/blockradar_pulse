import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../../../core/services/http_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return WalletService(httpService);
});

final walletsProvider = FutureProvider<List<WalletModel>>((ref) async {
  final walletService = ref.read(walletServiceProvider);
  return await walletService.getWallets();
});

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  final walletService = ref.read(walletServiceProvider);
  return await walletService.getWalletSummary();
});

final walletProvider = FutureProvider.family<WalletModel?, String>((
  ref,
  walletId,
) async {
  final walletService = ref.read(walletServiceProvider);
  return await walletService.getWallet(walletId);
});
