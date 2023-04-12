part of 'bloc_map.dart';

class BlocStateMap extends Equatable {
  BlocStateMap(
      {this.selectStart = EnumBlocStateMapSelectStatus.init,
      this.selectEnd = EnumBlocStateMapSelectStatus.init,
      this.timestamp = 0,
      this.gps = const Position(
          longitude: 23,
          latitude: 119,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: null)});

  BlocStateMap copyWith({
    EnumBlocStateMapSelectStatus? selectStart,
    EnumBlocStateMapSelectStatus? selectEnd,
    int? timestamp,
    Position? gps,
  }) {
    return BlocStateMap(
      gps: gps ?? this.gps,
      timestamp: timestamp ?? this.timestamp,
      selectStart: selectStart ?? this.selectStart,
      selectEnd: selectEnd ?? this.selectEnd,
    );
  }

  // Define
  final Position gps;
  final int timestamp;
  final EnumBlocStateMapSelectStatus selectStart;
  final EnumBlocStateMapSelectStatus selectEnd;
  @override
  List<Object> get props => [
        gps,
        timestamp,
        selectStart,
        selectEnd,
      ];
}
