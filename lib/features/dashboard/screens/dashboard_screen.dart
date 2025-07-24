import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../wallet/models/wallet_model.dart';
import '../../wallet/services/wallet_service.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../../ai_chat/screens/ai_chat_screen.dart';
import '../../../core/constants/app_constants.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletSummaryAsync = ref.watch(walletSummaryProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      floatingActionButton: _buildAskPulseFAB(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletSummaryProvider);
            ref.invalidate(walletsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                walletSummaryAsync.when(
                  data: (summary) => _buildSummaryCards(context, summary),
                  loading: () => _buildSummaryLoading(),
                  error: (error, stack) => _buildErrorCard(context, error),
                ),
                const SizedBox(height: AppSpacing.xl),
                walletsAsync.when(
                  data: (wallets) => _buildWalletsList(context, wallets),
                  loading: () => _buildWalletsLoading(),
                  error: (error, stack) => _buildErrorCard(context, error),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Monitor your wallets and transactions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, WalletSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Wallets',
                summary.totalWallets.toString(),
                Icons.account_balance_wallet_outlined,
                const Color(AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Active Chains',
                summary.activeChains.toString(),
                Icons.link_outlined,
                const Color(AppColors.success),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTokenSummaryCard(context, summary.tokenSummaries),
        const SizedBox(height: AppSpacing.md),
        _buildChainSummaryCard(context, summary.chainSummaries),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSummaryCard(
    BuildContext context,
    List<TokenSummary> tokens,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.toll_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Token Balances',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...tokens.map(
              (token) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      token.symbol,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      NumberFormat('#,##0.00').format(token.totalBalance),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainSummaryCard(
    BuildContext context,
    List<ChainSummary> chains,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.hub_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Chain Distribution',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...chains.map(
              (chain) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getChainColor(chain.name),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          chain.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Text(
                      '${chain.walletCount} wallets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletsList(BuildContext context, List<WalletModel> wallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Wallets',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...wallets.take(5).map((wallet) => _buildWalletCard(context, wallet)),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletModel wallet) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name ?? 'Wallet ${wallet.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, wallet.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getChainColor(wallet.blockchain),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  wallet.blockchain,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${wallet.balances.length} tokens',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, WalletStatus status) {
    Color color;
    String text;

    switch (status) {
      case WalletStatus.active:
        color = const Color(AppColors.success);
        text = 'Active';
        break;
      case WalletStatus.inactive:
        color = const Color(AppColors.warning);
        text = 'Inactive';
        break;
      case WalletStatus.suspended:
        color = const Color(AppColors.error);
        text = 'Suspended';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryLoading() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLoadingCard(),
        const SizedBox(height: AppSpacing.md),
        _buildLoadingCard(),
      ],
    );
  }

  Widget _buildWalletsLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildLoadingCard(),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(AppColors.onSurfaceVariant).withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(AppColors.onSurfaceVariant).withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(AppColors.error),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getChainColor(String chain) {
    // Using consistent Blockradar green theme for all chains
    return const Color(AppColors.primary);
  }

  Widget _buildAskPulseFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppColors.primary), Color(AppColors.accent)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primary).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AIChatScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(
          Icons.psychology_outlined,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'Ask Pulse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
