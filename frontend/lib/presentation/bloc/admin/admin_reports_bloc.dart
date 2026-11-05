import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/base/equatable.dart';
import '../../../domain/entities/content_report.dart';
import '../../../domain/repositories/admin_repository.dart';

// Events
abstract class AdminReportsEvent extends Equatable {
  const AdminReportsEvent();
  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends AdminReportsEvent {
  final String? status;
  final String? targetType;

  const LoadReportsEvent({this.status, this.targetType});

  @override
  List<Object?> get props => [status, targetType];
}

class ResolveReportEvent extends AdminReportsEvent {
  final String reportId;
  final String action;
  final String resolutionNotes;

  const ResolveReportEvent({
    required this.reportId,
    required this.action,
    required this.resolutionNotes,
  });

  @override
  List<Object?> get props => [reportId, action, resolutionNotes];
}

// States
abstract class AdminReportsState extends Equatable {
  const AdminReportsState();
  @override
  List<Object?> get props => [];
}

class AdminReportsInitial extends AdminReportsState {}

class AdminReportsLoading extends AdminReportsState {}

class AdminReportsLoaded extends AdminReportsState {
  final List<ContentReport> reports;
  final String? selectedStatus;

  const AdminReportsLoaded({required this.reports, this.selectedStatus});

  @override
  List<Object?> get props => [reports, selectedStatus];
}

class AdminReportsError extends AdminReportsState {
  final String message;
  const AdminReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminReportsActionSuccess extends AdminReportsState {
  final String message;
  const AdminReportsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  final AdminRepository _repository;

  AdminReportsBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminReportsInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ResolveReportEvent>(_onResolveReport);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(AdminReportsLoading());
    try {
      final reports = await _repository.listReports(
        status: event.status,
        targetType: event.targetType,
      );
      emit(AdminReportsLoaded(reports: reports, selectedStatus: event.status));
    } catch (e) {
      emit(AdminReportsError('Erro ao carregar fila de denúncias: $e'));
    }
  }

  Future<void> _onResolveReport(
    ResolveReportEvent event,
    Emitter<AdminReportsState> emit,
  ) async {
    try {
      await _repository.resolveReport(
        reportId: event.reportId,
        action: event.action,
        resolutionNotes: event.resolutionNotes,
      );
      emit(const AdminReportsActionSuccess('Denúncia processada com sucesso.'));
      add(const LoadReportsEvent());
    } catch (e) {
      emit(AdminReportsError('Erro ao processar denúncia: $e'));
    }
  }
}
