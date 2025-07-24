import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../api_status/models/api_status_model.dart';
import '../../api_status/services/api_status_service.dart';
import '../../api_status/providers/api_status_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isApiKeyVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final storageService = ref.read(secureStorageServiceProvider);
    final apiKey = await storageService.getApiKey();
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
  }

  Future<void> _saveApiKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showSnackBar('Please enter an API key', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      await storageService.storeApiKey(_apiKeyController.text.trim());
      _showSnackBar('API key saved successfully');
    } catch (e) {
      _showSnackBar('Failed to save API key: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearApiKey() async {
    setState(() => _isLoading = true);

    try {
      final storageService = ref.read(secureStorageServiceProvider);
      await storageService.deleteApiKey();
      _apiKeyController.clear();
      _showSnackBar('API key cleared successfully');
    } catch (e) {
      _showSnackBar('Failed to clear API key: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(AppColors.error)
            : const Color(AppColors.success),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiStatusAsync = ref.watch(apiStatusProvider);
    final webhookStatusAsync = ref.watch(webhookStatusProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(apiStatusProvider);
            ref.invalidate(webhookStatusProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                _buildApiKeySection(context),
                const SizedBox(height: AppSpacing.xl),
                _buildNotificationSection(context),
                const SizedBox(height: AppSpacing.xl),
                apiStatusAsync.when(
                  data: (status) => _buildApiStatusSection(context, status),
                  loading: () => _buildStatusLoading('API Status'),
                  error: (error, stack) =>
                      _buildErrorCard(context, 'API Status', error),
                ),
                const SizedBox(height: AppSpacing.xl),
                webhookStatusAsync.when(
                  data: (status) => _buildWebhookSection(context, status),
                  loading: () => _buildStatusLoading('Webhook Status'),
                  error: (error, stack) =>
                      _buildErrorCard(context, 'Webhook Status', error),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildAboutSection(context),
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
        Text('Settings', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Manage your API configuration and monitor status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.key_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'API Configuration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Enter your Blockradar API key to access live data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _apiKeyController,
              obscureText: !_isApiKeyVisible,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your Blockradar API key',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isApiKeyVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _isApiKeyVisible = !_isApiKeyVisible);
                      },
                    ),
                    if (_apiKeyController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _apiKeyController.text),
                          );
                          _showSnackBar('API key copied to clipboard');
                        },
                      ),
                  ],
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiKey,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Save API Key'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _clearApiKey,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationTile(
              context,
              'Transaction Alerts',
              'Get notified about new transactions',
              true,
              (value) {},
            ),
            _buildNotificationTile(
              context,
              'Sweep Failures',
              'Alert when sweep operations fail',
              true,
              (value) {},
            ),
            _buildNotificationTile(
              context,
              'API Status Changes',
              'Monitor API health status',
              false,
              (value) {},
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () async {
                final notificationService = ref.read(
                  notificationServiceProvider,
                );
                await notificationService.showLocalNotification(
                  title: 'Test Notification',
                  body: 'This is a test notification from Blockradar Pulse',
                );
                _showSnackBar('Test notification sent');
              },
              child: const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(AppColors.onSurfaceVariant),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(AppColors.primary),
      ),
    );
  }

  Widget _buildApiStatusSection(BuildContext context, ApiStatusModel status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.api_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'API Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _buildStatusIndicator(status.status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ...status.services.map(
              (service) => _buildServiceStatusTile(
                context,
                service.name,
                service.status,
                service.responseTime,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebhookSection(
    BuildContext context,
    List<WebhookStatus> webhooks,
  ) {
    final webhook = webhooks.isNotEmpty ? webhooks.first : null;

    if (webhook == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.webhook_outlined,
                    size: 20,
                    color: Color(AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Webhook Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No webhook data available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.webhook_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Webhook Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _buildStatusIndicator(webhook.status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow(
              context,
              'Total Events',
              webhook.totalEvents.toString(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              context,
              'Failed Events',
              webhook.failedEvents.toString(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              context,
              'Success Rate',
              '${webhook.totalEvents > 0 ? ((webhook.totalEvents - webhook.failedEvents) / webhook.totalEvents * 100).toStringAsFixed(1) : '0.0'}%',
            ),
            if (webhook.recentEvents.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Recent Events',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...webhook.recentEvents
                  .take(3)
                  .map((event) => _buildWebhookEventTile(context, event)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusTile(
    BuildContext context,
    String name,
    String status,
    int responseTime,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          _buildStatusIndicator(status),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '${responseTime}ms',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookEventTile(BuildContext context, WebhookEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(AppColors.background),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: const Color(AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            event.success ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: event.success
                ? const Color(AppColors.success)
                : const Color(AppColors.error),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              event.eventType,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    if (status == 'healthy') {
      color = const Color(AppColors.success);
    } else if (status == 'degraded') {
      color = const Color(AppColors.warning);
    } else if (status == 'down') {
      color = const Color(AppColors.error);
    } else {
      color = const Color(AppColors.onSurfaceVariant);
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(AppColors.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outlined,
                  size: 20,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('About', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(context, 'App Version', '1.0.0'),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(context, 'Build', '1'),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(context, 'API Version', 'v1'),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Blockradar Pulse is a developer tool for monitoring Blockradar wallet infrastructure.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLoading(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String title, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(AppColors.error),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Failed to load: ${error.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
