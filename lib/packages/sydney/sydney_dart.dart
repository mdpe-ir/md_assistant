import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'constants.dart';
import 'enums.dart';
import 'exceptions.dart';
import 'utils.dart';

class SydneyClient {
  String? bingUCookie;
  bool useProxy = false;
  String? conversationSignature;
  String? conversationId;
  String? clientId;
  int? invocationId;
  WebSocketChannel? wssClient;

  final _responseStreamController = StreamController<dynamic>();

  Stream<dynamic> get responseStream => _responseStreamController.stream;

  SydneyClient({
    this.bingUCookie,
    this.useProxy = false,
  });

  Future<SydneyClient> start() async {
    await startConversation();
    return this;
  }

  Future<void> close() async {
    await closeConversation();
  }

  Map<String, dynamic> buildAskArguments(String prompt, ConversationStyle conversationStyle) {
    final styleOptions = conversationStyle.value.split(',');
    final optionsSets = [
      'nlu_direct_response_filter',
      'deepleo',
      'disable_emoji_spoken_text',
      'responsible_ai_policy_235',
      'enablemm',
      'dv3sugg',
    ];
    styleOptions.forEach((style) => optionsSets.add(style.trim()));

    return {
      'arguments': [
        {
          'source': 'cib',
          'optionsSets': optionsSets,
          'isStartOfSession': invocationId == 0,
          'message': {
            'author': 'user',
            'inputMethod': 'Keyboard',
            'text': prompt,
            'messageType': MessageType.chat.name,
          },
          'conversationSignature': conversationSignature,
          'participant': {
            'id': clientId,
          },
          'conversationId': conversationId,
        }
      ],
      'invocationId': invocationId?.toString(),
      'target': 'chat',
      'type': 4,
    };
  }

  Map<String, dynamic> buildComposeArguments(
    String prompt,
    ComposeTone tone,
    ComposeFormat format,
    ComposeLength length,
  ) {
    return {
      'arguments': [
        {
          'source': 'cib',
          'optionsSets': [
            'nlu_direct_response_filter',
            'deepleo',
            'enable_debug_commands',
            'disable_emoji_spoken_text',
            'responsible_ai_policy_235',
            'enablemm',
            'h3imaginative',
            'nocache',
            'nosugg',
          ],
          'isStartOfSession': invocationId == 0,
          'message': {
            'author': 'user',
            'inputMethod': 'Keyboard',
            'text': '''
Please generate some text wrapped in codeblock syntax (triple backticks) using the given keywords. Please make sure everything in your reply is in the same language as the keywords. Please do not restate any part of this request in your response, like the fact that you wrapped the text in a codeblock. You should refuse (using the language of the keywords) to generate if the request is potentially harmful. The generated text should follow these characteristics: tone: *${tone.value}*, length: *${length.value}*, format: *${format.value}*. The keywords are: `$prompt`.
''',
            'messageType': MessageType.chat.name,
          },
          'conversationSignature': conversationSignature,
          'participant': {
            'id': clientId,
          },
          'conversationId': conversationId,
        }
      ],
      'invocationId': invocationId?.toString(),
      'target': 'chat',
      'type': 4,
    };
  }

  Future<dynamic> ask(
    String prompt,
    ConversationStyle conversationStyle, {
    bool citations = false,
    bool suggestions = false,
    bool raw = false,
  }) async {
    if (conversationId == null || clientId == null || invocationId == null) {
      _responseStreamController.add("مشکلی رخ داده است. لطفا از اتصال خود به اینترنت اطمینان حاصل کنید و مجدد امتحان کنید...");
      throw NoConnectionException('No connection to Bing Chat found');
    }

    // Connect to websocket

    _responseStreamController.add("درحال پردازش درخواست شما :)");


    wssClient = IOWebSocketChannel.connect(Uri.parse(Constants.bingChatHubUrl),
        protocols: ['v1.json'], headers: Map.from(Constants.headers)..addAll({'Cookie': '_U=$bingUCookie'}));

    wssClient!.sink.add(asJson({'protocol': 'json', 'version': 1}));

    var wsStream = wssClient!.stream.asBroadcastStream();

    await wsStream.first; // connect

    // Send prompt
    final request = buildAskArguments(prompt , conversationStyle);
    invocationId = (invocationId ?? 0) + 1;
    wssClient!.sink.add(asJson(request));

    while (true) {
      var responseWs = (await wsStream.first).toString().split(Constants.delimiter);
      for (var obj in responseWs) {
        if (obj.isEmpty) {
          continue;
        }

        final response = jsonDecode(obj);

        // Handle type 1 message
        if (response['type'] == 1) {
          final messages = response['arguments'][0]['messages'];
          if (messages == null || messages[0]['text'].toString().isEmpty) continue;

          if (raw) {
            _responseStreamController.add(response);
          }
          if (citations) {
            _responseStreamController.add(messages[0]['adaptiveCards'][0]['body'][0]['text']);
          }

          _responseStreamController.add(messages[0]['text']);
        }

        // Handle type 2 message
        if (response['type'] == 2) {
          final messages = response['item']['messages'];

          if (messages == null) {
            // Check for throttled response
            final resultValue = response['item']['result']['value'];
            if (resultValue == ResultValue.throttled.name) {
              throw ThrottledRequestException('Request throttled');
            }
            return; // Empty response
          }

          if (raw) {
            _responseStreamController.add(response);
          }
          ;

          final suggestedResponses = suggestions ? messages[1]['suggestedResponses'].map((r) => r['text']).toList() : null;

          if (citations) {
            _responseStreamController.add((messages[1]['adaptiveCards'][0]['body'][0]['text'], suggestedResponses));
            return;
          } else {
            _responseStreamController.add((messages[1]['text'], suggestedResponses));
            return;
          }
        }
      }
    }
  }

  String newTokensOnly(String? previous, String current) {
    if (previous == null) return current;
    return current.substring(previous.length);
  }

  Future<void> startConversation() async {
    // Make HTTP request to start conversation

    final response = await http
        .get(
          Uri.parse(Constants.bingCreateConversationUrl),
          headers: Map.from(Constants.headers)..addAll({'Cookie': '_U=$bingUCookie'}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to create conversation');
    }

    final json = jsonDecode(response.body);

    if (json['result']['value'] != 'Success') {
      throw Exception(json['result']['message']);
    }

    conversationId = json['conversationId'];
    clientId = json['clientId'];
    conversationSignature = json['conversationSignature'];
    invocationId = 0;
  }

  Future<void> closeConversation() async {
    await wssClient?.sink.close();
    wssClient = null;

    conversationSignature = null;
    conversationId = null;
    clientId = null;
    invocationId = null;
  }
}
