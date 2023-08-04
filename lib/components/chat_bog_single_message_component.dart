import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:md_assistant/packages/auto_direction/auto_direction.dart';

class ChatBotSingleMessageComponent extends StatelessWidget {
  const ChatBotSingleMessageComponent({super.key, required this.stream});

  final Stream stream;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.data.runtimeType == String) {
            return textWidget(snapshot.data.toString(), isDark);
          }
          if (snapshot.data.runtimeType.toString() == (String, List<dynamic>).toString()) {
            String result = snapshot.data.$1;
            return textWidget(result, isDark);
          }
          return Text("");
        });
  }

  Widget textWidget(String data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AutoDirection(
            text: data,
            child: MarkdownWidget(
              data: data,
              selectable: true,
              config: isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig,
            ),
          ),
        ),
      ),
    );
  }
}
