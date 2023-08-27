import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:md_assistant/packages/auto_direction/auto_direction.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChatBotSingleMessageComponent extends StatefulWidget {
  const ChatBotSingleMessageComponent(
      {super.key, this.stream, this.fullScreenMode = false, this.result = "", this.textEditingController});

  final TextEditingController? textEditingController;
  final bool fullScreenMode;
  final Stream? stream;
  final String result;

  @override
  State<ChatBotSingleMessageComponent> createState() => _ChatBotSingleMessageComponentState();
}

class _ChatBotSingleMessageComponentState extends State<ChatBotSingleMessageComponent> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.fullScreenMode
          ? SafeArea(child: textWidget(context, widget.result, isDark))
          : StreamBuilder(
              stream: widget.stream,
              builder: (context, snapshot) {
                if (snapshot.data.runtimeType == String) {
                  return textWidget(
                    context,
                    snapshot.data.toString(),
                    isDark,
                    allowShowFullScreen: snapshot.connectionState == ConnectionState.done,
                  );
                }
                if (snapshot.data.runtimeType.toString() == (String, List<dynamic>).toString()) {
                  String result = snapshot.data.$1;
                  List<dynamic> list = snapshot.data.$2;
                  log("list is $list");
                  return textWidget(
                    context,
                    result,
                    isDark,
                    allowShowFullScreen: snapshot.connectionState == ConnectionState.done,
                    suggestions: list,
                  );
                }
                return const Text("");
              }),
    );
  }

  Widget textWidget(
    BuildContext context,
    String data,
    bool isDark, {
    allowShowFullScreen = false,
    List<dynamic> suggestions = const [],
  }) {
    return Column(
      children: [
        AnimatedOpacity(
          opacity: suggestions.isEmpty ? 0 : 1,
          duration: Duration(milliseconds: 800),
          child: _SuggestedSection(
            suggestions: suggestions,
            textEditingController: widget.textEditingController,
          ),
        ),
        Expanded(
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.fullScreenMode
                    ? Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back)),
                        ],
                      )
                    : Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                if (allowShowFullScreen) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatBotSingleMessageComponent(
                                        result: data,
                                        fullScreenMode: true,
                                        key: UniqueKey(),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("تا پایان پردازش متن این قابلیت در دسترس نیست"),
                                  ));
                                }
                              },
                              icon: Icon(MdiIcons.arrowExpand)),
                        ],
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AutoDirection(
                      text: data,
                      child: MarkdownWidget(
                        data: data,
                        selectable: true,
                        config: isDark
                            ? MarkdownConfig.darkConfig.copy(configs: [
                                LinkConfig(
                                  onTap: (value) {
                                    launchUrlString(value);
                                  },
                                )
                              ])
                            : MarkdownConfig.defaultConfig.copy(configs: [
                                LinkConfig(
                                  onTap: (value) {
                                    launchUrlString(value);
                                  },
                                )
                              ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestedSection extends StatelessWidget {
  const _SuggestedSection({super.key, required this.suggestions, this.textEditingController});

  final List<dynamic> suggestions;
  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: suggestions.isNotEmpty ? 50 : 0,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              String item = suggestions[index];
              return suggestionsCard(item);
            },
          ),
        ),
        SizedBox(height: suggestions.isNotEmpty ? 8 : 0),
      ],
    );
  }

  Widget suggestionsCard(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // zoom in cursor
      child: GestureDetector(
        onTap: () {
          textEditingController?.text = text;
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoDirection(text: text, child: Text(text)),
          ),
        ),
      ),
    );
  }
}
