enum MessageType { text, image, video, audio }

MessageType getMessageType(String? type) {
  switch (type) {
    case 'image':
      return MessageType.image;
    case 'video':
      return MessageType.video;
    case 'audio':
      return MessageType.audio;
    default:
      return MessageType.text;
  }
}