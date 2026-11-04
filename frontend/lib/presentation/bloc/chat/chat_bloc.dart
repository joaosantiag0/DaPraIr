import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatMessagesEvent extends ChatEvent {
  final String peerUserId;
  const LoadChatMessagesEvent(this.peerUserId);
  @override
  List<Object?> get props => [peerUserId];
}

class SendChatMessageEvent extends ChatEvent {
  final String peerUserId;
  final String content;
  const SendChatMessageEvent({required this.peerUserId, required this.content});
  @override
  List<Object?> get props => [peerUserId, content];
}

class NewMessageReceivedEvent extends ChatEvent {
  final ChatMessage message;
  const NewMessageReceivedEvent(this.message);
  @override
  List<Object?> get props => [message];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String peerUserId;

  const ChatLoaded({required this.messages, required this.peerUserId});

  @override
  List<Object?> get props => [messages, peerUserId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  StreamSubscription<ChatMessage>? _subscription;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    _subscription = repository.messageStream.listen((msg) {
      add(NewMessageReceivedEvent(msg));
    });

    on<LoadChatMessagesEvent>(_onLoadMessages);
    on<SendChatMessageEvent>(_onSendMessage);
    on<NewMessageReceivedEvent>(_onNewMessage);
  }

  Future<void> _onLoadMessages(LoadChatMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await repository.getMessages(event.peerUserId);
      emit(ChatLoaded(messages: messages, peerUserId: event.peerUserId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendChatMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final msg = await repository.sendMessage(event.peerUserId, event.content);
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        if (!current.messages.any((m) => m.id == msg.id)) {
          emit(ChatLoaded(
            messages: [...current.messages, msg],
            peerUserId: event.peerUserId,
          ));
        }
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewMessage(NewMessageReceivedEvent event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      if (event.message.senderId == current.peerUserId || event.message.recipientId == current.peerUserId) {
        if (!current.messages.any((m) => m.id == event.message.id)) {
          emit(ChatLoaded(
            messages: [...current.messages, event.message],
            peerUserId: current.peerUserId,
          ));
        }
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
