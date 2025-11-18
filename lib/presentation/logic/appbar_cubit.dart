import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class AppbarState {
  final int selectedIndex;
  const AppbarState(this.selectedIndex);
}

class AppbarInitial extends AppbarState {
  const AppbarInitial() : super(-1);
}

class AppbarNavigated extends AppbarState {
  const AppbarNavigated(super.selectedIndex);
}

// Cubit
class AppbarCubit extends Cubit<AppbarState> {
  AppbarCubit() : super(const AppbarInitial());

  void navigateToIndex(int index) {
    emit(AppbarNavigated(index));
  }

  int get currentIndex => state.selectedIndex;

  // Method untuk cek apakah sedang di halaman appbar
  bool get isOnAppbarPage => state.selectedIndex >= 0;
}
