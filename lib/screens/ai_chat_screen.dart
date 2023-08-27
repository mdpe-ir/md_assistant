import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:md_assistant/components/chat_bog_single_message_component.dart';
import 'package:md_assistant/packages/auto_direction/auto_direction.dart';
import 'package:md_assistant/packages/sydney/enums.dart';
import 'package:md_assistant/packages/sydney/sydney_dart.dart';
import 'package:md_assistant/providers/secure_storage_provider.dart';
import 'package:md_assistant/utils/constant.dart' as utilConstant;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  bool isLoading = false;

  ConversationStyle conversationStyle = ConversationStyle.balanced;

  SydneyClient? client;

  String text = "";
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initClient();
  }

  Future initClient() async {
    client = SydneyClient(bingUCookie: await SecureStorageProvider.getString(key: utilConstant.Constant.bingChatSecretKey) ?? "");
    setState(() {});
  }

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
          child: client != null
              ? ChatBotSingleMessageComponent(stream: client!.responseStream.stream, textEditingController: textEditingController)
              : Container()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AutoDirection(
          text: textEditingController.value.text,
          child: TextFormField(
            controller: textEditingController,
            maxLength: 4000,
            maxLines: null,
            onChanged: (value) {
              setState(() => text = value);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              hintText: 'پیامی بنویسید...',
              prefixIcon: textEditingController.value.text.length > 3
                  ? IconButton(onPressed: () => textEditingController.clear(), icon: const Icon(Icons.clear))
                  : null,
              suffixIcon: isLoading
                  ? SizedBox(width: 20, height: 20, child: SpinKitFadingCircle(size: 20, color: Theme.of(context).highlightColor))
                  : IconButton(onPressed: () => sendMessage(), icon: const Icon(Icons.send)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    setState(() => isLoading = true);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await client?.startConversation();
      await client?.ask("${textEditingController.value.text}\npleas do not introduce your self", conversationStyle, suggestions: true);
      await client?.closeConversation();
      setState(() => isLoading = false);
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }
}
