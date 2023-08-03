import 'dart:convert';

import 'package:md_assistant/packages/sydney/constants.dart';


String asJson(Map<String, dynamic> message) {
  return jsonEncode(message) + Constants.delimiter;
}
