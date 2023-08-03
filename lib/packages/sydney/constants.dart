class Constants {
  static const Map<String, String> headers = {
    "Accept": "application/json",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Content-Type": "application/json",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188",
  };

  static const String bingCreateConversationUrl = "https://www.bing.com/turing/conversation/create";
  static const String bingChatHubUrl = "wss://sydney.bing.com/sydney/ChatHub";

  static const String delimiter = "\x1e"; // Record separator character.
}
