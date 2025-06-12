import 'package:logger/logger.dart';

class ApiLoggerService {
  static final ApiLoggerService _instance = ApiLoggerService._internal();
  factory ApiLoggerService() => _instance;
  ApiLoggerService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Track API usage statistics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _rateLimitedRequests = 0;
  DateTime? _lastRequestTime;
  final List<ApiRequestLog> _requestHistory = [];

  // Getters for statistics
  int get totalRequests => _totalRequests;
  int get successfulRequests => _successfulRequests;
  int get failedRequests => _failedRequests;
  int get rateLimitedRequests => _rateLimitedRequests;
  DateTime? get lastRequestTime => _lastRequestTime;
  List<ApiRequestLog> get requestHistory => _requestHistory;

  void logApiRequest({
    required String endpoint,
    required String query,
    required Map<String, String> parameters,
    String? filter,
  }) {
    _totalRequests++;
    _lastRequestTime = DateTime.now();

    final log = ApiRequestLog(
      timestamp: _lastRequestTime!,
      endpoint: endpoint,
      query: query,
      parameters: parameters,
      filter: filter,
      status: ApiRequestStatus.pending,
    );

    _requestHistory.add(log);

    // Keep only last 100 requests to prevent memory issues
    if (_requestHistory.length > 100) {
      _requestHistory.removeAt(0);
    }

    _logger.i('''
🌐 API REQUEST
📍 Endpoint: $endpoint
🔍 Query: "$query"
🏷️  Filter: ${filter ?? 'All'}
📊 Parameters: ${parameters.entries.map((e) => '${e.key}=${e.value}').join(', ')}
⏰ Time: ${_formatTime(_lastRequestTime!)}
📈 Total Requests: $_totalRequests
''');
  }

  void logApiSuccess({
    required String endpoint,
    required int resultCount,
    required int statusCode,
    required Duration responseTime,
    Map<String, String>? responseHeaders,
  }) {
    _successfulRequests++;

    // Update the last request log
    if (_requestHistory.isNotEmpty) {
      _requestHistory.last.status = ApiRequestStatus.success;
      _requestHistory.last.responseTime = responseTime;
      _requestHistory.last.resultCount = resultCount;
      _requestHistory.last.statusCode = statusCode;
    }

    _logger.i('''
✅ API SUCCESS
📍 Endpoint: $endpoint
📊 Status Code: $statusCode
🎯 Results: $resultCount items
⚡ Response Time: ${responseTime.inMilliseconds}ms
📈 Success Rate: ${((_successfulRequests / _totalRequests) * 100).toStringAsFixed(1)}%
${_checkRateLimit(responseHeaders)}
''');
  }

  void logApiError({
    required String endpoint,
    required int statusCode,
    required String error,
    required Duration responseTime,
    Map<String, String>? responseHeaders,
    StackTrace? stackTrace,
  }) {
    _failedRequests++;

    // Check if it's a rate limit error
    if (statusCode == 429) {
      _rateLimitedRequests++;
    }

    // Update the last request log
    if (_requestHistory.isNotEmpty) {
      _requestHistory.last.status =
          statusCode == 429
              ? ApiRequestStatus.rateLimited
              : ApiRequestStatus.failed;
      _requestHistory.last.responseTime = responseTime;
      _requestHistory.last.statusCode = statusCode;
      _requestHistory.last.error = error;
    }

    final errorLevel = statusCode == 429 ? Level.warning : Level.error;

    _logger.log(
      errorLevel,
      '''
${statusCode == 429 ? '⚠️ RATE LIMITED' : '❌ API ERROR'}
📍 Endpoint: $endpoint
📊 Status Code: $statusCode
💥 Error: $error
⚡ Response Time: ${responseTime.inMilliseconds}ms
📈 Failure Rate: ${((_failedRequests / _totalRequests) * 100).toStringAsFixed(1)}%
🚫 Rate Limited: $_rateLimitedRequests times
${_checkRateLimit(responseHeaders)}
''',
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _checkRateLimit(Map<String, String>? headers) {
    if (headers == null) return '';

    final remaining = headers['x-ratelimit-remaining'];
    final limit = headers['x-ratelimit-limit'];
    final reset = headers['x-ratelimit-reset'];

    if (remaining != null && limit != null) {
      final remainingInt = int.tryParse(remaining) ?? 0;
      final limitInt = int.tryParse(limit) ?? 0;
      final usedPercent = ((limitInt - remainingInt) / limitInt * 100)
          .toStringAsFixed(1);

      String resetInfo = '';
      if (reset != null) {
        final resetTime = DateTime.fromMillisecondsSinceEpoch(
          (int.tryParse(reset) ?? 0) * 1000,
        );
        resetInfo = '\n🔄 Resets at: ${_formatTime(resetTime)}';
      }

      return '''
🔢 Rate Limit: $remaining/$limit remaining ($usedPercent% used)$resetInfo''';
    }

    return '';
  }

  void logApiStatistics() {
    final successRate =
        _totalRequests > 0
            ? ((_successfulRequests / _totalRequests) * 100).toStringAsFixed(1)
            : '0.0';

    _logger.i('''
📊 API USAGE STATISTICS
═══════════════════════
📈 Total Requests: $_totalRequests
✅ Successful: $_successfulRequests ($successRate%)
❌ Failed: $_failedRequests
🚫 Rate Limited: $_rateLimitedRequests
⏰ Last Request: ${_lastRequestTime != null ? _formatTime(_lastRequestTime!) : 'Never'}
''');
  }

  void clearHistory() {
    _requestHistory.clear();
    _logger.i('🧹 API request history cleared');
  }

  void resetStatistics() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _rateLimitedRequests = 0;
    _lastRequestTime = null;
    _requestHistory.clear();
    _logger.i('🔄 API statistics reset');
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

// Data classes for request logging
class ApiRequestLog {
  final DateTime timestamp;
  final String endpoint;
  final String query;
  final Map<String, String> parameters;
  final String? filter;
  ApiRequestStatus status;
  Duration? responseTime;
  int? resultCount;
  int? statusCode;
  String? error;

  ApiRequestLog({
    required this.timestamp,
    required this.endpoint,
    required this.query,
    required this.parameters,
    this.filter,
    required this.status,
    this.responseTime,
    this.resultCount,
    this.statusCode,
    this.error,
  });
}

enum ApiRequestStatus { pending, success, failed, rateLimited }
