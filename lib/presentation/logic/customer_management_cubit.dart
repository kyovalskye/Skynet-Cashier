import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/models/session.dart';

// State
class CustomerManagementState {
  final List<SessionModel> activeSessions;
  final bool isLoading;
  final String? errorMessage;

  CustomerManagementState({
    required this.activeSessions,
    this.isLoading = false,
    this.errorMessage,
  });

  CustomerManagementState copyWith({
    List<SessionModel>? activeSessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerManagementState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Cubit
class CustomerManagementCubit extends Cubit<CustomerManagementState> {
  CustomerManagementCubit()
    : super(CustomerManagementState(activeSessions: [], isLoading: false));

  // Load active sessions (dummy data untuk contoh)
  Future<void> loadActiveSessions() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
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
      ];

      emit(state.copyWith(activeSessions: sessions, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Extend session time
  Future<void> extendSession(String sessionId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSessions = state.activeSessions.map((session) {
        if (session.id == sessionId) {
          // Add 1 hour to the session
          final newEndTime = _addHours(session.endTime, 1);
          final newRemainingTime = _calculateRemainingTime(
            session.startDateTime,
            4,
          ); // 3 + 1 hour

          return session.copyWith(
            duration: '4 Hours',
            endTime: newEndTime,
            remainingTime: newRemainingTime,
          );
        }
        return session;
      }).toList();

      emit(state.copyWith(activeSessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // End session
  Future<void> endSession(String sessionId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSessions = state.activeSessions
          .where((session) => session.id != sessionId)
          .toList();

      emit(state.copyWith(activeSessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // Update remaining time (call this periodically)
  void updateRemainingTimes() {
    final updatedSessions = state.activeSessions.map((session) {
      final newRemainingTime = _calculateRemainingTime(
        session.startDateTime,
        int.parse(session.duration.split(' ')[0]),
      );
      return session.copyWith(remainingTime: newRemainingTime);
    }).toList();

    emit(state.copyWith(activeSessions: updatedSessions));
  }

  // Helper methods
  String _addHours(String time, int hours) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]) + hours;
    final minute = parts[1];
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  String _calculateRemainingTime(DateTime startTime, int durationHours) {
    final endTime = startTime.add(Duration(hours: durationHours));
    final remaining = endTime.difference(DateTime.now());

    if (remaining.isNegative) {
      return '0h 0m';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }
}
