import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/moderation_action.dart';
import '../../../domain/repositories/admin_repository.dart';

// Events
abstract class AdminAuditEvent extends Equatable {
  const AdminAuditEvent();
  @override
  List<Object?> get props => [];
}

class LoadAuditLogsEvent extends AdminAuditEvent {
  final String? moderatorId;
  final String? actionType;
  final String? targetType;

  const LoadAuditLogsEvent({
    this.moderatorId,
    this.actionType,
    this.targetType,
  });

  @override
  List<Object?> get props => [moderatorId, actionType, targetType];
}

// States
abstract class AdminAuditState extends Equatable {
  const AdminAuditState();
  @override
  List<Object?> get props => [];
}

class AdminAuditInitial extends AdminAuditState {}

class AdminAuditLoading extends AdminAuditState {}

class AdminAuditLoaded extends AdminAuditState {
  final List<ModerationAction> logs;

  const AdminAuditLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class AdminAuditError extends AdminAuditState {
  final String message;
  const AdminAuditError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminAuditBloc extends Bloc<AdminAuditEvent, AdminAuditState> {
  final AdminRepository _repository;

  AdminAuditBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminAuditInitial()) {
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
  }

  Future<void> _onLoadAuditLogs(
    LoadAuditLogsEvent event,
    Emitter<AdminAuditState> emit,
  ) async {
    emit(AdminAuditLoading());
    try {
      final logs = await _repository.listAuditLogs(
        moderatorId: event.moderatorId,
        actionType: event.actionType,
        targetType: event.targetType,
      );
      emit(AdminAuditLoaded(logs));
    } catch (e) {
      emit(AdminAuditError('Erro ao carregar trilha de auditoria: $e'));
    }
  }
}
