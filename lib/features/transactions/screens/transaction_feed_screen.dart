import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';

import '../../../core/constants/app_constants.dart' hide AppColors;
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../providers/transaction_providers.dart';

class TransactionFeedScreen extends ConsumerStatefulWidget {
  const TransactionFeedScreen({super.key});

  @override
  ConsumerState<TransactionFeedScreen> createState() =>
      _TransactionFeedScreenState();
}

class _TransactionFeedScreenState extends ConsumerState<TransactionFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  String _selectedChain = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsStream = ref.watch(transactionStreamProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: transactionsStream.when(
        data: (transactions) =>
            _buildSliverLayout(context, _filterTransactions(transactions)),
        loading: () => recentTransactions.when(
          data: (transactions) =>
              _buildSliverLayout(context, _filterTransactions(transactions)),
          loading: () => _buildSliverLayout(context, []),
          error: (error, stack) => _buildErrorState(context, error),
        ),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildSliverLayout(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(context),
        _buildSliverFilters(context),
        transactions.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState(context))
            : _buildSliverTransactionsList(context, transactions),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(AppColors.background),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(AppColors.background),
                const Color(AppColors.surface).withOpacity(0.5),
                const Color(AppColors.primary).withOpacity(0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundEffects(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(AppColors.primary),
                                          Color(AppColors.accent),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'TRANSACTION FEED',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Real-time monitoring',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: const Color(
                                          AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _buildLiveIndicator(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(AppColors.primary).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(AppColors.accent).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.primary).withOpacity(0.2),
            const Color(AppColors.accent).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: const Color(AppColors.primary).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(AppColors.primary),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'LIVE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(AppColors.primary),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverFilters(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFilterChips(
                    context,
                    'Type',
                    ['all', 'deposit', 'sweep', 'transfer'],
                    _selectedFilter,
                    (value) => setState(() => _selectedFilter = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildFilterChips(
                    context,
                    'Chain',
                    ['all', 'ethereum', 'polygon', 'bsc', 'arbitrum'],
                    _selectedChain,
                    (value) => setState(() => _selectedChain = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverTransactionsList(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final transaction = transactions[index];
          return _buildEnhancedTransactionCard(context, transaction, index);
        }, childCount: transactions.length),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppColors.background),
            const Color(AppColors.surface).withOpacity(0.5),
          ],
        ),
      ),
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
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(AppColors.primary),
                          Color(AppColors.accent),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'TRANSACTION FEED',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Real-time blockchain monitoring',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(AppColors.primary).withOpacity(0.2),
                      const Color(AppColors.accent).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primary),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              AppColors.primary,
                            ).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'LIVE',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(AppColors.primary),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterChips(
                  context,
                  'Type',
                  ['all', 'deposit', 'sweep', 'transfer'],
                  _selectedFilter,
                  (value) => setState(() => _selectedFilter = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildFilterChips(
                  context,
                  'Chain',
                  ['all', 'ethereum', 'polygon', 'bsc', 'arbitrum'],
                  _selectedChain,
                  (value) => setState(() => _selectedChain = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    String label,
    List<String> options,
    String selected,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          children: options.map((option) {
            final isSelected = option == selected;
            return FilterChip(
              label: Text(
                option == 'all' ? 'All' : option.capitalize(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : const Color(AppColors.onSurface),
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: const Color(AppColors.surface),
              selectedColor: const Color(AppColors.primary),
              side: BorderSide(
                color: isSelected
                    ? const Color(AppColors.primary)
                    : const Color(AppColors.border),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(recentTransactionsProvider);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.xl,
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildEnhancedTransactionCard(context, transaction, index);
        },
      ),
    );
  }

  Widget _buildEnhancedTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppSpacing.lg,
        top: index == 0 ? AppSpacing.md : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetails(context, transaction),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(AppColors.surface).withOpacity(0.9),
                  const Color(AppColors.surface).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: const Color(AppColors.primary).withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTransactionIcon(transaction.type),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.type.name.capitalize(),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                              _buildStatusChip(context, transaction.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                const Color(AppColors.primary),
                                const Color(AppColors.accent),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '${NumberFormat('#,##0.00').format(double.parse(transaction.amount) / 1000000)} ${transaction.token}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(AppColors.primary).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildCompactTransactionDetails(context, transaction),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getChainColor(transaction.blockchain),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getChainColor(
                                  transaction.blockchain,
                                ).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          transaction.blockchain.capitalize(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: const Color(AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          timeago.format(transaction.timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(AppColors.onSurfaceVariant),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildCompactDetailItem(
            context,
            'FROM',
            '${transaction.fromAddress?.substring(0, 6) ?? 'N/A'}...${transaction.fromAddress != null && transaction.fromAddress!.length > 4 ? transaction.fromAddress!.substring(transaction.fromAddress!.length - 4) : ''}',
            Icons.account_circle_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildCompactDetailItem(
            context,
            'TO',
            '${transaction.toAddress?.substring(0, 6) ?? 'N/A'}...${transaction.toAddress != null && transaction.toAddress!.length > 4 ? transaction.toAddress!.substring(transaction.toAddress!.length - 4) : ''}',
            Icons.account_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(AppColors.background).withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: const Color(AppColors.primary).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(AppColors.primary)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(AppColors.onSurfaceVariant),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsModal(context, transaction),
    );
  }

  Widget _buildTransactionDetailsModal(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(AppColors.surface),
            const Color(AppColors.background),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(AppColors.onSurfaceVariant).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildTransactionDetails(context, transaction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getChainColor(String blockchain) {
    // Using consistent Blockradar green theme for all chains
    return const Color(AppColors.primary);
  }

  Widget _buildTransactionIcon(TransactionType type) {
    IconData iconData;
    List<Color> gradientColors;

    switch (type) {
      case TransactionType.deposit:
        iconData = Icons.south_west;
        gradientColors = [
          const Color(AppColors.primary),
          const Color(AppColors.accent),
        ];
        break;
      case TransactionType.sweep:
        iconData = Icons.swap_horiz;
        gradientColors = [
          const Color(AppColors.primary),
          const Color(AppColors.accent),
        ];
        break;
      case TransactionType.transfer:
        iconData = Icons.north_east;
        gradientColors = [
          const Color(AppColors.primary),
          const Color(AppColors.accent),
        ];
        break;
      case TransactionType.withdrawal:
        iconData = Icons.north_east;
        gradientColors = [
          const Color(AppColors.primary),
          const Color(AppColors.accent),
        ];
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(iconData, color: Colors.white, size: 28),
    );
  }

  Widget _buildStatusChip(BuildContext context, TransactionStatus status) {
    List<Color> gradientColors;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case TransactionStatus.pending:
        gradientColors = [
          const Color(AppColors.warning).withOpacity(0.2),
          const Color(AppColors.warning).withOpacity(0.1),
        ];
        textColor = const Color(AppColors.warning);
        text = 'PENDING';
        icon = Icons.schedule;
        break;
      case TransactionStatus.confirmed:
        gradientColors = [
          const Color(AppColors.primary).withOpacity(0.2),
          const Color(AppColors.accent).withOpacity(0.1),
        ];
        textColor = const Color(AppColors.primary);
        text = 'CONFIRMED';
        icon = Icons.check_circle;
        break;
      case TransactionStatus.failed:
        gradientColors = [
          const Color(AppColors.error).withOpacity(0.2),
          const Color(AppColors.error).withOpacity(0.1),
        ];
        textColor = const Color(AppColors.error);
        text = 'FAILED';
        icon = Icons.error;
        break;
      case TransactionStatus.cancelled:
        gradientColors = [
          const Color(AppColors.onSurfaceVariant).withOpacity(0.2),
          const Color(AppColors.onSurfaceVariant).withOpacity(0.1),
        ];
        textColor = const Color(AppColors.onSurfaceVariant);
        text = 'CANCELLED';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          'FROM',
          '${transaction.fromAddress?.substring(0, 8) ?? 'N/A'}...${transaction.fromAddress != null && transaction.fromAddress!.length > 6 ? transaction.fromAddress!.substring(transaction.fromAddress!.length - 6) : ''}',
          Icons.account_circle_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDetailRow(
          context,
          'TO',
          '${transaction.toAddress?.substring(0, 8) ?? 'N/A'}...${transaction.toAddress != null && transaction.toAddress!.length > 6 ? transaction.toAddress!.substring(transaction.toAddress!.length - 6) : ''}',
          Icons.account_circle,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDetailRow(
          context,
          'HASH',
          '${transaction.hash.substring(0, 10)}...${transaction.hash.substring(transaction.hash.length - 8)}',
          Icons.tag,
        ),
        if (transaction.gasFee != null && transaction.gasFee! > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            context,
            'GAS FEE',
            '${NumberFormat('#,##0.000000').format(transaction.gasFee)} ETH',
            Icons.local_gas_station,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(AppColors.primary).withOpacity(0.2),
                const Color(AppColors.accent).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 16, color: const Color(AppColors.primary)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(AppColors.onSurfaceVariant),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: const Color(AppColors.onSurfaceVariant).withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No transactions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Transactions will appear here when they occur',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.onSurfaceVariant),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(
                      AppColors.onSurfaceVariant,
                    ).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.onSurfaceVariant,
                          ).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 150,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.onSurfaceVariant,
                          ).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(AppColors.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(recentTransactionsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      final typeMatch =
          _selectedFilter == 'all' || transaction.type.name == _selectedFilter;
      final chainMatch =
          _selectedChain == 'all' ||
          transaction.blockchain.toLowerCase() == _selectedChain;
      return typeMatch && chainMatch;
    }).toList();
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
