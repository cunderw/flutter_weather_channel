import 'package:equatable/equatable.dart';

/// The three content panels that auto-cycle on the main TV view.
enum ActivePanel { currentConditions, radar, textSummary }

class DisplayState extends Equatable {
  final ActivePanel panel;

  const DisplayState({this.panel = ActivePanel.currentConditions});

  @override
  List<Object?> get props => [panel];
}
