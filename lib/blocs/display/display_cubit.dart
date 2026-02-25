import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/constants.dart';
import 'display_state.dart';

/// Manages which content panel is currently displayed on the TV screen.
/// Auto-cycles between panels on a timer.
class DisplayCubit extends Cubit<DisplayState> {
  Timer? _cycleTimer;

  DisplayCubit() : super(const DisplayState());

  /// Starts the auto-cycling timer.
  void startCycling() {
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(
      TimingConstants.panelCycleDuration,
      (_) => _nextPanel(),
    );
  }

  /// Stops the auto-cycling timer.
  void stopCycling() {
    _cycleTimer?.cancel();
    _cycleTimer = null;
  }

  /// Manually advance to the next panel.
  void _nextPanel() {
    const panels = ActivePanel.values;
    final currentIndex = panels.indexOf(state.panel);
    final nextIndex = (currentIndex + 1) % panels.length;
    emit(DisplayState(panel: panels[nextIndex]));
  }

  /// Jump to a specific panel (e.g., on user tap).
  void showPanel(ActivePanel panel) {
    emit(DisplayState(panel: panel));
    // Restart the cycle timer so the user gets a full duration view.
    startCycling();
  }

  @override
  Future<void> close() {
    _cycleTimer?.cancel();
    return super.close();
  }
}
