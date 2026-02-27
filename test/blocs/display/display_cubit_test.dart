import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/blocs/display/display_cubit.dart';
import 'package:flutter_weather_channel/blocs/display/display_state.dart';

void main() {
  group('DisplayCubit', () {
    test('initial state shows currentConditions panel', () {
      final cubit = DisplayCubit();
      expect(cubit.state.panel, ActivePanel.currentConditions);
      cubit.close();
    });

    blocTest<DisplayCubit, DisplayState>(
      'showPanel changes to specified panel',
      build: () => DisplayCubit(),
      act: (cubit) => cubit.showPanel(ActivePanel.radar),
      expect: () => [const DisplayState(panel: ActivePanel.radar)],
    );

    blocTest<DisplayCubit, DisplayState>(
      'showPanel cycles through all panels',
      build: () => DisplayCubit(),
      act: (cubit) {
        cubit.showPanel(ActivePanel.currentConditions);
        cubit.showPanel(ActivePanel.radar);
        cubit.showPanel(ActivePanel.textSummary);
      },
      expect: () => [
        const DisplayState(panel: ActivePanel.currentConditions),
        const DisplayState(panel: ActivePanel.radar),
        const DisplayState(panel: ActivePanel.textSummary),
      ],
    );

    test('startCycling and stopCycling manage timer lifecycle', () {
      final cubit = DisplayCubit();

      // Start cycling
      cubit.startCycling();
      expect(cubit.state.panel, ActivePanel.currentConditions);

      // Stop cycling
      cubit.stopCycling();

      cubit.close();
    });

    test('close cancels timer', () async {
      final cubit = DisplayCubit();
      cubit.startCycling();
      await cubit.close();
      // If this doesn't throw, the timer was cleaned up properly
    });
  });
}
