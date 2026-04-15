import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wallet_models.dart';

class LlmSummarizerService {
  LlmSummarizerService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  Future<List<String>> summarizeTransactions(
    List<NormalizedTransaction> transactions,
  ) async {
    final uri = Uri.https('api.openai.com', '/v1/chat/completions');
    final promptPayload = transactions.map((t) => t.toJson()).toList();

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content':
                'You convert blockchain transactions into short plain-English summaries. Avoid jargon and be concise.',
          },
          {
            'role': 'user',
            'content':
                'Convert these blockchain transactions into summaries. Return JSON: {"summaries":["..."]}. Transactions: ${jsonEncode(promptPayload)}',
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LLM summarization failed with status ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty)
      throw Exception('No LLM response choices.');

    final content =
        ((choices.first as Map<String, dynamic>)['message']
                as Map<String, dynamic>)['content']
            as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final summariesRaw = parsed['summaries'] as List<dynamic>?;
    if (summariesRaw == null || summariesRaw.isEmpty) {
      throw Exception('Missing summaries from LLM output.');
    }

    return summariesRaw.map((e) => e.toString()).toList();
  }

  Future<String?> summarizeInsights(
    List<NormalizedTransaction> transactions,
  ) async {
    if (transactions.isEmpty) return null;
    final uri = Uri.https('api.openai.com', '/v1/chat/completions');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 0.3,
        'messages': [
          {
            'role': 'system',
            'content':
                'Write one short insight sentence about a wallet activity pattern in plain English.',
          },
          {
            'role': 'user',
            'content':
                'Transactions: ${jsonEncode(transactions.map((e) => e.toJson()).toList())}',
          },
        ],
      }),
    );

    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;
    return ((choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>)['content']
        ?.toString();
  }
}
