import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../../../core/services/http_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return TransactionService(httpService);
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final transactionService = ref.read(transactionServiceProvider);
  return await transactionService.getTransactions();
});

final recentTransactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final transactionService = ref.read(transactionServiceProvider);
  return await transactionService.getRecentTransactions();
});

final transactionStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final transactionService = ref.read(transactionServiceProvider);
  return transactionService.watchTransactions();
});

final transactionProvider = FutureProvider.family<TransactionModel?, String>((
  ref,
  transactionId,
) async {
  final transactionService = ref.read(transactionServiceProvider);
  return await transactionService.getTransaction(transactionId);
});
