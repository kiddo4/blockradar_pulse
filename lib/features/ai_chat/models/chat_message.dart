class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  factory ChatMessage.ai(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
      metadata: metadata,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      type: MessageType.values[json['type'] ?? 0],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp, type: $type)';
  }
}

enum MessageType { text, transactionAnalysis, chartData, suggestion, error }

class AIResponse {
  final String content;
  final MessageType type;
  final Map<String, dynamic>? data;
  final List<String>? suggestions;

  AIResponse({
    required this.content,
    this.type = MessageType.text,
    this.data,
    this.suggestions,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      content: json['content'],
      type: MessageType.values[json['type'] ?? 0],
      data: json['data'],
      suggestions: json['suggestions']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type.index,
      'data': data,
      'suggestions': suggestions,
    };
  }
}
