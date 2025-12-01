import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/models/session.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

// STATE
class ScheduleManagementState {
  final List<SessionModel> activeSessions;
  final bool isLoading;
  final String? errorMessage;

  ScheduleManagementState({
    required this.activeSessions,
    this.isLoading = false,
    this.errorMessage,
  });

  ScheduleManagementState copyWith({
    List<SessionModel>? activeSessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScheduleManagementState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// CUBIT
class ScheduleManagementCubit extends Cubit<ScheduleManagementState> {
  final SupabaseService? supabaseService;

  ScheduleManagementCubit({this.supabaseService})
    : super(ScheduleManagementState(activeSessions: [], isLoading: false));

  Future<void> loadActiveSessions() async {
    emit(state.copyWith(isLoading: true));

    try {
      await Future.delayed(const Duration(seconds: 1));

      final sessions = [
        SessionModel(
          id: '1',
          seatNumber: 'Seat 13',
          customerName: 'Mas Hambali Ngawi',
          duration: '3 Hours',
          cost: 'Rp 15.000',
          startTime: '10:10',
          endTime: '13:10',
          remainingTime: '1h 18m',
          startDateTime: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 42),
          ),
        ),
        SessionModel(
          id: '2',
          seatNumber: 'Seat 14',
          customerName: 'Mas Hambali Ngawi',
          duration: '3 Hours',
          cost: 'Rp 15.000',
          startTime: '10:10',
          endTime: '13:10',
          remainingTime: '1h 18m',
          startDateTime: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 42),
          ),
        ),
      ];

      emit(state.copyWith(activeSessions: sessions, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> extendSession(String sessionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSessions = state.activeSessions.map((session) {
        if (session.id == sessionId) {
          final newEndTime = _addHours(session.endTime, 1);
          final newRemaining = _calculateRemainingTime(
            session.startDateTime,
            4,
          );

          return session.copyWith(
            duration: '4 Hours',
            endTime: newEndTime,
            remainingTime: newRemaining,
          );
        }
        return session;
      }).toList();

      emit(state.copyWith(activeSessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSessions = state.activeSessions
          .where((s) => s.id != sessionId)
          .toList();

      emit(state.copyWith(activeSessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void updateRemainingTimes() {
    final updated = state.activeSessions.map((session) {
      final newRemaining = _calculateRemainingTime(
        session.startDateTime,
        int.parse(session.duration.split(" ")[0]),
      );

      return session.copyWith(remainingTime: newRemaining);
    }).toList();

    emit(state.copyWith(activeSessions: updated));
  }

  String _addHours(String time, int hours) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]) + hours;
    return '${hour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  String _calculateRemainingTime(DateTime start, int durationHours) {
    final end = start.add(Duration(hours: durationHours));
    final diff = end.difference(DateTime.now());

    if (diff.isNegative) return "0h 0m";

    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}
