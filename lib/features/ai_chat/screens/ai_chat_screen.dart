import 'package:blockradar_pulse/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart' hide AppColors;
import '../models/chat_message.dart';
import '../providers/ai_chat_provider.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isTyping = true;
    });

    await ref.read(aiChatProvider.notifier).sendMessage(message);

    setState(() {
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(AppColors.background),
              const Color(AppColors.surface).withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildChatArea(chatState)),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
          ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(AppColors.surface).withOpacity(0.8),
              const Color(AppColors.surface).withOpacity(0.4),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(AppColors.primary).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(AppColors.primary), Color(AppColors.accent)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
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
                      'Ask Pulse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'AI Transaction Intelligence',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.accent),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(AppColors.success),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.success).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(AsyncValue<List<ChatMessage>> chatState) {
    return FadeTransition(
      opacity: _fadeController,
      child: chatState.when(
        data: (messages) {
          if (messages.isEmpty) {
            return _buildIntelligentWelcomeScreen();
          }
          return _buildIntelligentMessagesList(messages);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildIntelligentWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildAnomalyDetectionCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildSmartSummaryCards(),
          const SizedBox(height: AppSpacing.lg),
          _buildIntelligentQuestions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppColors.surface).withOpacity(0.8),
            const Color(AppColors.primary).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(AppColors.primary).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(AppColors.primary), Color(AppColors.accent)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(AppColors.primary), Color(AppColors.accent)],
            ).createShader(bounds),
            child: Text(
              'Ask Pulse',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'AI Transaction Intelligence',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(AppColors.accent),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Transform your blockchain data into actionable insights with intelligent analysis',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(AppColors.onSurfaceVariant),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyDetectionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.warning).withOpacity(0.1),
            const Color(AppColors.error).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(AppColors.warning).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(AppColors.warning).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(AppColors.warning),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Live Anomaly Detection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAnomalyItem(
            '🔥',
            'Wallet #1324 received 3x usual daily volume',
            'High activity detected',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAnomalyItem(
            '⚠️',
            'Sweep failed twice in the last hour',
            'Retry suggested',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAnomalyItem(
            '🕵️',
            'High gas usage on Polygon',
            'Consider switching to Base',
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyItem(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(AppColors.surface).withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(AppColors.primary),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '\$12,430',
                'Stablecoin deposits',
                'across 3 chains this week',
                Icons.account_balance_wallet,
                const Color(AppColors.success),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                '75%',
                'USDT on Tron',
                'of total volume',
                Icons.pie_chart,
                const Color(AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSummaryCard(
          '3 wallets',
          'Show unusual activity',
          'Tap to review suspicious transactions',
          Icons.security,
          const Color(AppColors.warning),
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Icon(
                      Icons.trending_up,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIntelligentQuestions() {
    final intelligentQuestions = [
      {
        'category': 'Suspicious Activity',
        'icon': Icons.security,
        'color': const Color(AppColors.error),
        'questions': [
          'Show me all suspicious transactions this week',
          'Flag large deposits over \$5K',
          'Are any wallets inactive in the last 7 days?',
        ],
      },
      {
        'category': 'Volume Analysis',
        'icon': Icons.analytics,
        'color': const Color(AppColors.primary),
        'questions': [
          'Which wallet is receiving the most stablecoin deposits?',
          'What\'s the average deposit size today?',
          'How much was swept to our master wallet yesterday?',
        ],
      },
      {
        'category': 'Network Optimization',
        'icon': Icons.speed,
        'color': const Color(AppColors.accent),
        'questions': [
          'Which chain has the highest fees right now?',
          'Show me gas fee trends across networks',
          'Recommend the cheapest route for transfers',
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ask Intelligent Questions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...intelligentQuestions.map((category) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildQuestionCategory(
              category['category'] as String,
              category['icon'] as IconData,
              category['color'] as Color,
              category['questions'] as List<String>,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuestionCategory(
    String category,
    IconData icon,
    Color color,
    List<String> questions,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...questions.map((question) {
            return GestureDetector(
              onTap: () {
                _messageController.text = question;
                _sendMessage();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(AppColors.surface).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.send,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildIntelligentMessagesList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isTyping) {
          return _buildIntelligentTypingIndicator();
        }
        return _buildIntelligentMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildIntelligentMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(AppColors.primary), Color(AppColors.accent)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUser
                      ? [
                          const Color(AppColors.primary),
                          const Color(AppColors.accent),
                        ]
                      : [
                          const Color(AppColors.surface).withOpacity(0.8),
                          const Color(AppColors.primary).withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : const Color(AppColors.primary).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(AppColors.primary).withOpacity(0.2)
                        : const Color(AppColors.surface).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.accent).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Ask Pulse AI',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(AppColors.accent),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!isUser) const SizedBox(height: AppSpacing.sm),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : const Color(AppColors.onSurfaceVariant),
                        ),
                      ),
                      if (!isUser)
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: const Color(AppColors.success),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Verified',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(AppColors.success),
                                fontWeight: FontWeight.w600,
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
          if (isUser) ...[
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(AppColors.surface).withOpacity(0.8),
                    const Color(AppColors.primary).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(AppColors.primary).withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(AppColors.primary),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntelligentTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(AppColors.primary), Color(AppColors.accent)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(AppColors.surface).withOpacity(0.8),
                  const Color(AppColors.primary).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: const Color(AppColors.primary).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Analyzing...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.accent),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(AppColors.primary).withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
          ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(AppColors.surface).withOpacity(0.8),
              const Color(AppColors.surface).withOpacity(0.4),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: const Color(AppColors.primary).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(AppColors.background).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask about suspicious activity, volume analysis, or network optimization...',
                    hintStyle: TextStyle(
                      color: const Color(
                        AppColors.onSurfaceVariant,
                      ).withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(AppColors.primary), Color(AppColors.accent)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isTyping ? null : _sendMessage,
                icon: Icon(
                  _isTyping ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(AppColors.primary)),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            'Something went wrong',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.onSurfaceVariant),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
