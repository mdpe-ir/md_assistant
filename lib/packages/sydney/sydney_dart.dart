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
  ConversationStyle conversationStyle;
  String? conversationSignature;
  String? conversationId;
  String? clientId;
  int? invocationId;
  WebSocketChannel? wssClient;

  SydneyClient({
    this.conversationStyle = ConversationStyle.balanced,
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

  Map<String, dynamic> buildAskArguments(String prompt) {
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
    String prompt, {
    bool citations = false,
    bool suggestions = false,
    bool raw = false,
  }) async {
    if (conversationId == null || clientId == null || invocationId == null) {
      throw NoConnectionException('No connection to Bing Chat found');
    }

    // Connect to websocket

    wssClient = IOWebSocketChannel.connect(Uri.parse(Constants.bingChatHubUrl),
        protocols: ['v1.json'], headers: Map.from(Constants.headers)..addAll({'Cookie': '_U=$bingUCookie'}));

    wssClient!.sink.add(asJson({'protocol': 'json', 'version': 1}));

    var wsStream = wssClient!.stream.asBroadcastStream();

    await wsStream.first; // connect

    // Send prompt
    final request = buildAskArguments(prompt);
    invocationId = (invocationId ?? 0) + 1;
    wssClient!.sink.add(asJson(request));

    while (true) {
      var responseWs = (await wsStream.first).toString().split(Constants.delimiter);
      for (var obj in responseWs) {
        print(obj.runtimeType);

        if (obj.isEmpty) {
          continue;
        }

        final response = jsonDecode(obj);
        print(response);

        // Handle type 1 message
        if (response['type'] == 1) {
          final messages = response['arguments'][0]['messages'];
          if (messages == null || messages[0]['text'].toString().isEmpty) continue;

          if (raw) return response;
          if (citations) return messages[0]['adaptiveCards'][0]['body'][0]['text'];

          // return messages[0]['text'];
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

          if (raw) return response;

          final suggestedResponses = suggestions ? messages[1]['suggestedResponses'].map((r) => r['text']).toList() : null;

          if (citations) {
            return (messages[1]['adaptiveCards'][0]['body'][0]['text'], suggestedResponses);
          } else {
            return (messages[1]['text'], suggestedResponses);
          }
        }
      }
    }
  }

  // Future<Stream> askStream(
  //   String prompt, {
  //   bool citations = false,
  //   bool suggestions = false,
  //   bool raw = false,
  // }) async {
  //
  //   wssClient = IOWebSocketChannel.connect(Uri.parse(Constants.bingChatHubUrl),
  //       protocols: ['v1.json'], headers: Map.from(Constants.headers)..addAll({'Cookie': '_U=$bingUCookie'}));
  //
  //   wssClient!.sink.add(asJson({'protocol': 'json', 'version': 1}));
  //
  //   var wsStream = wssClient!.stream.asBroadcastStream();
  //
  //   await wsStream.first; // connect
  //
  //   // Send prompt
  //   final request = buildAskArguments(prompt);
  //   invocationId = (invocationId ?? 0) + 1;
  //   wssClient!.sink.add(asJson(request));
  //
  //   String? previousResponse;
  //
  //   // await for (var response in wsStream) {
  //   //
  //   //   var responseWs = response.split(Constants.delimiter);
  //   //   final json = jsonDecode(responseWs[0]);
  //   //
  //   //   print(json);
  //   //
  //   //   // Handle type 1
  //   //   if (json['type'] == 1) {
  //   //     final messages = json['arguments'][0]['messages'];
  //   //     final responseText = messages[0]['text'];
  //   //
  //   //     if (raw) {
  //   //       yield json;
  //   //     } else {
  //   //       yield newTokensOnly(previousResponse, responseText);
  //   //       previousResponse = responseText;
  //   //     }
  //   //   }
  //   //
  //   //   // Handle type 2
  //   //   else if (json['type'] == 2) {
  //   //     final messages = json['item']['messages'];
  //   //     final responseText = messages[1]['text'];
  //   //
  //   //     if (raw) {
  //   //       yield json;
  //   //     } else {
  //   //       yield newTokensOnly(previousResponse, responseText);
  //   //       previousResponse = responseText;
  //   //     }
  //   //
  //   //     break; // Exit on type 2
  //   //   }
  //   // }
  // }

  // Utility method
  String newTokensOnly(String? previous, String current) {
    if (previous == null) return current;
    return current.substring(previous.length);
  }

  Future<void> startConversation() async {
    // Make HTTP request to start conversation

    final response = await http.get(
      Uri.parse(Constants.bingCreateConversationUrl),
      headers: Map.from(Constants.headers)..addAll({'Cookie': '_U=$bingUCookie'}),
    );

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
