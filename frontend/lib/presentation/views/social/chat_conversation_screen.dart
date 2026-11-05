import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/social/social_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/responsive_container.dart';
import '../../components/community_rules_sheet.dart';

class ChatConversationScreen extends StatefulWidget {
  final String peerUserId;
  final String peerName;
  final String peerHandle;

  const ChatConversationScreen({
    super.key,
    required this.peerUserId,
    required this.peerName,
    required this.peerHandle,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatMessagesEvent(widget.peerUserId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
          SendChatMessageEvent(peerUserId: widget.peerUserId, content: text),
        );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.peerHandle,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.block_outlined),
            tooltip: 'Bloquear usuário e fechar conversa',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.block, color: AppColors.warningOrange, size: 24),
                      SizedBox(width: 8),
                      Expanded(child: Text('Bloquear Usuário?')),
                    ],
                  ),
                  content: Text(
                    'Deseja bloquear ${widget.peerName}? Ao bloquear, ele não poderá enviar mensagens diretas para você. Você poderá desbloqueá-lo a qualquer momento em Perfil > Contatos Bloqueados.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<SocialBloc>().add(BlockUserEvent(targetUserId: widget.peerUserId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.peerName} foi bloqueado.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Bloquear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ResponsiveContainer.medium(
        child: Column(
          children: [
            // Security Notice
          // Security & Rules Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Conversa livre e segura: conversem sobre o que quiserem, sempre dentro das regras da comunidade.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => CommunityRulesSheet.show(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Regras',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded && state.messages.isNotEmpty) {
                  final last = state.messages.last;
                  if (!last.isOutgoing) {
                    SemanticsHelper.announce('Nova mensagem de ${widget.peerName}: ${last.content}');
                  }
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 48, color: AppColors.warningOrange),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline_rounded, size: 42, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Nenhuma mensagem trocada ainda.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Envie um "Olá!" para conversar sobre o que quiser, trocar ideias ou combinar encontros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final msg = state.messages[i];
                      final isMe = msg.isOutgoing;

                      return Semantics(
                        label: '${isMe ? "Você disse" : "${widget.peerName} disse"}: ${msg.content}',
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primaryBlue : AppColors.surfaceLight,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              border: isMe ? null : Border.all(color: AppColors.borderLight, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : AppColors.textPrimary,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white70 : AppColors.textHint,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        msg.status == 'READ' ? Icons.done_all : Icons.done,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Composer Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(top: BorderSide(color: AppColors.borderLight, width: 1.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      textField: true,
                      label: 'Digite sua mensagem para ${widget.peerName}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma mensagem...',
                            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccessibleButton(
                    label: 'Enviar',
                    icon: Icons.send_rounded,
                    minHeight: 48,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
