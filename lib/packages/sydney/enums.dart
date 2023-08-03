enum ConversationStyle {
  creative('h3imaginative,clgalileo,gencontentv3'),
  balanced('galileo'),
  precise('h3precise,clgalileo');

  final String value;

  const ConversationStyle(this.value);
}

enum ComposeTone {
  professional('professional'),
  casual('casual'),
  enthusiastic('enthusiastic'),
  informational('informational'),
  funny('funny');

  final String value;

  const ComposeTone(this.value);
}

enum ComposeFormat {
  paragraph('paragraph'),
  email('email'),
  blogPost('blog post'),
  ideas('ideas');

  final String value;

  const ComposeFormat(this.value);
}

enum ComposeLength {
  short('short'),
  medium('medium'),
  long('long');

  final String value;

  const ComposeLength(this.value);
}

enum MessageType {
  chat,
  internalSearchQuery,
  internalSearchResult,
  disengaged,
  internalLoaderMessage,
  renderCardRequest,
  adsQuery,
  semanticSerp,
  generateContentQuery,
  searchQuery
}

enum ResultValue {
  success,
  throttled
}