import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/enums.dart';

import 'package:geolocator/geolocator.dart';

part 'bloc_event_map.dart';
part 'bloc_state_map.dart';

class BlocMap extends Bloc<BlocEventMap, BlocStateMap> {
  // ignore: non_constant_identifier_names
  final String TAG = 'BlocMap';
  late StreamSubscription geolocatorStream;

  BlocMap()
      : super(
          BlocStateMap(),
        ) {
    repositoryPrint(TAG, 'construct');
    initFlow();

    on<BlocEventMapChange>(_onMapChange);
  }

  @override
  Future<void> close() {
    repositoryPrint(TAG, 'close');

    try {
      repositoryPrint(TAG, geolocatorStream.isPaused);
      geolocatorStream.cancel();
    } catch (e) {
      repositoryPrint(TAG, 'e:$e');
    }

    return super.close();
  }

  Future<void> initFlow() async {
    repositoryPrint(TAG, 'initFlow');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Add Location Settings with High accuracy
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    geolocatorStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      //repositoryPrint(TAG, '- App - Position Stream: $position');
      add(
        BlocEventMapChange(
          position,
        ),
      );
    });
  }

  void _onMapChange(
    BlocEventMapChange event,
    Emitter<BlocStateMap> emit,
  ) async {
    repositoryPrint(TAG, '${event.value.timestamp?.millisecondsSinceEpoch} - ${event.value}');

    return emit(
      state.copyWith(
        gps: event.value,
        timestamp: event.value.timestamp?.millisecondsSinceEpoch,
      ),
    );
  }

  void repositoryPrint(String TAG, dynamic ex) {
    print('$TAG - $ex');
  }
}
