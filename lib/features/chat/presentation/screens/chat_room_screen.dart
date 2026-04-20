import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final String sessionId;
  final String topic;

  const ChatRoomScreen({
    super.key,
    required this.sessionId,
    required this.topic,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchMessages(
        widget.sessionId,
        refresh: true,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ChatProvider>();
      if (!provider.isLoading && provider.hasMoreMessages) {
        provider.fetchMessages(widget.sessionId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    // Prevent empty or multiple sends
    if (_textController.text.trim().isEmpty) return;

    final provider = context.read<ChatProvider>();
    if (provider.currentSession?.status == 'CLOSED') return;
    if (provider.isLoading) return; // Prevent double tap

    try {
      await provider.sendMessage(_textController.text.trim(), widget.sessionId);
      _textController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sending message: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      try {
        await context.read<ChatProvider>().sendMessage(
          "",
          widget.sessionId,
          filePath: result.files.single.path,
        );
        _scrollToBottom();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error sending file: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      try {
        await context.read<ChatProvider>().sendMessage(
          "",
          widget.sessionId,
          filePath: result.files.single.path,
        );
        _scrollToBottom();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error sending image: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    // Wait for list to update then scroll
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Reverse list, 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider
        .messages; // Newest is at index 0, ListView(reverse:true) puts index 0 at bottom

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // AppColors.backgroundGrey
      appBar: AppBar(
        backgroundColor: const Color(0xFF55789A), // AppColors.appBarBlue
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(
                'assets/Images/logoSk.png',
              ), // Or user avatar
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'end') {
                provider
                    .endChat(widget.sessionId)
                    .then((_) {
                      Navigator.pop(context);
                    })
                    .catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error ending chat: $e")),
                      );
                    });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'end', child: Text("End Chat")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final currentUser = context.read<AuthProvider>().userId;
                      final senderId = msg.sender.id.toString().trim();
                      final currentIdStr = currentUser?.toString().trim() ?? "";

                      print(
                        "DEBUG_SENDER: msg.sender.id = $senderId | currentUser = $currentIdStr | isMe = ${senderId == currentIdStr}",
                      );

                      final isMe = senderId == currentIdStr;

                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),
          if (provider.currentSession?.status == 'CLOSED')
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              width: double.infinity,
              child: const Text(
                "This chat has been closed.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            _buildInputArea(provider),
        ],
      ),
    );
  }

  Widget _buildFilePreview(ChatMessageModel msg, bool isMe) {
    final fileUrl = msg.fileUrl;
    final fileType = msg.fileType?.toLowerCase() ?? '';
    final isImage = fileType.contains('image') || fileType.contains('jpg') || fileType.contains('jpeg') || fileType.contains('png') || fileType.contains('webp');

    if (fileUrl != null && isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fileUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 200,
              height: 140,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stack) {
            return _buildFileChip(msg, isMe);
          },
        ),
      );
    }

    return _buildFileChip(msg, isMe);
  }

  Widget _buildFileChip(ChatMessageModel msg, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            color: isMe ? Colors.white : Colors.black54,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            msg.fileType ?? "File",
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF4A749B)
                : Colors.white, // AppColors.primaryBlue
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important for wrap content
            children: [
              if (!isMe) ...[
                Text(
                  msg.sender.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (msg.fileUrl != null) ...[
                _buildFilePreview(msg, isMe),
                const SizedBox(height: 4),
              ],

              if (msg.text.isNotEmpty)
                Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),

              const SizedBox(height: 4),
              Text(
                // Simple time format, preferably use intl
                msg.createdAt != null
                    ? "${msg.createdAt!.hour}:${msg.createdAt!.minute.toString().padLeft(2, '0')}"
                    : "Now",
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: provider.isLoading ? null : _pickFile,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: provider.isLoading ? null : _pickImage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !provider.isLoading,
                        decoration: const InputDecoration(
                          hintText: "Type here...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: provider.isLoading
                    ? Colors.grey
                    : const Color(0xFF5C88C4),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
