import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../models/wallet_model.dart';

class WalletService {
  final HttpService _httpService;

  WalletService(this._httpService);

  Future<List<WalletModel>> getWallets() async {
    try {
      final response = await _httpService.get('/wallets');
      final List<dynamic> data = response.data['wallets'] ?? [];
      return data.map((json) => WalletModel.fromJson(json)).toList();
    } catch (e) {
      return _getMockWallets();
    }
  }

  Future<WalletSummary> getWalletSummary() async {
    try {
      final response = await _httpService.get('/wallets/summary');
      return WalletSummary.fromJson(response.data);
    } catch (e) {
      return _getMockWalletSummary();
    }
  }

  Future<WalletModel> getWallet(String walletId) async {
    try {
      final response = await _httpService.get('/wallets/$walletId');
      return WalletModel.fromJson(response.data);
    } catch (e) {
      return _getMockWallets().first;
    }
  }

  List<WalletModel> _getMockWallets() {
    return [
      WalletModel(
        id: '1',
        name: 'Main Ethereum Wallet',
        address: '0x742d35Cc6634C0532925a3b8D4C9db4C4C4C4C4C',
        blockchain: 'ethereum',
        balances: [
          const TokenBalance(
            token: 'USDC',
            symbol: 'USDC',
            balance: 1500.0,
            decimals: 6,
            usdValue: 1500.0,
          ),
          const TokenBalance(
            token: 'USDT',
            symbol: 'USDT',
            balance: 2500.0,
            decimals: 6,
            usdValue: 2500.0,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActivity: DateTime.now(),
        status: WalletStatus.active,
      ),
      WalletModel(
        id: '2',
        name: 'Polygon Wallet',
        address: '0x8ba1f109551bD432803012645Hac136c22C4C4C4C',
        blockchain: 'polygon',
        balances: [
          const TokenBalance(
            token: 'USDC',
            symbol: 'USDC',
            balance: 750.0,
            decimals: 6,
            usdValue: 750.0,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActivity: DateTime.now(),
        status: WalletStatus.active,
      ),
    ];
  }

  WalletSummary _getMockWalletSummary() {
    return WalletSummary(
      totalWallets: 2,
      activeChains: 2,
      totalUsdValue: 4750.0,
      chainSummaries: [
        ChainSummary(
          name: 'ethereum',
          walletCount: 1,
          totalUsdValue: 4000.0,
          topTokens: [
            const TokenBalance(
              token: 'USDT',
              symbol: 'USDT',
              balance: 2500.0,
              decimals: 6,
              usdValue: 2500.0,
            ),
            const TokenBalance(
              token: 'USDC',
              symbol: 'USDC',
              balance: 1500.0,
              decimals: 6,
              usdValue: 1500.0,
            ),
          ],
        ),
        ChainSummary(
          name: 'polygon',
          walletCount: 1,
          totalUsdValue: 750.0,
          topTokens: [
            const TokenBalance(
              token: 'USDC',
              symbol: 'USDC',
              balance: 750.0,
              decimals: 6,
              usdValue: 750.0,
            ),
          ],
        ),
      ],
      tokenSummaries: [
        const TokenSummary(
          symbol: 'USDT',
          totalBalance: 2500.0,
          usdValue: 2500.0,
          walletCount: 1,
        ),
        const TokenSummary(
          symbol: 'USDC',
          totalBalance: 2250.0,
          usdValue: 2250.0,
          walletCount: 2,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}
