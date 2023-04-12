part of 'bloc_map.dart';

class BlocEventMap extends Equatable {
  const BlocEventMap();

  @override
  List<Object> get props => [];
}

class BlocEventMapChange extends BlocEventMap {
  BlocEventMapChange(
    this.value,
  );
  Position value;

  @override
  List<Object> get props => [value];
}
