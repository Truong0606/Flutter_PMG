import 'package:flutter/material.dart';
import '../../../ai_chat/data/ai_chat_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/storage_service.dart';

class GuestAiChatBox extends StatefulWidget {
  const GuestAiChatBox({super.key});

  @override
  State<GuestAiChatBox> createState() => _GuestAiChatBoxState();
}

class _GuestAiChatBoxState extends State<GuestAiChatBox> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final AiChatService _service;
  late final StorageService _storage;

  final List<_Msg> _messages = [
    _Msg(role: _Role.assistant, text: 'Hi! I\'m your assistant. Ask me anything.'),
  ];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    _service = AiChatService(ApiClient(_storage));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Removed local history load/save to keep chat stateless per user request.

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    // Optimistically append and set sending state
    if (!mounted) return;
    setState(() {
      _messages.add(_Msg(role: _Role.user, text: text));
      _messages.add(const _Msg(role: _Role.assistant, text: '...'));
      _sending = true;
      _controller.clear();
    });

    // Ensure _sending is always reset even if any await above fails
    try {
      // Call backend to get reply
      final reply = await _service.sendGuestMessage(text);
      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] =
            _Msg(role: _Role.assistant, text: reply.isEmpty ? 'No response.' : reply);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[_messages.length - 1] =
            _Msg(role: _Role.assistant, text: 'Error: ${e.toString()}');
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        // Avoid exceptions if the list isn't attached yet
        try {
          await Future.delayed(const Duration(milliseconds: 50));
          if (_scrollController.hasClients) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final width = maxWidth < 420 ? maxWidth - 24 : 360.0;

    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        width: width,
        height: 420,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF3498DB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Assistant (Guest)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isUser = m.role == _Role.user;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: BoxConstraints(maxWidth: width - 48),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFFF6B35) : const Color(0xFFF0F3F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Role { user, assistant }

class _Msg {
  final _Role role;
  final String text;
  const _Msg({required this.role, required this.text});
}
