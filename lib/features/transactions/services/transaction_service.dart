import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../models/transaction_model.dart';
import '../../../core/constants/app_constants.dart';

class TransactionService {
  final HttpService _httpService;

  TransactionService(this._httpService);

  Future<List<TransactionModel>> getTransactions({
    int limit = 50,
    int offset = 0,
    TransactionType? type,
    TransactionStatus? status,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (type != null) 'type': type.name,
        if (status != null) 'status': status.name,
      };

      final response = await _httpService.get(
        '/transactions',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['transactions'] ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      return _getMockTransactions(limit: limit, type: type, status: status);
    }
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    return getTransactions(limit: 20);
  }

  Future<TransactionModel> getTransaction(String transactionId) async {
    try {
      final response = await _httpService.get('/transactions/$transactionId');
      return TransactionModel.fromJson(response.data);
    } catch (e) {
      return _getMockTransactions(limit: 1).first;
    }
  }

  Stream<List<TransactionModel>> watchTransactions() async* {
    while (true) {
      yield await getRecentTransactions();
      await Future.delayed(
        const Duration(seconds: AppConstants.refreshInterval),
      );
    }
  }

  List<TransactionModel> _getMockTransactions({
    int limit = 50,
    TransactionType? type,
    TransactionStatus? status,
  }) {
    final now = DateTime.now();
    final mockTransactions = [
      TransactionModel(
        id: '1',
        hash: '0x1234567890abcdef1234567890abcdef12345678',
        walletId: '1',
        blockchain: 'ethereum',
        type: TransactionType.deposit,
        status: TransactionStatus.confirmed,
        amount: '1000000000',
        token: 'USDC',
        fromAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        toAddress: '0x742d35Cc6634C0532925a3b8D4C9db4C4C4C4C4C',
        gasFee: 0.0025,
        timestamp: now.subtract(const Duration(minutes: 5)),
        metadata: {'confirmations': 12},
      ),
      TransactionModel(
        id: '2',
        hash: '0xabcdef1234567890abcdef1234567890abcdef12',
        walletId: '1',
        blockchain: 'ethereum',
        type: TransactionType.sweep,
        status: TransactionStatus.confirmed,
        amount: '500000000',
        token: 'USDT',
        fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db4C4C4C4C4C',
        toAddress: '0x9876543210fedcba9876543210fedcba98765432',
        gasFee: 0.0018,
        timestamp: now.subtract(const Duration(minutes: 15)),
        metadata: {'confirmations': 25},
      ),
      TransactionModel(
        id: '3',
        hash: '0x9876543210fedcba9876543210fedcba98765432',
        walletId: '2',
        blockchain: 'polygon',
        type: TransactionType.deposit,
        status: TransactionStatus.pending,
        amount: '250000000',
        token: 'USDC',
        fromAddress: '0xfedcba9876543210fedcba9876543210fedcba98',
        toAddress: '0x8ba1f109551bD432803012645Hac136c22C4C4C4C',
        gasFee: 0.001,
        timestamp: now.subtract(const Duration(minutes: 2)),
        metadata: {'confirmations': 0},
      ),
      TransactionModel(
        id: '4',
        hash: '0xfedcba9876543210fedcba9876543210fedcba98',
        walletId: '1',
        blockchain: 'ethereum',
        type: TransactionType.sweep,
        status: TransactionStatus.failed,
        amount: '100000000',
        token: 'USDC',
        fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db4C4C4C4C4C',
        toAddress: '0x1111111111111111111111111111111111111111',
        gasFee: 0.0032,
        timestamp: now.subtract(const Duration(hours: 1)),
        metadata: {'error': 'Insufficient gas'},
      ),
      TransactionModel(
        id: '5',
        hash: '0x1111111111111111111111111111111111111111',
        walletId: '2',
        blockchain: 'polygon',
        type: TransactionType.withdrawal,
        status: TransactionStatus.confirmed,
        amount: '75000000',
        token: 'USDC',
        fromAddress: '0x8ba1f109551bD432803012645Hac136c22C4C4C4C',
        toAddress: '0x2222222222222222222222222222222222222222',
        gasFee: 0.0008,
        timestamp: now.subtract(const Duration(hours: 2)),
        metadata: {'confirmations': 45},
      ),
    ];

    var filtered = mockTransactions.where((tx) {
      if (type != null && tx.type != type) return false;
      if (status != null && tx.status != status) return false;
      return true;
    }).toList();

    return filtered.take(limit).toList();
  }
}
