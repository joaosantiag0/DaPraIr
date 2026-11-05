import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/unified_content.dart';
import '../../../domain/repositories/admin_repository.dart';

// Events
abstract class AdminContentEvent extends Equatable {
  const AdminContentEvent();
  @override
  List<Object?> get props => [];
}

class LoadContentEvent extends AdminContentEvent {
  final String? type;
  final String? status;
  final String? query;

  const LoadContentEvent({this.type, this.status, this.query});

  @override
  List<Object?> get props => [type, status, query];
}

class HideContentEvent extends AdminContentEvent {
  final String type;
  final String id;
  final String reason;

  const HideContentEvent({
    required this.type,
    required this.id,
    required this.reason,
  });

  @override
  List<Object?> get props => [type, id, reason];
}

class RestoreContentEvent extends AdminContentEvent {
  final String type;
  final String id;
  final String reason;

  const RestoreContentEvent({
    required this.type,
    required this.id,
    required this.reason,
  });

  @override
  List<Object?> get props => [type, id, reason];
}

class DeleteContentEvent extends AdminContentEvent {
  final String type;
  final String id;
  final String reason;

  const DeleteContentEvent({
    required this.type,
    required this.id,
    required this.reason,
  });

  @override
  List<Object?> get props => [type, id, reason];
}

// States
abstract class AdminContentState extends Equatable {
  const AdminContentState();
  @override
  List<Object?> get props => [];
}

class AdminContentInitial extends AdminContentState {}

class AdminContentLoading extends AdminContentState {}

class AdminContentLoaded extends AdminContentState {
  final List<UnifiedContent> items;
  final String? currentType;
  final String? currentStatus;
  final String? currentQuery;

  const AdminContentLoaded({
    required this.items,
    this.currentType,
    this.currentStatus,
    this.currentQuery,
  });

  @override
  List<Object?> get props => [items, currentType, currentStatus, currentQuery];
}

class AdminContentError extends AdminContentState {
  final String message;
  const AdminContentError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminContentActionSuccess extends AdminContentState {
  final String message;
  const AdminContentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminContentBloc extends Bloc<AdminContentEvent, AdminContentState> {
  final AdminRepository _repository;

  AdminContentBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminContentInitial()) {
    on<LoadContentEvent>(_onLoadContent);
    on<HideContentEvent>(_onHideContent);
    on<RestoreContentEvent>(_onRestoreContent);
    on<DeleteContentEvent>(_onDeleteContent);
  }

  Future<void> _onLoadContent(
    LoadContentEvent event,
    Emitter<AdminContentState> emit,
  ) async {
    emit(AdminContentLoading());
    try {
      final items = await _repository.listContent(
        type: event.type,
        status: event.status,
        query: event.query,
      );
      emit(AdminContentLoaded(
        items: items,
        currentType: event.type,
        currentStatus: event.status,
        currentQuery: event.query,
      ));
    } catch (e) {
      emit(AdminContentError('Erro ao carregar conteúdos: $e'));
    }
  }

  Future<void> _onHideContent(
    HideContentEvent event,
    Emitter<AdminContentState> emit,
  ) async {
    try {
      await _repository.hideContent(
        type: event.type,
        id: event.id,
        reason: event.reason,
      );
      emit(const AdminContentActionSuccess('Conteúdo ocultado com sucesso.'));
      add(const LoadContentEvent());
    } catch (e) {
      emit(AdminContentError('Erro ao ocultar conteúdo: $e'));
    }
  }

  Future<void> _onRestoreContent(
    RestoreContentEvent event,
    Emitter<AdminContentState> emit,
  ) async {
    try {
      await _repository.restoreContent(
        type: event.type,
        id: event.id,
        reason: event.reason,
      );
      emit(const AdminContentActionSuccess('Conteúdo restaurado com sucesso.'));
      add(const LoadContentEvent());
    } catch (e) {
      emit(AdminContentError('Erro ao restaurar conteúdo: $e'));
    }
  }

  Future<void> _onDeleteContent(
    DeleteContentEvent event,
    Emitter<AdminContentState> emit,
  ) async {
    try {
      await _repository.deleteContent(
        type: event.type,
        id: event.id,
        reason: event.reason,
      );
      emit(const AdminContentActionSuccess('Conteúdo excluído com sucesso.'));
      add(const LoadContentEvent());
    } catch (e) {
      emit(AdminContentError('Erro ao excluir conteúdo: $e'));
    }
  }
}
