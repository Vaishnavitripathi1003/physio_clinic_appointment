import 'package:flutter/material.dart';

// --- 1. Mock Data Structure ---
class Message {
  final String text;
  final bool isMe; // True if the message is from the current user
  final DateTime time;

  Message({required this.text, required this.isMe, required this.time});
}

// --- 2. Chat Screen Widget ---
class ChatScreen extends StatefulWidget {
  final String contactName;

  const ChatScreen({Key? key, this.contactName = 'John Doe'}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock list of messages
  List<Message> _messages = [
    Message(
      text: 'Hey, are we still meeting tomorrow?',
      isMe: false,
      time: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    Message(
      text: 'Yes, around 10 AM. How does that sound?',
      isMe: true,
      time: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    Message(
      text: 'Perfect! See you then.',
      isMe: false,
      time: DateTime.now().subtract(Duration(minutes: 1)),
    ),
  ];

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim().isEmpty) return; // Prevent sending empty messages

    setState(() {
      _messages.add(
        Message(
          text: text,
          isMe: true, // New messages are from the current user
          time: DateTime.now(),
        ),
      );
    });

    // Scroll to the bottom to view the new message
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar (Header) ---
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName, style: TextStyle(fontSize: 18)),
            Text('Online', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),

      // --- Body (Message List) ---
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          const Divider(height: 1.0),

          // --- Composer (Input Field) ---
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Row(
        children: <Widget>[
          // Text Input Field
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
              ),
            ),
          ),
          // Send Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.blue, // Primary color for the send button
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Message Bubble Widget ---
class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Determine alignment and color based on who sent the message
    final alignment =
    message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isMe ? Colors.lightGreen : Colors.grey[300];
    final margin = message.isMe
        ? const EdgeInsets.only(left: 80.0)
        : const EdgeInsets.only(right: 80.0);
    final textColor = message.isMe ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: <Widget>[
          Container(
            margin: margin,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: message.isMe ? Radius.circular(15) : Radius.zero,
                bottomRight: message.isMe ? Radius.zero : Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 8.0, left: 8.0),
            child: Text(
              '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10.0, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}