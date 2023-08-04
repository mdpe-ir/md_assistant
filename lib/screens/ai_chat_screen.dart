import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:md_assistant/components/chat_bog_single_message_component.dart';
import 'package:md_assistant/packages/auto_direction/auto_direction.dart';
import 'package:md_assistant/packages/sydney/enums.dart';
import 'package:md_assistant/packages/sydney/sydney_dart.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  bool isLoading = false;

  ConversationStyle conversationStyle = ConversationStyle.balanced;

  SydneyClient client = SydneyClient(bingUCookie: "");

  String text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("چت بات"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                items: ["خلاقانه", "متعادل", "دقیق"],
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "انتخاب سبک مکالمه",
                    hintText: "",
                  ),
                ),
                onChanged: (value) {
                  if (value == "خلاقانه") {
                    setState(() => conversationStyle = ConversationStyle.creative);
                  }

                  if (value == "متعادل") {
                    setState(() => conversationStyle = ConversationStyle.balanced);
                  }

                  if (value == "دقیق") {
                    setState(() => conversationStyle = ConversationStyle.precise);
                  }
                },
                selectedItem: "متعادل",
              ),
            ),
          )),
      body: Theme(
          data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(fontFamily: "JetbrainsMono", fontFamilyFallback: ["Vazirmatn"])),
          child: ChatBotSingleMessageComponent(stream: client.responseStream)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AutoDirection(
          text: text,
          child: TextFormField(
            // Add PlaceHolder
            maxLength: 4000,
            maxLines: null,
            onChanged: (value) {
              setState(() => text = value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'پیامی بنویسید...',
              suffixIcon: IconButton(
                onPressed: () {
                  sendMessage();
                },
                icon: const Icon(Icons.send),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    await client.startConversation();
    await client.ask(text, conversationStyle, suggestions: true);
    await client.closeConversation();
  }
}
