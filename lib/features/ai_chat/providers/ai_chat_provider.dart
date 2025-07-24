import 'package:blockradar_pulse/features/transactions/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../models/chat_message.dart';
import '../../transactions/models/transaction_model.dart';

final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, AsyncValue<List<ChatMessage>>>(
      (ref) => AIChatNotifier(ref),
    );

class AIChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref _ref;
  final List<ChatMessage> _messages = [];

  AIChatNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    state = AsyncValue.data(List.from(_messages));

    await Future.delayed(const Duration(milliseconds: 800));

    final aiResponse = await _generateAIResponse(content);
    final aiMessage = ChatMessage.ai(
      aiResponse.content,
      metadata: aiResponse.data,
    );
    _messages.add(aiMessage);
    state = AsyncValue.data(List.from(_messages));
  }

  Future<AIResponse> _generateAIResponse(String userInput) async {
    final input = userInput.toLowerCase();

    if (input.contains('transaction') && input.contains('recent')) {
      return _analyzeRecentTransactions();
    } else if (input.contains('spending') || input.contains('pattern')) {
      return _analyzeSpendingPattern();
    } else if (input.contains('gas') && input.contains('fee')) {
      return _analyzeGasFees();
    } else if (input.contains('explain') || input.contains('what')) {
      return _explainConcept(input);
    } else if (input.contains('hello') || input.contains('hi')) {
      return _greetUser();
    } else if (input.contains('help')) {
      return _showHelp();
    } else {
      return _generateGeneralResponse(input);
    }
  }

  AIResponse _analyzeRecentTransactions() {
    final transactions = _ref.read(recentTransactionsProvider).value ?? [];

    if (transactions.isEmpty) {
      return AIResponse(
        content:
            "I don't see any recent transactions in your account. Once you start making transactions, I'll be able to provide detailed analysis and insights about your blockchain activity.",
        type: MessageType.transactionAnalysis,
      );
    }

    final totalTransactions = transactions.length;
    final uniqueChains = transactions.map((t) => t.blockchain).toSet().length;
    final totalValue = transactions.fold<double>(
      0,
      (sum, t) => sum + (double.tryParse(t.amount) ?? 0),
    );

    final mostUsedChain = _getMostUsedChain(transactions);
    final avgGasFee = _calculateAverageGasFee(transactions);

    return AIResponse(
      content:
          "📊 **Recent Transaction Analysis**\n\n"
          "• **Total Transactions**: $totalTransactions\n"
          "• **Blockchains Used**: $uniqueChains\n"
          "• **Most Active Chain**: ${mostUsedChain.capitalize()}\n"
          "• **Average Gas Fee**: ${avgGasFee.toStringAsFixed(6)} ETH\n"
          "• **Total Volume**: ${(totalValue / 1000000).toStringAsFixed(2)} tokens\n\n"
          "Your activity shows ${_getActivityLevel(totalTransactions)} usage. "
          "${_getChainRecommendation(mostUsedChain)}",
      type: MessageType.transactionAnalysis,
      data: {
        'totalTransactions': totalTransactions,
        'uniqueChains': uniqueChains,
        'mostUsedChain': mostUsedChain,
        'avgGasFee': avgGasFee,
        'totalValue': totalValue,
      },
    );
  }

  AIResponse _analyzeSpendingPattern() {
    final transactions = _ref.read(recentTransactionsProvider).value ?? [];

    if (transactions.isEmpty) {
      return AIResponse(
        content:
            "I need transaction data to analyze your spending patterns. Start making some transactions and I'll provide insights about your crypto spending habits!",
      );
    }

    final typeDistribution = <String, int>{};
    final chainDistribution = <String, double>{};

    for (final transaction in transactions) {
      typeDistribution[transaction.type.name] =
          (typeDistribution[transaction.type.name] ?? 0) + 1;
      final amount = double.tryParse(transaction.amount) ?? 0;
      chainDistribution[transaction.blockchain] =
          (chainDistribution[transaction.blockchain] ?? 0) + amount;
    }

    final mostCommonType = typeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final highestValueChain = chainDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return AIResponse(
      content:
          "💰 **Spending Pattern Analysis**\n\n"
          "• **Most Common Activity**: ${mostCommonType.capitalize()} (${typeDistribution[mostCommonType]} transactions)\n"
          "• **Highest Value Chain**: ${highestValueChain.capitalize()}\n"
          "• **Transaction Frequency**: ${_getFrequencyInsight(transactions.length)}\n"
          "• **Risk Level**: ${_getRiskLevel(typeDistribution)}\n\n"
          "${_getSpendingAdvice(mostCommonType, highestValueChain)}",
      type: MessageType.transactionAnalysis,
    );
  }

  AIResponse _analyzeGasFees() {
    final transactions = _ref.read(recentTransactionsProvider).value ?? [];

    if (transactions.isEmpty) {
      return AIResponse(
        content:
            "I don't have gas fee data to analyze yet. Once you make some transactions, I can help you optimize your gas spending!",
      );
    }

    final gasFees = transactions
        .map((t) => double.tryParse(t.gasFee.toString() ?? '0') ?? 0)
        .toList();
    final avgGas =
        gasFees.fold<double>(0, (sum, fee) => sum + fee) / gasFees.length;
    final maxGas = gasFees.isEmpty
        ? 0.0
        : gasFees.reduce((double a, double b) => a > b ? a : b);
    final minGas = gasFees.isEmpty
        ? 0.0
        : gasFees.reduce((double a, double b) => a < b ? a : b);

    return AIResponse(
      content:
          "⛽ **Gas Fee Analysis**\n\n"
          "• **Average Gas Fee**: ${avgGas.toStringAsFixed(6)} ETH\n"
          "• **Highest Fee Paid**: ${maxGas.toStringAsFixed(6)} ETH\n"
          "• **Lowest Fee Paid**: ${minGas.toStringAsFixed(6)} ETH\n"
          "• **Total Gas Spent**: ${gasFees.fold<double>(0, (sum, fee) => sum + fee).toStringAsFixed(6)} ETH\n\n"
          "💡 **Optimization Tips**:\n"
          "• Consider using Layer 2 solutions for lower fees\n"
          "• Monitor gas prices and transact during off-peak hours\n"
          "• Batch multiple operations when possible",
      type: MessageType.suggestion,
    );
  }

  AIResponse _explainConcept(String input) {
    if (input.contains('transaction')) {
      return AIResponse(
        content:
            "🔗 **Blockchain Transactions Explained**\n\n"
            "A blockchain transaction is a digital record of value transfer between addresses. Here's what happens:\n\n"
            "1. **Initiation**: You sign a transaction with your private key\n"
            "2. **Broadcasting**: The transaction is sent to the network\n"
            "3. **Validation**: Miners/validators verify the transaction\n"
            "4. **Confirmation**: The transaction is added to a block\n"
            "5. **Finality**: The block is confirmed by the network\n\n"
            "Each transaction includes gas fees to incentivize network participants.",
      );
    } else if (input.contains('gas')) {
      return AIResponse(
        content:
            "⛽ **Gas Fees Explained**\n\n"
            "Gas is the fee required to execute transactions on blockchain networks:\n\n"
            "• **Purpose**: Compensates miners/validators for processing\n"
            "• **Calculation**: Gas Price × Gas Used\n"
            "• **Factors**: Network congestion, transaction complexity\n"
            "• **Optimization**: Use Layer 2s, time transactions wisely\n\n"
            "Higher gas = faster processing, but costs more!",
      );
    } else {
      return AIResponse(
        content:
            "I'd be happy to explain blockchain concepts! Try asking about:\n\n"
            "• Transactions and how they work\n"
            "• Gas fees and optimization\n"
            "• Different blockchain networks\n"
            "• DeFi protocols and strategies\n"
            "• Security best practices\n\n"
            "What would you like to learn about?",
      );
    }
  }

  AIResponse _greetUser() {
    final greetings = [
      'Welcome to Ask Pulse! 🚀\n\n'
          'I\'m your personal blockchain analyst. I can help you:\n\n'
          '• **Analyze transactions** - Get insights on any transaction\n'
          '• **Spot patterns** - Discover trends in your activity\n'
          '• **Optimize costs** - Find ways to reduce gas fees\n'
          '• **Understand data** - Explain complex blockchain concepts\n\n'
          'What would you like to explore in your transaction data?',
      "Hi there! Ready to dive into your blockchain data? I can analyze transactions, explain concepts, or provide insights about your crypto journey.",
      "Welcome back! I'm excited to help you make sense of your blockchain activities. What can I assist you with today?",
    ];

    return AIResponse(content: greetings[Random().nextInt(greetings.length)]);
  }

  AIResponse _showHelp() {
    return AIResponse(
      content:
          "🤖 **How I Can Help You**\n\n"
          "**Transaction Analysis**\n"
          "• Analyze recent transactions\n"
          "• Identify spending patterns\n"
          "• Track gas fee trends\n\n"
          "**Education**\n"
          "• Explain blockchain concepts\n"
          "• Provide optimization tips\n"
          "• Share security best practices\n\n"
          "**Insights**\n"
          "• Portfolio recommendations\n"
          "• Risk assessment\n"
          "• Market trends (coming soon)\n\n"
          "Just ask me anything about your blockchain data!",
      type: MessageType.suggestion,
    );
  }

  AIResponse _generateGeneralResponse(String input) {
    final responses = [
      "That's an interesting question! While I specialize in blockchain and transaction analysis, I'm always learning. Could you rephrase your question or ask about your crypto activities?",
      "I'm focused on helping you with blockchain-related queries. Try asking about your transactions, gas fees, or any crypto concepts you'd like to understand better!",
      "I'd love to help! My expertise is in blockchain analysis and crypto insights. What would you like to know about your transaction history or blockchain in general?",
    ];

    return AIResponse(content: responses[Random().nextInt(responses.length)]);
  }

  String _getMostUsedChain(List<TransactionModel> transactions) {
    final chainCounts = <String, int>{};
    for (final transaction in transactions) {
      chainCounts[transaction.blockchain] =
          (chainCounts[transaction.blockchain] ?? 0) + 1;
    }
    if (chainCounts.isEmpty) return 'ethereum';
    return chainCounts.entries
        .reduce(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.value > b.value ? a : b,
        )
        .key;
  }

  double _calculateAverageGasFee(List<TransactionModel> transactions) {
    final gasFees = transactions
        .map((t) => double.tryParse(t.gasFee.toString() ?? '0') ?? 0)
        .where((fee) => fee > 0)
        .toList();

    if (gasFees.isEmpty) return 0.0;
    return gasFees.fold<double>(0, (sum, fee) => sum + fee) / gasFees.length;
  }

  String _getActivityLevel(int transactionCount) {
    if (transactionCount > 50) return 'very high';
    if (transactionCount > 20) return 'high';
    if (transactionCount > 10) return 'moderate';
    if (transactionCount > 5) return 'low';
    return 'minimal';
  }

  String _getChainRecommendation(String mostUsedChain) {
    switch (mostUsedChain.toLowerCase()) {
      case 'ethereum':
        return 'Consider using Layer 2 solutions like Arbitrum or Polygon for lower fees.';
      case 'polygon':
        return 'Great choice for cost-effective transactions!';
      case 'bsc':
        return 'BSC offers good balance of speed and cost.';
      case 'arbitrum':
        return 'Excellent choice for Ethereum compatibility with lower fees.';
      default:
        return 'Diversifying across multiple chains can optimize your costs.';
    }
  }

  String _getFrequencyInsight(int count) {
    if (count > 30) return 'Very Active (30+ transactions)';
    if (count > 15) return 'Active (15+ transactions)';
    if (count > 5) return 'Moderate (5+ transactions)';
    return 'Getting Started';
  }

  String _getRiskLevel(Map<String, int> typeDistribution) {
    final swapCount = typeDistribution['swap'] ?? 0;
    final totalCount = typeDistribution.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    if (swapCount > totalCount * 0.7) return 'High (Frequent Trading)';
    if (swapCount > totalCount * 0.4) return 'Medium (Regular Trading)';
    return 'Low (Conservative)';
  }

  String _getSpendingAdvice(String mostCommonType, String highestValueChain) {
    String advice = "💡 **Personalized Advice**:\n";

    if (mostCommonType == 'swap') {
      advice +=
          "• You're an active trader! Consider DCA strategies to reduce timing risk\n";
      advice += "• Monitor slippage and use limit orders when possible\n";
    } else if (mostCommonType == 'transfer') {
      advice +=
          "• You frequently move funds. Consider batching transfers to save on gas\n";
    }

    advice += "• Your main chain is ${highestValueChain.capitalize()}. ";
    advice += _getChainRecommendation(highestValueChain);

    return advice;
  }

  void clearChat() {
    _messages.clear();
    state = const AsyncValue.data([]);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
